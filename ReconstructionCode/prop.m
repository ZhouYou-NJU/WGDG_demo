function [ outputObj ] = prop(obj,psize,wlength,z0,method)
%INCOHERENT Summary of this function goes here
%   Detailed explanation goes here

k0 = 2*pi/wlength;
%% setup the coordineates 
[m, n, tt] = size(obj);
x = -m/2*psize:psize:(m/2-1)*psize;
y = -n/2*psize:psize:(n/2-1)*psize;
[xm, ym] = meshgrid(x,y);
kx = -pi/psize:2*pi/((n-1)*psize):pi/psize;
ky = -pi/psize:2*pi/((n-1)*psize):pi/psize;
[kxm, kym] = meshgrid(kx,ky);
if(strcmp(method,'Angular Spectrum'))
    kzm=sqrt(k0^2-kxm.^2-kym.^2);
elseif(strcmp(method,'Fresnel'))
    kzm=k0-(kxm.^2+kym.^2)/2/k0;
end;
CTF_1 = exp(1i*real(kzm).*z0);
CTF = reshape(repmat(CTF_1,[1 tt]), m, n, tt);

%% perform filtering
objFT = fftshift(fft2(ifftshift(obj))); 
outputFT = objFT.*CTF;
outputObj = fftshift(ifft2(ifftshift(outputFT))); 
end

