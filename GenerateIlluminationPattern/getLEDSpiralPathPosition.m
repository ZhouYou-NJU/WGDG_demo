function [ LEDPositionX, LEDPositionY ] = getLEDSpiralPathPosition( nLEDPerRow )
% this function generates LED Positions in Spiral Path
OrderMat     = spiral(nLEDPerRow);
OrderMat     = rot90(OrderMat,3);
% OrderMat     = fliplr(OrderMat);
nLED         = nLEDPerRow^2;    % total illumination number
LEDPositionX = zeros(1, nLED);
LEDPositionY = zeros(1, nLED);

for iLED = 1:nLED
    [iRow, jCol]       = find(OrderMat == iLED);
    LEDPositionX(iLED) = iRow;
    LEDPositionY(iLED) = jCol;
end
LEDPositionX = LEDPositionX - round(nLEDPerRow/2);
LEDPositionY = LEDPositionY - round(nLEDPerRow/2);
end

