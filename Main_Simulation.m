clear; clc; close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Parameters setting
D_LED2Mask            = 300e-3;                 % distance from LED matirx to sample (unit: m)
D_Mask2Sample         = 5.0e-3;                 % distance from pinhole mask to sample (unit: m)
D_Sample2CCD          = 0.5e-3;                 % distance from Sample to image sensor (unit: m)
UpSampleRatio         = 1.0;                    % upsample ratio
PixelSize             = 1.67e-6/UpSampleRatio;  % effective pixel size of imaging system (unit: m)
PropMethod            = 'Angular Spectrum';     % Propagation Method
% ideal LED
LEDBoard.WaveLength   = 530e-9;                 % wavelength(green) of LED light (unit: m)
LEDBoard.nLEDPerRow   = 5;                      % number of Lighting LEDs in X/Y directions
LEDBoard.step         = 1;                      % interval numbers of neibourhooding lighting LEDs in LED matirx
LEDBoard.LED_Interval = 4e-3*LEDBoard.step;     % interval distance of neibourhooding lighting LEDs (unit: m)
LEDBoard.xint         = 0;                      % X shift of center of LED panel (unit: m)
LEDBoard.yint         = 0;                      % Y shift of center of LED panel (unit: m)
LEDBoard.rotation     = 0;                      % rotation of LED panel (unit: m)
% mismatched LED
LEDBoardm             = LEDBoard;
LEDBoardm.xint        = 1.5e-4;                 % (unit: m)
LEDBoardm.yint        = -1.5e-4;                % (unit: m)
LEDBoardm.rotation    = 0.008;                  % (unit: rad)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Input object image
InputImgSize          = round(280*UpSampleRatio);                                          % size of input image (assumed to be square)
TargetSize            = round(400*UpSampleRatio);                                          % image size after padding
AmpImgPath            = 'liftingbody.png';                                                 % amplitude image
PhaseImgPath          = 'lighthouse.png';                                                  % phase image
InputImg              = getInputImg(AmpImgPath, PhaseImgPath, InputImgSize, TargetSize);   % generate input object image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Pinhole mask setting
MaskSetting.MaskSize          = TargetSize;                         % whole size of mask
MaskSetting.nMaskRoundPerRow  = 1;                                  % 1, pinhole mask; n>1, parallel round mask
MaskSetting.MaskRoundRadius   = round(150e-6/PixelSize);            % radius of pinhole
MaskSetting.MaskRoundInterval = round(0/PixelSize);                 % for pinhole mask, this parameter has no use   
Mask                          = getRoundMatrixMask(MaskSetting);    % generate pinhole mask
% image show
figure;
subplot(221);imshow(abs(InputImg),[]);   xlabel('Input amplitude image');
subplot(222);imshow(angle(InputImg),[]); xlabel('Input phase image');
subplot(223);imshow(Mask,[]);            xlabel('Input pinhole mask');
drawnow;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Raw image set
% generate illumination
disp('Generate Raw Image Set ...');
[IllumSet]    = getMultiAngleIllum(InputImg, LEDBoard,  PixelSize, D_LED2Mask);                                                    % ideal illumination
[IllumSetm]   = getMultiAngleIllum(InputImg, LEDBoardm, PixelSize, D_LED2Mask);                                                    % mismatched illumination
% generate raw image set
[RawImgSet]   = getIdealData   (InputImg, Mask, LEDBoard, PixelSize, D_Mask2Sample, D_Sample2CCD, IllumSet,  PropMethod);          % ideal data
[RawImgSetm]  = getMismatchData(InputImg, Mask, LEDBoard, PixelSize, D_Mask2Sample, D_Sample2CCD, IllumSetm, PropMethod);          % data with mismatched LEDs
DeltaPo       = 0.500; % parameter of Poisson noise
[RawImgSetPo] = getPoNoiseData (InputImg, Mask, LEDBoard, PixelSize, D_Mask2Sample, D_Sample2CCD, IllumSet,  PropMethod, DeltaPo); % data with Poisson noise
DeltaGa       = 0.020; % Standard deviation of Gaussian noise
[RawImgSetGa] = getGaNoiseData (InputImg, Mask, LEDBoard, PixelSize, D_Mask2Sample, D_Sample2CCD, IllumSet,  PropMethod, DeltaGa); % data with Gaussian noise
disp('Generate Raw Image Set Finished.');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Reconstruction
% set main parameters of reconstruction
MainPara.nIterative    = 200;
MainPara.IllumSet      = IllumSet;
MainPara.Mask          = Mask;
MainPara.PixelSize     = PixelSize;
MainPara.D_Mask2Sample = D_Mask2Sample;
MainPara.D_Sample2CCD  = D_Sample2CCD;
MainPara.PropMethod    = PropMethod;
MainPara.InputImgSize  = InputImgSize;
DataLabel              = 'GD';                                                            % data with Gaussian nois
Delta_g                = 1e-5;                                                            % guessed standard deviation of Gaussian noise, use a small value here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
switch DataLabel
    case 'ID'                                                                             % ideal data       
        [ImgRecGS_ID]  = getRec_GS (RawImgSet,   LEDBoard, MainPara, DataLabel);          % GS algorithm
        [ImgRecWFG_ID] = getRec_WFG(RawImgSet,   LEDBoard, MainPara, Delta_g, DataLabel); % WFG algorithm
    case 'PD'                                                                             % data with Poisson noise
        [ImgRecGS_PD]  = getRec_GS (RawImgSetPo, LEDBoard, MainPara, DataLabel);          % GS algorithm
        [ImgRecWFG_PD] = getRec_WFG(RawImgSetPo, LEDBoard, MainPara, Delta_g, DataLabel); % WFG algorithm
    case 'MD'                                                                             % data with mismatched LEDs
        [ImgRecGS_MD]  = getRec_GS (RawImgSetm,  LEDBoard, MainPara, DataLabel);          % GS algorithm
        [ImgRecWFG_MD] = getRec_WFG(RawImgSetm,  LEDBoard, MainPara, Delta_g, DataLabel); % WFG algorithm
    case 'GD'                                                                             % data with Gaussian noise
        [ImgRecGS_GD]  = getRec_GS (RawImgSetGa, LEDBoard, MainPara, DataLabel);          % GS algorithm 
        Delta_g        = DeltaGa;                                                         % guessed standard deviation of Gaussian noise
        [ImgRecWFG_GD] = getRec_WFG(RawImgSetGa, LEDBoard, MainPara, Delta_g, DataLabel); % WFG algorithm
end  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 