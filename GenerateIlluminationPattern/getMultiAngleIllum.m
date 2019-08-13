function [IllumPaSet,kxSet,kySet] = getMultiAngleIllum(InputImg, LEDBoard, PixelSize, D_LED2Sample)
% this function calculates the illumination patterns of angle lights
nLEDPerRow   = LEDBoard.nLEDPerRow;
LED_Interval = LEDBoard.LED_Interval;        % distance between each lighting LED
nPattern     = nLEDPerRow^2;                 % total illumination pattern number
xint         = LEDBoard.xint;                % X shift of LED matrix
yint         = LEDBoard.yint;                % Y shift of LED matrix
sita         = LEDBoard.rotation;            % rotation of LED matrix
WaveLength   = LEDBoard.WaveLength;
k0           = 2*pi/WaveLength;              % wave number
[mRow, nCol] = size(InputImg);
x            = -nCol/2*PixelSize:PixelSize:(nCol/2-1)*PixelSize;
y            = -mRow/2*PixelSize:PixelSize:(mRow/2-1)*PixelSize;
[xm, ym]     = meshgrid(x,y);
IllumPaSet   = zeros(mRow, nCol, nPattern);
IllumMax     = 0;

[ LEDPositionX, LEDPositionY ] = getLEDSpiralPathPosition( nLEDPerRow ); % generates LED Positions
[kxSet,kySet,~] = gkxkywithxy3(LEDPositionX, LEDPositionY, D_LED2Sample, LED_Interval, xint, yint ,1 ,0, sita); % calculate angles of incident lights

for iImg=1:nPattern
    kxill                = kxSet(iImg);
    kyill                = kySet(iImg);
    IllumPaSet(:,:,iImg) = exp(1j*kxill*k0*xm).*exp(1j*kyill*k0*ym);
    abs_thisIllum        = abs(IllumPaSet(:,:,iImg));
    IllumMax             = max(IllumMax,max(abs_thisIllum(:)));
end
IllumPaSet   = IllumPaSet./IllumMax;
end