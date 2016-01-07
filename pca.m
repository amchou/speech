function [pca] = pca(X,d_p);
%converts mfcc matrix, X, into a lower dimension (d', or d_p) matrix using PCA

%first, subtract means to centre the data
[T d] = size(X);
means = mean(X); %row of column means (mean for each dimension in d)
means = repmat(means,T,1);
cX = X-means;

%get covariance matrix
covar = cov(X);
[V,D] = eig(covar);		% D=diag of eigenvals, V= full, cols are eigenvecs X*V=V*D
[val ind] = sortrows(diag(D));
D = flipud(ind);
D = D(1:d_p);					% only keep top d_p dimensions by using largest eigenvalues (accounting for most of variance)

%now get corresponding eigenvectors
featVec = [];
for d=1:length(D) %=d_p
	featVec = horzcat(featVec,V(:,D(d)));
end

%reduced dimensionality data = row feature vector * row centered data, transposed
pca = (featVec'*cX')';
