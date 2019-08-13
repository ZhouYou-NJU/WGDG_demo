function [RawImgSetWithPo] = getPoNoiseData(InputImg, Mask, LEDBoard, PixelSize,DistanceMask2Sample,...
    DistanceSample2CCD, IlluminationPatternSet, PropMethod, delta)
    nLEDPerRow = LEDBoard.nLEDPerRow        ;          % arraysize by arraysize
    nLED                =   nLEDPerRow^2;
    WaveLength = LEDBoard.WaveLength;
    nRawImg = nLED;    
    [mRow, nCol] = size(InputImg);  
    RawImgSet = zeros(mRow, nCol, nRawImg);
    for iImg=1:nRawImg
        LightAfterMask        = IlluminationPatternSet(:,:,iImg).*Mask; 
        LightOnSample         = prop(LightAfterMask,PixelSize,WaveLength,DistanceMask2Sample,PropMethod);% prop to CCD
        LightAfterSample      = InputImg.*LightOnSample;% plane wave multiply high reso image
        LightOnCCD            = prop(LightAfterSample,PixelSize,WaveLength,DistanceSample2CCD,PropMethod);% prop to CCD
        RawImgSet(:,:,iImg)      = (abs(LightOnCCD)).^2;% record the abs
%         disp(iImg);
    end
    RawImgSet_max=max(RawImgSet(:));
    RawImgSet=RawImgSet/RawImgSet_max;
    RawImgSaveFolder='GenerateRawImageSet/3_PoissonNoiseData';
    if ~exist(RawImgSaveFolder,'file')
        mkdir(RawImgSaveFolder);
    end
    RawImgSetWithPo=RawImgSet;
    for iImg=1:nRawImg
        thisImg=RawImgSetWithPo(:,:,iImg);
        thisImgPo=imnoise(thisImg./delta,'poisson').*delta;
        RawImgSetWithPo(:,:,iImg)=thisImgPo;
        ImgName=sprintf('%s/RawImg_%0.2d.png',RawImgSaveFolder,iImg);
        imwrite(RawImgSetWithPo(:,:,iImg),ImgName,'png');
    end
%     RawImgSetWithPo_max=max(RawImgSetWithPo(:));
%     RawImgSetWithPo=RawImgSetWithPo/RawImgSetWithPo_max;
end