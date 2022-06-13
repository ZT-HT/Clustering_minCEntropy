# Modified minCEntropy clustering: partitional clustering using a minimum conditional entropy objective for image segmentation

Please cite the reference below when using this software:

Tirandaz Z, Croucher M. Modified minCEntropy clustering: partitional clustering using a minimum conditional entropy objective for image segmentation. Submitted, 2022

This repository contains the software used in the paper entitled "Efficient quantization of images of paintings by relevant colors" (publication in preparation).  It uses a modified version of the minCEntropy algorithm developed by Nguyen Xuan Vinh and Julien Epps (2010) to perform image segmentation.  The primary difference between this implementation of minCEntropy and the original is that this version is faster and more suited to larger data sets. 

Here is a demonstration of its use for segmenting the MATLAB image `peppers.png` into 12 clusters. Parameter K is the number of desired clusters and n_run and sigma_factor are the other hyperparameters. 

```
clc;clear;close all;

image=imread('peppers.png');

K=12; % Number of clusters
image=double(image);

[rows, columns, dim]=size(image);
X=reshape(image,[rows*columns dim]);

   
mem=minCEntropy(X,K,sigma_factor=1,n_run=10,parallel="off",verbose=true);  % run minCEntropy+ 10 times


X=reshape(X,[rows columns dim]);

subplot(1,2,1); imshow(uint8(X))
title('image')

mem1=reshape(mem,[rows columns]);

if dim==3
segmented_image =  color_assignment(X,mem1);
else
segmented_image =  grayscale_assignment(X,mem1);
end

subplot(1,2,2); imshow(uint8(segmented_image))
title('segmented image')

```

The output while running the code is as follows.

```
Initialising using MATLABkmeans
Parallel mode is  off
Sigma factor: 1, changes: 12866, quality: 178360.057143
>>>>>>>>Finished clustering. best quality: 178360.057143

```

![](https://github.com/ZT-HT/Clustering_minCEntropy/blob/main/segmented.bmp)



This example will take quite a long time to run (e.g. 2617 s seconds on a Intel(R) Core(TM) i7-10710U CPU @ 1.10GHz 1.61 GHz). See the **parallel execution** section for details on how to make it faster.

## Parallel execution 

If you have access to the [Parallel Computing Toolbox](https://www.mathworks.com/products/parallel-computing.html), you can switch parallelization on, which can result in significant improvements in speed. Thus, create a parallel pool:

```
parpool('threads')
```

and set the parallel option to `on`

```
[mem]=minCEntropy(X,K,sigma_factor=1,n_run=10,parallel="on",verbose=true);
```


To check the effect of parallization, the running time with parallel options of `off` and `on` are compared in the table below. Setting the option to `on` halves the execution time. 


 |  Parallel option     | Time   | Speed-up | 
 | ------------------   | ----   | -------- | 
 |       off                  | 2617.392 s       | 1x |
 |       on                   | 1421.474 s       |  2x  |
  


If you have a version of MATLAB newer than 2021a, refer to the following **demo execution**.


## Demo execution

Run this demonstration to see the result of image segmentation with the peppers.png image:

```
minCEntropyClustering.m
```

The demonstration performs minCEntropy clustering to partition the observations of the n*p data matrix X into K clusters and returns an n-by-1 vector (mem) containing cluster indices of each observation. Rows are the number of objects and columns the number of clusters.


## Users of MATLAB older than R2021a

If your MATLAB version is older than R2021a, refer to the `Old MATALB version` folder  and run the following demonstration to see the result of image segmentation with the peppers.png image:

```
minCEntropyClusteringOld.m
```


To run the code on a different image, substitute it for peppers.png. To run the code on other types of data, replace X in minCEntropyClustering.m (in the current folder) and minCEntropyClusteringOld.m (in `Old MATALB version` folder) with your data. 

lines 18-32 in minCEntropyClustering.m (in the current folder) and Lines 20-34 in minCEntropyClusteringOld.m (in `Old MATALB version` folder) display the original image and the segmented image and may be commented out if unnecessary. 

The demo code has been tested on three versions of MATLAB, R2021a, R2020b and R2018a with outputs as follows.

R2021a:

```
Starting parallel pool (parpool) ...
Connected to the parallel pool (number of workers: 6).
Initialising using MATLABkmeans
Parallel mode is  on
Sigma factor: 1, changes: 7198, quality: 178360.728659
>>>>>>>>Finished clustering. best quality: 178360.728659
```

"(number of workers: 6)" refers to the machine running the code.


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

* Nguyen Xuan Vinh (2022). The minCEntropy algorithm for alternative clustering (https://www.mathworks.com/matlabcentral/fileexchange/32994-the-mincentropy-algorithm-for-alternative-clustering), MATLAB Central File Exchange. Retrieved March 7, 2022.
* Nguyen Xuan Vinh, Julien Epps (2010). minCEntropy: a Novel Information Theoretic Approach for the Generation of Alternative Clusterings, the 10th IEEE Int. Conf. on Data Mining (ICDM'10).


