function [ Mask ] = getRoundMatrixMask( MaskSetting )
%GETROUNDMATRIXMASK 此处显示有关此函数的摘要
%   此处显示详细说明
%% mask with periodic aperture
    MaskRoundRadius= MaskSetting.MaskRoundRadius    ;  
    MaskRoundInterval=MaskSetting.MaskRoundInterval  ;
    nMaskRoundPerRow=MaskSetting.nMaskRoundPerRow   ; 
    MaskSize = MaskSetting.MaskSize;
    
    Mask = double(getSingleRoundMask(MaskSize, MaskRoundRadius, MaskRoundInterval, nMaskRoundPerRow));

end

function Mask = getSingleRoundMask(MaskSize, MaskRoundRadius, MaskRoundInterval, nMaskRoundPerRow)
    [xi,yi]=LEDposition(nMaskRoundPerRow);
    if (mod(nMaskRoundPerRow,2)==0)
        xi=xi-0.5;
        yi=yi-0.5;
    end
    xcenter=xi.*MaskRoundInterval+round(MaskSize./2);
    ycenter=yi.*MaskRoundInterval+round(MaskSize./2);
    % % 
    [phi,sita]=meshgrid(1:MaskSize,1:MaskSize);
    for i=1:nMaskRoundPerRow.^2
        masksingle(:,:,i)=double(((sita-(ycenter(i)))/MaskRoundRadius).^2+((phi-(xcenter(i)))/MaskRoundRadius).^2<=1);% mask between sample and ccd
    end

    Mask=im2bw(sum(masksingle,3),0.5);
end



