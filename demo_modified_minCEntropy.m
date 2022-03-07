clc;clear;close all;

image=imread('peppers.png');
K=12; % Number of clusters
image=double(image);

[rows, columns,dim]=size(image);
X=reshape(image,[rows*columns dim]);

% Check MATLAB version
version_year=isMATLABReleaseOlderThan("R2021a");

if version_year==1

mem=demo_minCEntropy_modified_Older_Version(X,K); % run minCEntropy+ 10 times

else 
    
delete(gcp('nocreate'))
   
mem=demo_minCEntropy_modified_Newer_Version(X,K); % run minCEntropy+ 10 times

end


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
title('segmeted image')


