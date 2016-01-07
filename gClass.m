function [M epsilon max_iter correct correct5] = gClass(M,epsilon,max_iter,varargin);
% gmmClassify, modified for testing

% uses gmmTrain.m to report the top 5 most likely speakers & corresponding log-likelihoods
% for each test utterance N in Testing data

%%%% train %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dir_train = '/u/cs401/speechdata/Training';
%max_iter = 100;
%epsilon = 1000;
%M = 2;
if length(varargin) == 1
	d_p = varargin{1};
	gmms = gmmTrain(dir_train,max_iter,epsilon,M, d_p);
else 
	gmms = gmmTrain(dir_train,max_iter,epsilon,M);
end

%%%% test  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dir_test = '/u/cs401/speechdata/Testing';
mfccs = dir([ dir_test, filesep, '*', 'mfcc']);
top = 5;

ref = {'MMRP0','MPGH0','MKLW0','FSAH0','FVFB0','FJSP0','MTPF0','MRDD0','MRSO0','MKLS0','FETB0','FMEM0','FCJF0','MWAR0','MTJS0'};

correct = 0;
correct5 = 0;

% for each test file, generate likelihood for all 30 speakers and store top 5 result in file
for iDir=1:length(mfccs)	
	% get mfcc data, X, from the test file
	X = load([dir_test, filesep, 'unkn_',num2str(iDir),'.mfcc']);
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PCA %%%%%%%%%%%%%%%%%%%%
	if length(varargin) == 1
		d_p = varargin{1};
		%d_p = d_p{1};
		X = pca(X,d_p);
	end
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	[T d] = size(X);

	% for every speaker, get log-likelihood (use pieces of code from gmmTrain)
	result = [];
	for s=1:length(gmms)
		[logL junk] = updateGMM ( gmms{1,s}, X, T, d, M );	% not updating, just get logL
		result = vertcat(result,[s logL]);	% keep both columns as num to sort
	end

	% get top (5) results, format and write to file
	result = flipud(sortrows(result,2));			  	% sort by logL, descending
	result = horzcat([1:top]',result(1:top,:));		% get top 5, add indices
	iFile = strcat('unkn_',num2str(iDir),'.lik'); % write to file corresponding to utterance
	fileID = fopen(iFile, 'w');
	fprintf(fileID,'%4s %10s %8s\n','Num','Speaker','Log-Lik');
	for r=1:length(result)
		name = gmms{1,result(r,2)}.name;
		fprintf(fileID,'%4u %10s %8.2f\n',result(r,1),name,result(r,3));
		% check accuracies
		if iDir<16		% only given ref for first 15
			if strcmp(name,ref(iDir))	% if identified name matches reference list
				correct5 = correct5+1;	% if within top 5
				if r == 1 							% if actually top
					correct = correct + 1;
				end
			end
		end
	end
	fclose(fileID);

end
%	output vector of input parameters and corresponding accuracies
printthis = [M epsilon max_iter correct correct5]
