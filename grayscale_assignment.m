function seg = grayscale_assignment(image,label)
%The code take from https://www.mathworks.com/help/images/ref/superpixels.html with some modifications

% Set the color of each pixel in the output image to the mean RGB color of the region

%Input required arguments:
%   image: image with the size of rows*cols*3
%   label: assigned label to the image

%Output required arguments:
%   seg: coloured image based the labels


seg = zeros(size(image),'like',image);

idx = label2idx(label);

label=reshape(label, size(label,1)*size(label,2) ,1);
N=length(unique(label,'row'));%Number of relevant colours


for labelVal = 1:N
    grayIdx = idx{labelVal};
    seg(grayIdx) = mean(image(grayIdx));
end    


end
