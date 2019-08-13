function [kx, ky, NAt]= gkxkywithxy3(xi,yi,H,LEDp,xint,yint,nglass,t,sita)
% this fucntion calculate the angles (kx ky) of incident lights.
% x is along horizonal direction; y is along vertical direction
% sita for rotation
% kx ky here are the normalized wavevectors; it should times k0 later
total = size(xi,2);
kx    = zeros(1,total);
ky    = kx;
NAt   = kx;
for tt=1:total
    x0 = xint+xi(1,tt)*LEDp; % from rightmost postion
    y0 = yint+yi(1,tt)*LEDp; % from topmost postion
    x1 = x0*cos(sita*pi/180)-y0*sin(sita*pi/180);
    y1 = x0*sin(sita*pi/180)+y0*cos(sita*pi/180);
    [kx(1,tt), ky(1,tt), NAt(1,tt)] = calculate(x1,y1,H,t,nglass);
end;
end

function [kx, ky, NAt]=calculate(x0,y0,H,h,n)
l      = sqrt(x0^2+y0^2);          % distance of LED from origin
thetal = atan2(y0,x0);             % angle of LED in x-y plane
xoff   = 0;                        % initial guess where beam enters bottom of slide
thetag = -asin(l/sqrt(l^2+H^2)/n); % get angle of beam in glass from Snell's law
xint   = h*tan(thetag);            % find where the beam exits the top of the slide
xoff   = xoff-xint;                % modify guess where beam enters bottom of slide by this amount

% repeat the above procedure until the beam exits the top of the slide
% within 1 micron of center
while abs(xint) > .001
    thetag = -asin((l-xoff)/sqrt((l-xoff)^2+H^2)/n);
    xint   = xoff+h*tan(thetag);
    xoff   = xoff-xint;
end
% angle under the glass and angle over the cover slip
% Here treats this as the angle in the sample, so pretends the sample has
% refractive index 1.0
theta = asin((l-xoff)/sqrt((l-xoff)^2+H^2));
NAt   = abs(sin(theta));
kx    = -NAt*cos(thetal);
ky    = -NAt*sin(thetal);
end