%{
myRun: collects all phoneme sequences from the test data, given respective *.phn files
-find log-likelihood of each phoneme seq in the test data given each HMM phoneme model using loglikHMM

%}

dir_test = '/u/cs401/speechdata/Testing';
testdata = struct;

%% First, get all test data into a struct, testdata.phn where each field 'phn' is a phoneme
% go through all files

phns = dir([ dir_test, filesep, '*', 'phn']);
		
		% go through all phn files in the folder
		for iFile=1:length(phns)
			[junk1,filename,junk2] = fileparts(phns(iFile).name); %[pathstr,name,ext], to make sure .mfcc file is exact match to .phn file
			plines = textread([dir_test, filesep, phns(iFile).name], '%s','delimiter','\n');
			mfcc = load([dir_test, filesep, strcat(filename,'.mfcc')]);

			% for every line in phn file, get matching mfcc data on the sequence and store in data.phn
			for i=1:length(plines)
				plinestr = plines{i};
				[s_ind e_ind phn] = strread(plinestr,'%d %d %s');
				phn = phn{1};

				% 'h#' cannot be fieldname, so fix if this is our phoneme here
				if strcmp(phn,'h#') == 1
					phn = 'hsh';
				end
				
				% adjust indices
				s_ind = s_ind/128 + 1;
				e_ind = e_ind/128 + 1;

				% get lines from corresponding mfcc file
				temp_data = mfcc(s_ind:min(e_ind,size(mfcc,1)),:)';				%change d' here

				if ~isfield(testdata,(phn))
					testdata.(phn){1} = temp_data;
				else
					testdata.(phn){end+1} = temp_data;
				end	
			end
		end

load('hmmDefault');		%load model created by myTrain.m

%% Now, for each phoneme sequence, get LL from ALL HMM models (want to see if most likely model matches the test phoneme)
phonemes = fieldnames(testdata);
hphones = fieldnames(hmm);
correct = 0;
tot = 0;

% go through all phonemes
for i=1:length(phonemes)
	phn = phonemes{i};
	numseq = length(testdata.(phn));
	tot = tot + numseq;

	% for every sequence in the phoneme get array of LL's
	for j=1:numseq
		LL = [];
		% get LL from each HMM model
		for k=1:length(hphones)
			hph = hphones{k};
			LL(k) = loglikHMM (hmm.(hph), testdata.(phn){j});
		end
		[val ind] = max(LL);
		if strcmp(hphones{ind},phn)
			correct = correct + 1;
		end
	end
end

% print final accuracy
accuracy = correct/tot



