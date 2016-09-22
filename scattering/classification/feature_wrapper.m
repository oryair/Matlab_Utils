% feature_wrapper: Wrapper for feature functions.
% Usage
%    feature = feature_wrapper(x, objects, feature_fun, input_sz, ...
%       output_sz, obj_normalize, collapse)
% Input
%    x: The file data.
%    object: The objects contained in the data.
%    feature_fun: The real feature function handle, takes as input one signal
%       (or multiple, arranged as columns of a matrix) and outputs the cor-
%       responding feature vectors. These are arranged with feature dimension
%       along the first axis and time/space along second axis and signal
%       index along the third axis (if more than one signal are input).
%    input_sz: The size of the input vectors to be given to feature_fun. If
%       empty, takes the rectangle specified by the objects structure, other-
%       wise takes the rectangle of size input_sz centered on the object (de-
%       fault empty).
%    output_sz: The desired size of the data covered by the feature vector. If
%       empty, keeps the output from feature_fun, otherwise extracts the 
%       time/space rectangle of size output_sz centered on the original data, 
%       taking into account any subsampling by feature_fun (default empty).
%    obj_normalize: The normalization of the input vectors before being 
%       given to feature_fun. Can be empty, 1, 2, or Inf (default Inf).
%    collapse: If true, collapses the time/space dimension into one vector,
%       otherwise leaves this dimension intact (default false).
% Output
%    duration: The log-duration of the objects.

function t = feature_wrapper(x,objects,fun,input_sz,output_sz, ...
	obj_normalize,collapse)
	if nargin < 4
		input_sz = [];
	end
	
	if nargin < 5
		output_sz = [];
	end
	
	if nargin < 6
		obj_normalize = Inf;
	end
	
	if nargin < 7
		collapse = 0;
	end
	
	if isempty(input_sz)
		buf = zeros(objects(1).u2-objects(1).u1+ones(size(objects(1).u1)), ...
			length(objects));
		
		u1 = [objects.u1];
		u2 = [objects.u2];
	else
		buf = zeros(input_sz,length(objects));

		u1 = round(([objects.u1]+[objects.u2]+1)/2-input_sz/2);
		u2 = u1+input_sz-1;
	end

	for l = 1:length(objects)
		ind = max(u1(l),1):min(u2(l),length(x));

		buf(:,l) = [zeros(max(0,1-u1(l)),1); x(ind); zeros(max(0,u2(l)-length(x)),1)];
	end
	
	if ~isempty(obj_normalize)
		if obj_normalize == 1
			n = sum(abs(buf),1);
		elseif obj_normalize == 2
			n = sqrt(sum(abs(buf).^2,1));
		elseif obj_normalize == Inf
			n = max(abs(buf),[],1);
		end
		
		buf = bsxfun(@times,buf,1./n);
	end

	t = fun(buf);

	if ~isempty(output_sz)
		N = size(t,2);
		extent = floor(output_sz/(2*input_sz)*N);
		
		t = t(:,N/2+1-extent:N/2+1+extent,:);
	end
	
	if collapse
		t = reshape(t,[size(t,1)*size(t,2) 1 size(t,3)]);
	end
end
