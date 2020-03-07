function [RawImgSetG] = getGaNoiseData(InputImg, Mask, LEDBoard, PixelSize, D_Mask2Sample, D_Sample2CCD, IllumPatSet, PropMethod, deltaG)
% this function generates raw images with Gaussian noise.
% deltaG is the pre-set standard deviation of Gaussian noise.
%  we use deltaG = 0.008 in the demo.
nLEDPerRow   = LEDBoard.nLEDPerRow;
nRawImg      = nLEDPerRow^2;
WaveLength   = LEDBoard.WaveLength;
[ImgSize, ~] = size(InputImg);
RawImgSet    = zeros(ImgSize, ImgSize, nRawImg);                   % raw image set in ideal condition
% forward imaging model
for iImg=1:nRawImg
    LightAfterMask       = IllumPatSet(:,:,iImg).*Mask;
    LightOnSample        = prop(LightAfterMask,PixelSize,WaveLength,D_Mask2Sample,PropMethod);
    LightAfterSample     = InputImg.*LightOnSample;
    LightOnCCD           = prop(LightAfterSample,PixelSize,WaveLength,D_Sample2CCD,PropMethod);
    RawImgSet(:,:,iImg)  = (abs(LightOnCCD)).^2;                   % record the intensiy of diffraction pattern
end
RawImgSet_max = max(RawImgSet(:));
RawImgSet     = RawImgSet/RawImgSet_max;                           % normalization
% saving folder
RawImgSaveFolder = 'GenerateRawImageSet/4_GaussianNoiseData';
if ~exist(RawImgSaveFolder,'file')
    mkdir(RawImgSaveFolder);
end
% add Gaussian noise and save raw images
RawImgSetG = RawImgSet;                                            % raw image set with Gaussian noise
NoiseAverVal = 0.025;
for iImg=1:nRawImg
    thisImg              = RawImgSetG(:,:,iImg);
    thisImgGn            = imnoise(thisImg,'gaussian',NoiseAverVal,deltaG^2); % add Gaussian noise
    RawImgSetG(:,:,iImg) = thisImgGn;
    ImgName              = sprintf('%s/RawImg_%0.2d.png',RawImgSaveFolder,iImg);
    imwrite(RawImgSetG(:,:,iImg),ImgName,'png');
end
end
