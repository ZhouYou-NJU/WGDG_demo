function [ Mask ] = getRoundMatrixMask( MaskSetting )
% this function generates mask with periodic round aperture.
% note that, in this demo, we only use this function to generate a pinhole 
% mask (single-round mask) between the LED matrix and sample.
MaskRoundRadius   = MaskSetting.MaskRoundRadius    ;
MaskRoundInterval = MaskSetting.MaskRoundInterval  ;
nMaskRoundPerRow  = MaskSetting.nMaskRoundPerRow   ;
MaskSize          = MaskSetting.MaskSize;
Mask              = double(getSingleRoundMask(MaskSize, MaskRoundRadius, MaskRoundInterval, nMaskRoundPerRow));
end

function Mask = getSingleRoundMask(MaskSize, MaskRoundRadius, MaskRoundInterval, nMaskRoundPerRow)
% this function generates single-round mask
[xi,yi] = LEDposition(nMaskRoundPerRow);
if (mod(nMaskRoundPerRow,2)==0)
    xi = xi-0.5;
    yi = yi-0.5;
end
xcenter    = xi.*MaskRoundInterval+round(MaskSize./2);
ycenter    = yi.*MaskRoundInterval+round(MaskSize./2);
[phi,sita] = meshgrid(1:MaskSize,1:MaskSize);
for i=1:nMaskRoundPerRow^2
    masksingle(:,:,i) = double(((sita-(ycenter(i)))/MaskRoundRadius).^2+((phi-(xcenter(i)))/MaskRoundRadius).^2<=1);
end
Mask = im2bw(sum(masksingle,3),0.5);
end



