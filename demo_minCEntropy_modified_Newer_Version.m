function [mem]=demo_minCEntropy_modified_Newer_Version(X,K)

delete(gcp('nocreate'))

parpool('threads'); % For parallel


[mem]=minCEntropy_modified_Newer_Version(X,K,sigma_factor=1,n_run=10,parallel="on",verbose=true);  %% run minCEntropy+ 10 times,

end

