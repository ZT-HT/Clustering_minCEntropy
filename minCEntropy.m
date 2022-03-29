function [mem]=minCEntropy(a,K,options)

% minCEntropy clustering: partitional clustering using the minimum conditional Entropy objective
% Modified by Zeinab Tirandaz with some contributions by Mike Croucher, 2021
%Original: (C) Nguyen Xuan Vinh, 2010. Contact:  vinh.nguyenx@gmail.com, vinh.nguyen@monash.edu
%Input required arguments:
%   a: data, rows for objects, cols for features
%   K: number of desired clusters
% Optional arguments
%   sigma_factor: default kernel with sigma_0, specify sigma_factor to obtain
%               a new kernel width,  sigma=sigma_0/sigma_factor. Default: 1
%   n_run: optional, number of runs, default: 1
%   SS: A provided kernel matrix.  If one is not provided, it will be computed.
%   init: Cluster initialisations.
%   verbose: Gives additional output
%Output:
%   max_mem: best clustering over n_run runs
%   max_obj: max objective value
%   S: kernel similarity matrix
%Reference:
%   [1] N. X. Vinh, Epps, J., "minCEntropy: a Novel Information Theoretic Approach for the Generation of
%       Alternative Clusterings,"  in IEEE Int. Conf. on Data Mining (ICDM) 2010.
%Example:
%
% X = [randn(100,2)+5;randn(100,2)+[5*ones(100,1) -5*ones(100,1)];  randn(100,2)-5;randn(100,2)+[-5*ones(100,1) 5*ones(100,1)]];
% [mem]=minCEntropy(X,2,1,10);  %% run minCEntropy+ 10 times,
%                               %% with K=2, sigma=sigma_0
% figure;scatter(X(:,1),X(:,2),30,mem);title('minCEntropy clustering');
arguments
   a (:,:)
   K (1,1)
   options.sigma_factor (1,1) = 1
   options.n_run (1,1) = 1
   options.SS (:,:) = []
   options.init (1,1) string = "MATLABkmeans"
   options.verbose (1,1) logical = false
   options.parallel (1,1) string {mustBeMember(options.parallel,["on","off"])} = "off"
 end

if options.verbose 
    fprintf("Initialising using "+ options.init + "\n")
    fprintf("Parallel mode is  "+ options.parallel + "\n")
end

%Handle parallelisation options
num_workers = 0;     % serial mode
if options.parallel == "on"
   num_workers = inf;   %Will use the maxium number of workers defined in the parpool
end

sigma_factor = options.sigma_factor;
n_run = options.n_run;

[n, dim]=size(a);


if isempty(options.SS)
    if dim>1
        for i=1:dim
         A=a;A=A';
         A(i,:)=bsxfun(@minus,A(i,:),mean(A(i,:),2));
         SSS = full(sum((A.^2),1));
        end
    else
    A=a;A=A';
    A = bsxfun(@minus,A,mean(A,2));
    SSS = full(sum((A.^2),1));
    end
    
    sum_sqrt_SE=0;
    parfor(iii=1:n,num_workers)
        dd=(-2)*(((A'*A(:,iii)))');
        SSS1=dd+SSS;
        Se1=SSS1+SSS(iii);
        sum_sqrt_SE=(sum(sqrt(Se1)))+sum_sqrt_SE;
    end  
    
    sigma0=(sum_sqrt_SE)/n^2/2; %1/2 average pairwise distance
    sigma0=real(sigma0);
    sigma=sigma0/sigma_factor;
    sig2=4*sigma^2;
    
else
    S=options.SS; %preprovided kernel matrix
end
G=zeros(1,K);              %cluster quality
Nj=zeros(1,K);             %cluster size

I=a;
%initialization 

%MATLAB's k-means
warning('off','stats:kmeans:FailedToConverge');       % We know it's not going to converge and don't care. This is just an initial seeding
mem=kmeans(I,K,'Maxiter',10000,'EmptyAction','singleton','Replicates',n_run);   % Best clustering among n_run
warning('on','stats:kmeans:FailedToConverge');


[Spc0] = setup(mem,A,n,K,SSS,sig2,num_workers); %point->cluster similarity


%% main loop
[max_mem,max_obj] = main_loop(Spc0,Nj,G,n,K,A,SSS,sig2,sigma_factor,mem);  

fprintf('>>>>>>>>Finished clustering. best quality: %f\n',max_obj);

end%main function

function [Spc] = setup(mem,A,n,K,SSS,sig2,num_workers)
Spc=zeros(n,K);            %point->cluster similarity
parfor(i=1:n,num_workers)
    dd=(-2)*(((A'*A(:,i)))');
    for j=1:K
        SSS1=dd+SSS+SSS(i);
        Ss1=SSS1(mem==j);
        Ss=exp(-Ss1/sig2);
        Spc(i,j)=sum(Ss);  % point -> cluster similarity
    end
end
end

function [mem,obj] = main_loop(Spc0,Nj,G,n,K,A,SSS,sig2,sigma_factor,mem)
change_count=0;


Spc = Spc0;

for j=1:K
    G(j)=sum(Spc(mem==j,j));
    Nj(j)=sum(mem==j);
end
obj=sum(G./Nj);

isContinue=1;
while isContinue
    isContinue=0;
    for i=1:n
        cur_clus=mem(i);
        %check point->cluster similarity
        max_inc=-inf; % maximum objective increase
        for new_clus=1:K
            if new_clus==cur_clus continue;end;
            cond2=G(cur_clus)/(Nj(cur_clus)-1)/Nj(cur_clus)-G(new_clus)/(Nj(new_clus)+1)/Nj(new_clus)-2*Spc(i,cur_clus)/(Nj(cur_clus)-1)+2*Spc(i,new_clus)/(Nj(new_clus)+1);
            if cond2>max_inc
                max_inc=cond2;
                max_clus=new_clus;
            end
        end
        
        if(max_inc>0) %make change
            new_clus=max_clus;
            change_count=change_count+1;
            isContinue=isContinue+1;
            
            %update tables
            A22 = A'*A(:,i);
            SE = -2*A22 + SSS(i) + SSS';
            SS = exp(-SE./sig2);
            
            %% The following vectorised method appears to be faster
            Spc(:,cur_clus) = Spc(:,cur_clus) - SS;
            Spc(:,new_clus) = Spc(:,new_clus) + SS;
            % Change the entry for i back to how it was since the original
            % loop skipped it
            Spc(i,cur_clus) = Spc(i,cur_clus) + SS(i);
            Spc(i,new_clus) = Spc(i,new_clus) - SS(i);
            
            G(cur_clus)=G(cur_clus)-2*Spc(i,cur_clus);
            G(new_clus)=G(new_clus)+2*Spc(i,new_clus);
            
            %update membership
            mem(i)=new_clus;
            Nj(cur_clus)=Nj(cur_clus)-1;
            Nj(new_clus)=Nj(new_clus)+1;
            change_count=change_count+1;
        end %make change
    end%for i=1:n  one round through the data set
    
end%while point can still move

obj=sum(G./Nj);
fprintf('Sigma factor: %d, changes: %d, quality: %f\n',sigma_factor,change_count,obj);

end

