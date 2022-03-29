# Modified minCEntropy clustering: partitional clustering using the minimum conditional Entropy objective for image segmentation

This repository contains the software used in the paper entitled "Efficient human estimates of relevant colors of paintings" (Publication in progress).  It uses a modified version of the minCEntropy algorithm developed by Xuan Vinh Nguyen [2010] to perform image segmentation.  The primary difference between this implementation of minCEntropy and the original is that this version is faster and more suited to larger data sets. 

Here is a demonstration of its use for segmenting the image `peppers.png` (which is built into MATLAB) using 12 clusters

```
image=imread('peppers.png');  %This image is built into MATLAB

% prepare the image
image=double(image);
[rows, columns,dim]=size(image);
X=reshape(image,[rows*columns dim]);

K=12; % Number of clusters
% perform clustering
[mem]=minCEntropy_modified_Newer_Version(X,K,sigma_factor=1,n_run=10,parallel="off",verbose=true);

% Display image alongside segmented image
X=reshape(X,[rows columns dim]);
subplot(1,2,1);imshow(uint8(X))
title('image')

mem = reshape(mem,[rows columns]);

if dim==3
segmented_image =  color_assignment(X,mem);
else
segmented_image =  grayscale_assignment(X,mem);
end

subplot(1,2,2);imshow(uint8(segmented_image))
title('segmeted image')
```

The output of running the code is 

```
Initialising using MATLABkmeans
Parallel mode is  off
Sigma factor: 1, changes: 12866, quality: 178360.057143
>>>>>>>>Finished clustering. best quality: 178360.057143

```

![](https://github.com/ZT-HT/Clustering_minCEntropy/blob/main/segmented.bmp)



This example will take quite a long time to run (e.g. 2617.392 s seconds on a Intel(R) Core(TM) i7-10710U CPU @ 1.10GHz 1.61 GHz), see the **parallel execution** section for details on how to make it faster.

## Parallel execution 

If you have access to the [Parallel Computing Toolbox](https://www.mathworks.com/products/parallel-computing.html), you can switch parallelisation on which can result in significant improvements in speed.  Create a parallel pool:

```
parpool('threads')
```

and set the parallel option to `on`

```
[mem]=minCEntropy_modified_Newer_Version(X,K,sigma_factor=1,n_run=10,parallel="on",verbose=true);
```


To check the effect of parallisation, the running time with parallel options of `on` and `off` are compared in the table below. Setting the option to `on` allows speed-ups of 2 times relative to the option `off`. 


 |  Parallel option     | Time   | Speed-up | 
 | ------------------   | ----   | -------- | 
 |       off                  | 2617.392 s       | 1x |
 |       on                   | 1421.474 s       |  2x  |
  


If you have a version of MATLAB older than 2021a, refer to the **demo execution** details below.


## Demo execution

Run the following demo to see the result of image segmentation on peppers.png image:

```
demo_modified_minCEntropy.m
```

The demo performs minCEntropy clustering to partition the observations of the n*p data matrix X into K clusters and returns an n-by-1 vector (mem) containing cluster indices of each observation. Rows are the number of objects and cols the number of features.
Based on the version of MATLAB this demo calls one of two functions demo_minCEntropy_modified_Older_Version.m (for MATLAB versions older than R2021a) or demo_minCEntropy_modified_Newer_Version.m (for MATLAB versions newer than R2021a).

## Users of MATLAB older than R2020b

If your MATLAB version is older than R2020b, replace the following lines. 

```
version_year=isMATLABReleaseOlderThan("R2021a");`
if version_year==1
```

with

```
release=['Release R' version('-release')];
release = split(release);
version = regexp(release{2,1},'\d*','Match');
version_year=str2num(version{1,1});
if version_year<2021
```

To run the code on your data, replace X in demo_minCEntropy_modified.m with your data. To run the code on a different image, replace peppers.png with your image.

Lines 28-40 in demo_modified_minCEntropy.m display the original image and the segmented image and are not needed for the data other than images and should be commented for other types of data. 

K is the number of desired clusters. n_run and sigma_factor in demo_minCEntropy_modified_Newer_Version and demo_minCEntropy_modified_Older_Version are the other hyperparameters. 

The demo code has been tested on three versions of MATLAB, R2021a, R2020b and R2018a and the outputs were

R2021a:

```
Starting parallel pool (parpool) ...
Connected to the parallel pool (number of workers: 6).
Initialising using MATLABkmeans
Parallel mode is  on
Sigma factor: 1, changes: 7198, quality: 178360.728659
>>>>>>>>Finished clustering. best quality: 178360.728659
```

6 in (number of workers: 6) changes based on the machine on which we are running the code.


R2020b:

```
Sigma factor: 1, changes: 7198, quality: 178360.728659
>>>>>>>>Finished clustering. best quality: 178360.728659
```

R2018a:
```
Sigma factor: 1, changes: 7388, quality: 178360.716154
>>>>>>>>Finished clustering. best quality: 178360.716154
IdleTimeout has been reached.
Parallel pool using the 'local' profile is shutting down.
```

## References

* Xuan Vinh Nguyen (2022). The minCEntropy algorithm for alternative clustering (https://www.mathworks.com/matlabcentral/fileexchange/32994-the-mincentropy-algorithm-for-alternative-clustering), MATLAB Central File Exchange. Retrieved March 7, 2022.


