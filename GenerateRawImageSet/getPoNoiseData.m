function [RawImgSetP] = getPoNoiseData(InputImg, Mask, LEDBoard, PixelSize, D_Mask2Sample, D_Sample2CCD, IllumPatSet, PropMethod, deltaP)
% this function generates raw images with LED misalignment.
% deltaP is the parameter of Poisson noise.
% we use deltaP = 1/2 in the demo, and Poisson noise becomes larger when 
% the value of deltaP is smaller (for example, 1/3).
nLEDPerRow   = LEDBoard.nLEDPerRow;
nRawImg      = nLEDPerRow^2;
WaveLength   = LEDBoard.WaveLength;
[ImgSize, ~] = size(InputImg);
RawImgSet    = zeros(ImgSize, ImgSize, nRawImg);                       % raw image set in ideal condition
% forward imaging model
for iImg=1:nRawImg
    LightAfterMask        = IllumPatSet(:,:,iImg).*Mask;
    LightOnSample         = prop(LightAfterMask,PixelSize,WaveLength,D_Mask2Sample,PropMethod);
    LightAfterSample      = InputImg.*LightOnSample;
    LightOnCCD            = prop(LightAfterSample,PixelSize,WaveLength,D_Sample2CCD,PropMethod);
    RawImgSet(:,:,iImg)   = (abs(LightOnCCD)).^2;                      % record the intensiy of diffraction pattern
end
RawImgSet_max = max(RawImgSet(:));
RawImgSet     = RawImgSet/RawImgSet_max;                               % normalization
% saving folder
RawImgSaveFolder='GenerateRawImageSet/3_PoissonNoiseData';
if ~exist(RawImgSaveFolder,'file')
    mkdir(RawImgSaveFolder);
end
% add Poisson noise and save raw images
RawImgSetP = RawImgSet;                                                 % raw image set with Poisson noise
for iImg=1:nRawImg
    thisImg              = RawImgSetP(:,:,iImg);
    thisImgPo            = imnoise(thisImg./deltaP,'poisson').*deltaP;  % add Gaussian noise
    RawImgSetP(:,:,iImg) = thisImgPo;
    ImgName              = sprintf('%s/RawImg_%0.2d.png',RawImgSaveFolder,iImg);
    imwrite(RawImgSetP(:,:,iImg),ImgName,'png');
end
end