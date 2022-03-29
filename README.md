# Modified minCEntropy clustering: partitional clustering using the minimum conditional Entropy objective for image segmentation

This repository contains the software used in the paper entitled "Efficient human estimates of relevant colors of paintings" (Publication in progress).  It uses a modified version of the minCEntropy algorithm developed by Xuan Vinh Nguyen [2010] to perform image segmentation.  The primary difference between this implementation of minCEntropy and the original is that this version is faster and more suited to larger data sets. 

Here is a demonstration of its use for segmenting the image `peppers.png` (which is built into MATLAB) using 12 clusters

```
clc;clear;close all;

image=imread('peppers.png');

K=12; % Number of clusters
image=double(image);

[rows, columns,dim]=size(image);
X=reshape(image,[rows*columns dim]);

   
mem=minCEntropy(X,K,sigma_factor=1,n_run=10,parallel="off",verbose=true);  % run minCEntropy+ 10 times


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
[mem]=minCEntropy(X,K,sigma_factor=1,n_run=10,parallel="on",verbose=true);
```


To check the effect of parallisation, the running time with parallel options of `on` and `off` are compared in the table below. Setting the option to `on` allows speed-ups of 2 times relative to the option `off`. 


 |  Parallel option     | Time   | Speed-up | 
 | ------------------   | ----   | -------- | 
 |       off                  | 2617.392 s       | 1x |
 |       on                   | 1421.474 s       |  2x  |
  


If you have a version of MATLAB newer than 2021a, refer to the **demo execution** details below.


## Demo execution

Run the following demo to see the result of image segmentation on peppers.png image:

```
minCEntropyClustering.m
```

The demo performs minCEntropy clustering to partition the observations of the n*p data matrix X into K clusters and returns an n-by-1 vector (mem) containing cluster indices of each observation. Rows are the number of objects and cols the number of features.


## Users of MATLAB older than R2021a

If your MATLAB version is older than R2021a, run the following demo in [Old MATLAB version](https://github.com/ZT-HT/Clustering_minCEntropy/tree/main/Old%20MATLAB%20version) to see the result of image segmentation on peppers.png image:

```
minCEntropyClusteringOld.m
```


To run the code on a different image, replace peppers.png with your image. To run the code on any other type of data, replace X in demo_minCEntropy_modified.m with your data. 

Lines 17-31 in minCEntropyClustering.m display the original image and the segmented image and are not needed for the data other than images and should be commented for other types of data. 

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


