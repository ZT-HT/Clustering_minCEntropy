clc;clear;close all;

image=imread('peppers.png');

K=12; % Number of clusters
image=double(image);

delete(gcp('nocreate'))
parpool('threads')

[rows, columns, dim]=size(image);
X=reshape(image,[rows*columns dim]);

   
mem=minCEntropy(X,K,sigma_factor=1,n_run=10,parallel="on",verbose=true);  % run minCEntropy+ 10 times


X=reshape(X,[rows columns dim]);

subplot(1,2,1);imshow(uint8(X))
title('image')

mem1=reshape(mem,[rows columns]);

if dim==3
segmented_image =  color_assignment(X,mem1);
else
segmented_image =  grayscale_assignment(X,mem1);
end

subplot(1,2,2);imshow(uint8(segmented_image))
title('segmented image')


