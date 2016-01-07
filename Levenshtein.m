function [SE IE DE LEV_DIST] =Levenshtein(hypothesis,annotation_dir)
% Input:
%	hypothesis: The path to file containing the the recognition hypotheses
%	annotation_dir: The path to directory containing the annotations
%			(Ex. the Testing dir containing all the *.txt files)
% Outputs:
%	SE: proportion of substitution errors over all the hypotheses
%	IE: proportion of insertion errors over all the hypotheses
%	DE: proportion of deletion errors over all the hypotheses
%	LEV_DIST: proportion of overall error in all hypotheses

% NOTE: this Levenshtein distance computation first prunes non-word punctuation (! ? , .)
% since this is for speech recognition we only check for word correctness
% also assumes given hyptheses and annotation sentences use proper grammar (will have spaces after commas, for example);  quotation marks are ignored

	addpath(genpath('/u/cs401/A2_SMT/code'));	%use strsplit from A2_SMT

	%for all lines in hypothesis
	hyplines = textread(hypothesis,'%s','delimiter','\n');
	[refsum, SE, IE, DE] = deal(0);

	for i=1:length(hyplines)
		hyp = preLev(hyplines{i});
		refline = textread([annotation_dir, filesep, 'unkn_', num2str(i),'.txt'],'%s','delimiter','\n');
		ref = preLev(refline{1});

		refsum = refsum + length(ref);	%divide by ref sentence length to get proportions
		R(length(ref)+1,length(hyp)+1) = 0;
		R(1,:) = Inf;
		R(:,1) = Inf;
		R(1,1) = 0;

		for j=2:length(ref)+1
			for k=2:length(hyp)+1
				if strcmp(ref(j-1),hyp(k-1)) % if words match
					R(j,k) = min([R(j-1,k)+1,R(j-1,k-1),R(j,k-1)+1]);	%del/match/ins
				else												  % if words differ
					R(j,k) = min([R(j-1,k)+1,R(j-1,k-1)+1,R(j,k-1)+1]);	%del/sub/ins
				end
			end
		end

		%backtrace to get a minpath and calculate sub/del/ins:
		%since an optimal/min path is composed of optimal subpaths, simply check neighbours
		[j k] = deal(length(ref)+1, length(hyp)+1);
		while j~=1 | k~=1	% while not back at start cell
				mincell = min([R(j-1,k-1),R(j-1,k),R(j,k-1)]);
				switch mincell
					% substitution if not match
					case R(j-1,k-1)
						if ~strcmp(ref(j-1),hyp(k-1))
							SE = SE + 1;
						end
						[j k] = deal(j-1, k-1);
					% insertion
					case R(j,k-1)	
						[IE k] = deal(IE+1,k-1);
					% deletion
					case R(j-1,k)
						[DE j] = deal(DE+1,j-1);
				end
		end
		R=[];
									
	end
	SE = SE/refsum;
	IE = IE/refsum;
	DE = DE/refsum;
	LEV_DIST = SE+IE+DE;

end

% used for prepping both hyp and ref sentences for WER/distance analysis
function [words] = preLev(sent)
	sent = regexprep(sent,'([^ ]*) ([^ ]*) (.*)','$3');	%remove numbers
	sent = regexprep(sent,',|!|?|\.','');               %remove select punctuation (this isn't robust)
	words = strsplit(' ',sent);                         % split into words
end


