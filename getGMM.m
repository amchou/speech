function gmm = getGMM( X, max_iter, epsilon, M, name)
% called by gmmTrain to get each gmm
% outputs the gmm struct corresponding to ONE speaker, with given T-by-d X matrix from mfcc files
% gmm struct will go into the cell array gmms, which is the output of gmmTrain

	% initialize model parameters
	gmm = struct;
	gmm.name = name;
	[T d] = size(X);
	gmm.weights(1:M) = 1/M;		% 1-by-M
	%gmm.means = X(1:M,:)'
	gmm.means = zeros(d,M);
	for m=1:M	
		gmm.means(:,m) = X(ceil(rand*T),:);
	end
  gmm.cov = repmat(eye(d),[1 1 M]);

	% EM iterations
	i = 0;
	prevL = -Inf;
	imprv = Inf;
	while (i < max_iter) && (imprv >= epsilon)
		[logL gmm] = updateGMM(gmm,X,T,d,M,1);	% 'optional arg '1':update parameters
		imprv = logL - prevL;
		prevL = logL;
		i = i+1;
	end

end

