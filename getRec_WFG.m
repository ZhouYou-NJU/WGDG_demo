function [ImgRec] = getRec_WFG(RawImgSet, LEDBoard, MainPara, Delta_g, DataLabel)
% this fucntion realizes the reconstruction code of WFG method in the paper
% for lensless imaging with mask updating.
%% Parameters setting
nIterative                    = MainPara.nIterative;
IllumPatternSet               = MainPara.IllumSet;
PMask0                        = MainPara.Mask;
PixelSize                     = MainPara.PixelSize;
D_Mask2Sample                 = MainPara.D_Mask2Sample;
D_Sample2CCD                  = MainPara.D_Sample2CCD;
PropMethod                    = MainPara.PropMethod;
ObjSize                       = MainPara.InputImgSize;
WaveLength                    = LEDBoard.WaveLength;
[RecImgSize,~,nImg]           = size(RawImgSet);
% pinhole mask range restriction
MaskSetting.MaskSize          = RecImgSize;
MaskSetting.nMaskRoundPerRow  = 1;
MaskSetting.MaskRoundRadius   = round(150e-6/PixelSize*1.02);
MaskSetting.MaskRoundInterval = round(0/PixelSize);
MaskRes                       = getRoundMatrixMask(MaskSetting);
% object range restriction
ObjMask                       = zeros(RecImgSize,RecImgSize);
ObjSize                       = ObjSize+5;
ObjRange                      = round((RecImgSize-ObjSize)/2)+1:round((RecImgSize-ObjSize)/2)+ObjSize;
ObjMask(ObjRange,ObjRange)    = 1;
% result saving folder
ResultsFolder                 = datestr(now, 'YYYYmmDD_HHMMSS');
ResultsFolder                 = sprintf('WFG_result_%s_%s',DataLabel,ResultsFolder);
mkdir(ResultsFolder);
%% Initialization
ImgRec0                       = 0.35*ones(RecImgSize,RecImgSize);  % initial guess of object image
ImgRec                        = ImgRec0;
PMask                         = PMask0;
mu                            = 1;                                 % weighting parameter to incorporate the noise constraint 
mu1                           = 1e-4;                              % small coefficient of fine-tuning regularization to control estimated object
Gset                          = zeros(RecImgSize,RecImgSize,nImg); % Gaussian noise matrix set
Eset                          = zeros(RecImgSize,RecImgSize,nImg); % relaxation matrix set
DeltaFlag                     = 0;                                 % control to use changing delta parameters or constant values
CEflag                        = 0;                                 % image contrast enhancement flag  
%% Reconstruction process
figure;
tic;
for iIte = 1 : nIterative
    for iImg = 1 : nImg
        % forward propagation
        lightOnMask      = IllumPatternSet(:,:,iImg);                                           % illumination on pinhole mask
        lightAfterMask   = lightOnMask.*PMask;                                                  % light field after passing through mask 
        lightOnSample    = prop(lightAfterMask,PixelSize,WaveLength,D_Mask2Sample,PropMethod);  % light field propagating on sample plane
        lightAfterSample = lightOnSample.*ImgRec;                                               % light field after passing through sample  
        lightOnDetector  = prop(lightAfterSample,PixelSize,WaveLength,D_Sample2CCD,PropMethod); % light field propagating on image sensor plane
        
        % calculate correspounding values using equations in the maniscript
        P                = lightOnMask;
        M                = PMask;
        B                = lightOnDetector;
        O                = ImgRec;
        D                = RawImgSet(:,:,iImg);                                                 % captured raw image under current angular light  
        B1               = conj(B).*B+Gset(:,:,iImg);                                           % |B|.^2+G
        C0               = sqrt(B1);                                                            % sqrt(|B|.^2+G)
        C1               = B./C0;                                                               % B./sqrt(|B|.^2+G)
        C2               = -sqrt(D)+C0;                                                         % -sqrt(D)+ sqrt(|B|.^2+G)
        C3               = prop(C1.*C2,PixelSize,WaveLength,-D_Sample2CCD,PropMethod);          % conj(PSF_2)*{[B./sqrt(|B|.^2+G)]，[-sqrt(D)+ sqrt(|B|.^2+G)]} 
        C4               = C3.*conj(O);                                                         % C3，conj(O)
        C5               = C2./C0;                                                              % [-sqrt(D)+ sqrt(|B|.^2+G)]./[sqrt(|B|.^2+G)]
        C6               = 4*mu.*Gset(:,:,iImg).*(Gset(:,:,iImg).*Gset(:,:,iImg)+...            % df/dE --- Eq.(15)
                           Eset(:,:,iImg).*Eset(:,:,iImg)-9*Delta_g^2);
       
        % update object image
        df_O             = conj(lightOnSample).*C3+mu1.*O;                                      % df/d[conj(O)]=[conj(PSF_1)*(M，P)^*]，C3 + mu1，O --- Eq.(12)
        if DeltaFlag     == 1                                                                   % gradient descent step size of O
            delta1       = min(1-exp(-iIte/33),0.075)/(sum(sum(abs(ImgRec0).^2)))*1e5;    
        else
            delta1       = 0.5;
        end
        O                = O-1/2*delta1*df_O;                                                   % --- Eq.(9)
        O                = O.*ObjMask;                                                          % restrict object image inside a certain range
        % update pinhole mask
        df_M             = conj(P).*prop(C4,PixelSize,WaveLength,-D_Mask2Sample,PropMethod);    % df/d[conj(M)]=conj(P)，{conj(PSF_1)*[conj(PSF_2)*C3]} --- Eq.(13)   
        if DeltaFlag     == 1                                                                   % gradient descent step size of M
            delta2       = min(1-exp(-iIte/33),0.15)/(sum(sum(abs(PMask0).^2)))*2e3;
        else
            delta2       = 0.008;
        end
        M                = M-1/2*delta2*df_M;                                                    % --- Eq.(10)
        M                = M.*MaskRes;                                                           % restrict pinhole mask inside a certain range
        % update Gn matrix
        df_Gn            = C5+C6;                                                                % df/dG --- Eq.(14)
        if DeltaFlag     == 1 
            delta3       = min(1-exp(-100/33),0.15)/Delta_g^2/1e5;
        else
            delta3       = 0.002;
        end
        GnNew            = (Gset(:,:,iImg)-1/2*delta3*df_Gn);
        GnNew(GnNew<0)   = 0;                                                                    % Gset includes only nonnegative real values 
        Gset(:,:,iImg)   = GnNew;
        % update E matrix
        Eset(:,:,iImg)   = sqrt(max(0,9*Delta_g^2-Gset(:,:,iImg).*Gset(:,:,iImg)));              % --- Eq.(16)    
        
        % show recoverd results
        PMask            = M;
        ImgRec           = O;
        AmpImgRec        = mat2gray(abs(ImgRec));
        PhsImgRec        = mat2gray(angle(ImgRec));
        AmpMaskRec       = mat2gray(abs(PMask));
        PhsMaskRec       = mat2gray(angle(PMask));
        if CEflag        == 1
            AmpImgRec    = imadjust(AmpImgRec);
            PhsImgRec    = imadjust(PhsImgRec);
        end
        title_name       = sprintf('WFG, Iterative = %d, Imgae Num = %d',iIte,iImg);
        subplot(221);imshow(AmpImgRec); xlabel('Rec Amp Img');title(title_name);
        subplot(222);imshow(PhsImgRec); xlabel('Rec Phs Img');
        subplot(223);imshow(AmpMaskRec);xlabel('Rec Mask Amp Img');
        subplot(224);imshow(PhsMaskRec);xlabel('Rec Mask Phs Img');
        pause(0.010);drawnow;
    end
    AmpImgRecSave        = AmpImgRec(ObjRange,ObjRange);
    PhsImgRecSave        = PhsImgRec(ObjRange,ObjRange);
    AmpImgRecName        = sprintf('WFG AmpImgRec Iterative= %d.png',iIte);
    PhsImgRecName        = sprintf('WFG PhsImgRec Iterative= %d.png',iIte);
    imwrite(AmpImgRecSave, fullfile(ResultsFolder, AmpImgRecName), 'png');
    imwrite(PhsImgRecSave, fullfile(ResultsFolder, PhsImgRecName), 'png');
end
toc;
end

