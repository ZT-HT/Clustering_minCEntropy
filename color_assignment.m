function seg = color_assignment(image,label)
%The code taken from https://www.mathworks.com/help/images/ref/superpixels.html

% Set the color of each pixel in the output image to the mean RGB color of the region

%Input required arguments:
%   image: image with the size of rows*cols*3
%   label: assigned label to the image

%Output required arguments:
%   seg: coloured image based the labels


seg = zeros(size(image),'like',image);


idx = label2idx(label);
numRows = size(image,1);
numCols = size(image,2);
label=reshape(label, size(label,1)*size(label,2) ,1);
N=length(unique(label,'row'));%Number of relevant colours


for labelVal = 1:N
    redIdx = idx{labelVal};
    greenIdx = idx{labelVal}+numRows*numCols;
    blueIdx = idx{labelVal}+2*numRows*numCols;
    seg(redIdx) = mean(image(redIdx));
    seg(greenIdx) = mean(image(greenIdx));
    seg(blueIdx) = mean(image(blueIdx));
end    


end
