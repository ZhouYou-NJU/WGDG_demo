function [ImgRec] = getRec_GS(RawImgSet, LEDBoard, MainPara, DataLabel)
% GS method will reduce the contrast of recovered image with the existance
% of noise, so a contrast enhancement process (set CEflag = 1) is always 
% needed to show the result. The proposed WFG method does not have this
% problem. The images shown in the paper all have adjusted the contrast 
% using the 'Adjust the brightness and contrast' function and 'Auto' 
% button of ImageJ. 
CEflag                        = 1;                                               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Parameters setting
nIterative                    = MainPara.nIterative;
IllumPatternSet               = MainPara.IllumSet;
PMask                         = MainPara.Mask;
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
% initial guess of object image
ImgRec                        = 0.35*ones(RecImgSize,RecImgSize); 
% result saving folder
ResultsFolder                 = datestr(now,'YYYYmmDD_HHMMSS');
ResultsFolder                 = sprintf('GS_result_%s_%s',DataLabel,ResultsFolder);
mkdir(ResultsFolder);
%% Reconstruction process
figure;
tic;
for iIte = 1 : nIterative
    for iImg = 1 : nImg
        % forward propagation
        lightOnMask       = IllumPatternSet(:,:,iImg);                                           % illumination on pinhole mask
        lightAfterMask    = lightOnMask.*PMask;                                                  % light field after passing through mask 
        lightOnSample     = prop(lightAfterMask,PixelSize,WaveLength,D_Mask2Sample,PropMethod);  % light field propagating on sample plane       
        lightAfterSample  = lightOnSample.*ImgRec;                                               % light field after passing through sample       
        lightOnDetector   = prop(lightAfterSample,PixelSize,WaveLength,D_Sample2CCD,PropMethod); % light field propagating on image sensor plane       
        thisCapturedImg   = RawImgSet(:,:,iImg);                                                 % captured raw image under current angular light    
        thisAmpImg        = (thisCapturedImg.^0.5)*0.7+abs(lightOnDetector)*0.3;                 % use captured img and previous value to calculate current amplitude
        lightOnDetector   = thisAmpImg.*exp(1j.*angle(lightOnDetector));                         % replace amplitude image and keep phase unchange
        lightBackOnSample = prop(lightOnDetector,PixelSize,WaveLength,-D_Sample2CCD,PropMethod); % light field propagating back on sample plane
        
        % update object image
        ImgRec            = ImgRec+conj(lightOnSample)./max(max(max((abs(lightOnSample)).^2)),1e-4).*(lightBackOnSample-lightAfterSample); 
        ImgRec            = ImgRec.*ObjMask;                                                     % restrict object image inside a certain range
        % update light field before sample 
        lightOnSample     = lightOnSample+conj(ImgRec)./max(max(max((abs(ImgRec)).^2)),1e-4).*(lightBackOnSample-lightAfterSample);
        lightBackOnMask   = prop(lightOnSample,PixelSize,WaveLength,-D_Mask2Sample,PropMethod);  % light field propagating back on pinhole mask plane
        % update pinhole mask
        PMask             = PMask+0.1*conj(lightOnMask)./max(max(max((abs(lightOnMask)).^2)),1e-4).*(lightBackOnMask-lightAfterMask); 
        PMask             = PMask.*MaskRes;                                                      % restrict pinhole mask inside a certain range
        
        % show recoverd results
        AmpImgRec         = mat2gray(abs(ImgRec));
        PhsImgRec         = mat2gray(angle(ImgRec));
        AmpMaskRec        = mat2gray(abs(PMask));
        PhsMaskRec        = mat2gray(angle(PMask));
        if CEflag         == 1
            AmpImgRec     = imadjust(AmpImgRec);
            PhsImgRec     = histeq(PhsImgRec);
        end
        title_name        = sprintf('GS, Iterative = %d, Imgae Num = %d',iIte,iImg);
        subplot(221);imshow(AmpImgRec); xlabel('Rec Amp Img');title(title_name);
        subplot(222);imshow(PhsImgRec); xlabel('Rec Phs Img');
        subplot(223);imshow(AmpMaskRec);xlabel('Rec Mask Amp Img');
        subplot(224);imshow(PhsMaskRec);xlabel('Rec Mask Phs Img');
        pause(0.010);drawnow;
    end
    
    AmpImgRecSave         = AmpImgRec(ObjRange,ObjRange);
    PhsImgRecSave         = PhsImgRec(ObjRange,ObjRange);
    AmpImgRecName         = sprintf('GS AmpImgRec Iterative= %d.png',iIte);
    PhsImgRecName         = sprintf('GS PhsImgRec Iterative= %d.png',iIte);
    imwrite(AmpImgRecSave, fullfile(ResultsFolder, AmpImgRecName), 'png');
    imwrite(PhsImgRecSave, fullfile(ResultsFolder, PhsImgRecName), 'png');
end
toc;
end

