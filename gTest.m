%script to test M/epsilon/d_p for gmmClassify.m

%specify input data: [M epsilon max_iter d_p]
%test = [2 3 100 10; 4 10 100 10; 4 20 100 10; 5 10 100 10; 5 20 100 10; 8 50 10 10;8 50 100 10];
%test = [1 20 100; 1 50 100; 8 100 100; 8 200 100; 8 500 100; 5 100 100;10 500 100];
%test = [1 500 100; 1 1000 100; 2 500 100; 2 1000 100; 8 2000 100; 8 1000 100;5 1000 100];

test = [20 1000 1000;10 1000 1000;2 1000 1000];
[r c] = size(test);

for i=1:r
	%gClass(M,epsilon,max_iter, d_p(optional))
	 [M epsilon max_iter correct correct5] = gClass(test(i,1),test(i,2),test(i,3));	% note 4th arg can be omitted if not using PCA
end

