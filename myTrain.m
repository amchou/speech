%{
myTrain (script)

	initialize and train continuous HMM models for each phoneme in data
	each model is trained on all data of a specific phoneme across all speakers
	(i.e. models are speaker-independent)

%}

dir_train = '/u/cs401/speechdata/Training';

% First, create a struct of cell arrays: data.phn = {i}(d,n) where each field  will serve as 'data' input for initHMM
% NOTE: must convert h# to 'hsh' such that it can act as a fieldname variable
data = struct;

% get list of folders in training directory (go through all speakers)
spk_dirs = regexp(genpath(dir_train),['[^:]*'],'match');	% cell array
spk_dirs = spk_dirs(2:end);	% remove given directory

% go through all folders
for iDir=1:length(spk_dirs) 
	phns = dir([ spk_dirs{iDir}, filesep, '*', 'phn']);
		
		% go through all phn files in the folder
		for iFile=1:length(phns)
			[junk1,filename,junk2] = fileparts(phns(iFile).name); %[pathstr,name,ext], to make sure .mfcc file is exact match to .phn file
			plines = textread([spk_dirs{iDir}, filesep, phns(iFile).name], '%s','delimiter','\n');
			mfcc = load([spk_dirs{iDir}, filesep, strcat(filename,'.mfcc')]);

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
				e_ind = e_ind/128 +1 ;

				% get lines from corresponding mfcc file
				temp_data = mfcc(s_ind:min(e_ind,size(mfcc,1)),:)'; %change dimensionality d' here

				if ~isfield(data,(phn))
					data.(phn){1} = temp_data;
				else
					data.(phn){end+1} = temp_data;
				end	

			end

		end
end

% Now that all data is collected, initialize an HMM model for each phoneme
hmm = struct;
ll = struct;
phonemes = fieldnames(data);

% initialize and train HMMs for all phonemes
for i=1:length(phonemes)
	phn = phonemes{i};
	hmm.(phn) = initHMM(data.(phn));
	[hmm.(phn), ll.(phn)] = trainHMM(hmm.(phn), data.(phn));
end

save('hmmDefault.mat','hmm');
save('llDefault.mat','ll');









