function [RawImgSet] = getIdealData(InputImg, Mask, LEDBoard, PixelSize, D_Mask2Sample, D_Sample2CCD, IllumPatSet, PropMethod)
% this function generates raw images in ideal condition.
nLEDPerRow   = LEDBoard.nLEDPerRow;
nRawImg      = nLEDPerRow^2;
WaveLength   = LEDBoard.WaveLength;
[ImgSize, ~] = size(InputImg);
RawImgSet    = zeros(ImgSize, ImgSize, nRawImg);     % raw image set in ideal condition
% forward imaging model
for iImg=1:nRawImg
    LightAfterMask        = IllumPatSet(:,:,iImg).*Mask;
    LightOnSample         = prop(LightAfterMask,PixelSize,WaveLength,D_Mask2Sample,PropMethod);
    LightAfterSample      = InputImg.*LightOnSample;
    LightOnCCD            = prop(LightAfterSample,PixelSize,WaveLength,D_Sample2CCD,PropMethod);
    RawImgSet(:,:,iImg)   = (abs(LightOnCCD)).^2;    % record the intensiy of diffraction pattern
end
RawImgSet_max = max(RawImgSet(:));
RawImgSet     = RawImgSet/RawImgSet_max;                   % normalization
% saving folder
RawImgSaveFolder='GenerateRawImageSet/1_IdealData';
if ~exist(RawImgSaveFolder,'file')
    mkdir(RawImgSaveFolder);
end
% save raw images
for iImg=1:nRawImg
    ImgName=sprintf('%s/RawImg_%0.2d.png',RawImgSaveFolder,iImg);
    imwrite(RawImgSet(:,:,iImg),ImgName,'png');
end
end