function [logL gmm] = updateGMM ( gmm, X, T, d, M, varargin)
% updates L and theta in the gmmTrain algorithm
% first get likelihood L from X,theta
% then get new theta from theta,X,L

	% FIRST, COMPUTE LIKELIHOODS
	% compute b_m (Txm matrix)
  b = zeros(T,M);
  mutrans = gmm.means'; % Mxd
  for m=1:M
			covd    = diag(gmm.cov(:,:,m));
			b_num   = (X-repmat(mutrans(m,:),T,1)).^2;
			b_num   = b_num./repmat(covd',T,1);	
			b_num   = sum(b_num,2);
			b_num   = exp(-0.5*b_num);
			b_den   = (2*pi)^(d/2) * (prod(covd))^(1/2);
			b_den   = repmat(b_den,T,1);                   			
      b(:,m)  = b_num./b_den;
  end

	% Tx1 col. vector
	% px_t = probability of x_t in the entire GMM (denominator) = p_gamma(x_t)
  omega = repmat(gmm.weights,T,1); %TxM matrix of weights, repeated
	p_num = omega.*b;
	px_t  = sum(p_num,2);
	% the scalar logL we want to maximize
	logL = sum(log(px_t));

	% update parameters if indicated (called from gmmTrain via getGMM, we want to update
	% called from gmmClassify, only want to compute logL based on already-trained GMM)
	if length(varargin) == 1
		% TxM, each row should sum to 1
		%compute L = P(gamma_m|x_t,theta), P(mth mix|vector x_t)
		p_m = p_num./repmat(px_t,1,M);
		% sum up columns to get 1xM row vector
		p_mm = sum(p_m);
		gmm.weights = p_mm./T;

		mu    = zeros(d,M);
		sigma = repmat(zeros(d),[1 1 M]);
		for m=1:M
		    mu(:,m) = (sum(repmat(p_m(:,m),1,d).*X)./p_mm(m))';
		    sigma(:,:,m) = diag(  (sum( (repmat(p_m(:,m),1,d).*(X.^2)) )./p_mm(m))' - (mu(:,m)).^2  );
		end 
		gmm.means = mu;
		gmm.cov = sigma;
	end
end
