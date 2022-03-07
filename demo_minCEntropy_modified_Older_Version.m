function [mem]=demo_minCEntropy_modified(X,K)

sigma_factor=1;
n_run=10;

[mem]=minCEntropy_modified(X,K,sigma_factor,n_run);  %% run minCEntropy+ 10 times,

end





