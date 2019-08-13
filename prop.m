function [outputLF] = prop(inputLF,psize,wlength,z0,method)
% this fucntion realizes the free-space propogation of light field.
% inputLF is input light field, and outputLF is the output light field
% after propagating over zo distance is free space.
% the actual effect of 'Fresnel' function is similar as that of 'Angular
% Spectrum' function.
%% setup the coordineates
k0              = 2*pi/wlength; 
[ImgSize,~, tt] = size(inputLF);
kx              = -pi/psize:2*pi/((ImgSize-1)*psize):pi/psize;
ky              = -pi/psize:2*pi/((ImgSize-1)*psize):pi/psize;
[kxm, kym]      = meshgrid(kx,ky);
% realize free-space propogation
if(strcmp(method,'Angular Spectrum'))             % use angular spectrum theory
    kzm         = sqrt(k0^2-kxm.^2-kym.^2);
elseif(strcmp(method,'Fresnel'))                  % use Fresnel approximation
    kzm         = k0-(kxm.^2+kym.^2)/2/k0;
end;
CTF_1           = exp(1i*real(kzm).*z0);
CTF             = reshape(repmat(CTF_1,[1 tt]), ImgSize, ImgSize, tt);

%% perform filtering
inputFT_F       = fftshift(fft2(ifftshift(inputLF)));
outputFT        = inputFT_F.*CTF;
outputLF        = fftshift(ifft2(ifftshift(outputFT)));
end

