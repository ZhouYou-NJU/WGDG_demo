function InputImg = getInputImg(AmpImgPath, PhaseImgPath, InputImgSize, TargetSize)
% this function generates complex field image of object, as ground-truth. 
% we use the image from 'AmpImgPath' as input amplitude and the image from
% 'PhaseImgPath' as input phase.
% the complex field image is then padded with zero values and enlarged from 
% 'InputImgSize' to 'TargetSize'. 

AmpImg   = im2double(imread(AmpImgPath));
AmpImg   = mat2gray((AmpImg(:,:,2)))+0.1;
AmpImg   = imresize(AmpImg, [InputImgSize InputImgSize],'nearest');
AmpImg   = AmpImg./max(AmpImg(:));

PhaseImg = im2double(imread(PhaseImgPath));
PhaseImg = mat2gray(PhaseImg(:,:,2))+0.1;
PhaseImg = imresize(PhaseImg,[InputImgSize InputImgSize],'nearest');
PhaseImg = PhaseImg./max(PhaseImg(:))*pi/2;

InputImg = AmpImg .* exp(1i*PhaseImg);
% pad zeros in borders of complex image
InputImg = padarray(InputImg, [round((TargetSize-InputImgSize)/2) round((TargetSize-InputImgSize)/2)], 0); 
end