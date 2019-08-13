function InputImg = getInputImg(AmpImgPath, PhaseImgPath, InputImgSize, TargetSize)
AmpImg     =    im2double(imread(AmpImgPath));
%     AmpImg     =    mat2gray(sqrt(rgb2gray(AmpImg)))+0.1;
AmpImg     =    mat2gray((AmpImg(:,:,2)))+0.1;%mat2gray(sqrt(AmpImg(:,:,2)))+0.2;
AmpImg     =    imresize(AmpImg, [InputImgSize InputImgSize],'nearest');
AmpImg     =    AmpImg./max(AmpImg(:));

PhaseImg    =   im2double(imread(PhaseImgPath));
%     PhaseImg    =    mat2gray(sqrt(rgb2gray(PhaseImg)))+0.05;
PhaseImg    =   mat2gray(PhaseImg(:,:,2))+0.2;
PhaseImg    =   imresize(PhaseImg,[InputImgSize InputImgSize],'nearest');
PhaseImg    =   PhaseImg./max(PhaseImg(:))*pi/2;

InputImg = AmpImg .* exp(1i*PhaseImg);
InputImg = padarray(InputImg, [round((TargetSize-InputImgSize)/2) round((TargetSize-InputImgSize)/2)], 0);
%     InputImg = padarray(InputImg, [round((TargetSize-InputImgSize)/2) round((TargetSize-InputImgSize)/2)],0.02,'both');
end