function gmms = gmmTrain( dir_train, max_iter, epsilon, M, varargin )
% gmmTain
%
%  inputs:  dir_train  : a string pointing to the high-level
%                        directory containing each speaker directory: /u/cs401/speechdata/Training
%           max_iter   : maximum number of training iterations (integer)
%           epsilon    : minimum improvement for iteration (float)
%           M          : number of Gaussians/mixture (integer); we will start with 8
%
%  output:  gmms       : a 1xN cell array. The i^th element is a structure
%                        with this structure:
%                            gmm.name    : string - the name of the speaker
%                            gmm.weights : 1xM vector of GMM weights
%                            gmm.means   : DxM matrix of means (each column 
%                                          is a vector
%                            gmm.cov     : DxDxM matrix of covariances. 
%                                          (:,:,i) is for i^th mixture

	% get speaker directories
	spk_dirs = regexp(genpath(dir_train),['[^:]*'],'match');	% cell array
	spk_dirs = spk_dirs(2:end);	% remove given directory
	gmms = {};

	% get X, matrix of all available mfcc data for each speaker at iDir
	for iDir=1:length(spk_dirs)                                                  
		mfccs = dir([ spk_dirs{iDir}, filesep, '*', 'mfcc']);
		X = [];

			% go through all mfcc files for the speaker
			for iFile=1:length(mfccs)																								 
				mfcc = load([spk_dirs{iDir}, filesep, mfccs(iFile).name]);
				X = vertcat(X,mfcc);
			end
			%%%%%%%%%%%%%%%%%%% if d_p given, use PCA to reduce X to dimension d_p
			if length(varargin)==1 
				d_p = varargin{1};
				X = pca(X,d_p{1});
			end
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
		% folder name is speaker name
		name = regexp(spk_dirs{iDir},'(?<=/)([^/]*?$)','match');

		% get gmm for the speaker and append to gmms cell array of structs
		gmms{1,iDir} = getGMM(X, max_iter, epsilon, M, name{1});
		
	end
  save('gmms.mat','gmms');

end % end function




