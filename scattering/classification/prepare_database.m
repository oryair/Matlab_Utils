% prepare_database: Calculates the features from objects in a source.
% Usage
%    database = prepare_database(src, feature_fun, options)
% Input
%    src: The source specifying the objects.
%    feature_fun: The feature functions applied to each object.
%    options: Options for calculating the features. options.feature_sampling
%       specifies how to sample the feature vectors in time/space.
% Output
%    database: The database of feature vectors.

function db = prepare_database(src,feature_fun,opt)
	if nargin < 3
		opt = struct();
	end
	
	opt = fill_struct(opt,'feature_sampling',1);
	opt = fill_struct(opt,'file_normalize',[]);
	
	features = cell(1,length(src.files));
	obj_ind = cell(1,length(src.files));
	
	rows = 0;
	cols = 0;
	precision = 'double';
	
	parfor k = 1:length(src.files)
		file_objects = find([src.objects.ind]==k);
		
		if length(file_objects) == 0
			continue;
		end
		
		tm0 = tic;
		x = data_read(src.files{k});
		
		if isempty(opt.file_normalize)
			if opt.file_normalize == 1
				x = x/sum(abs(x(:)));
			elseif opt.file_normalize == 2
				x = x/sqrt(sum(abs(x(:)).^2));
			elseif opt.file_normalize == Inf
				x = x/max(abs(x(:)));
			end
		end
		
		features{k} = cell(1,length(file_objects));
		obj_ind{k} = file_objects;
		
		buf = apply_features(x,src.objects(file_objects),feature_fun,opt);
		
		for l = 1:length(file_objects)
			features{k}{l} = buf(:,1:opt.feature_sampling:end,l);
		end
		
		fprintf('calculated features for %s. (%.2fs)\n',src.files{k},toc(tm0));
	end
	
	nonempty = find(~cellfun(@isempty,features));

	rows = size(features{nonempty(1)}{1},1);
	cols = sum(cellfun(@(x)(sum(cellfun(@(x)(size(x,2)),x))),features(nonempty)));
	precision = class(features{nonempty(1)}{1});
	
	db.src = src;
	
	db.features = zeros(rows,cols,precision);
	
	db.indices = cell(1,length(src.objects));
	
	r = 1;
	for k = 1:length(features)
		for l = 1:length(features{k})
			ind = r:r+size(features{k}{l},2)-1;
			db.features(:,ind) = features{k}{l};
			db.indices{obj_ind{k}(l)} = ind;
			r = r+length(ind);
		end
	end
end

function out = apply_features(x,objects,feature_fun,opt)
	out = {};
	for k = 1:length(feature_fun)
		if nargin(feature_fun{k}) == 2
			out{k,1} = feature_fun{k}(x,objects);
		elseif nargin(feature_fun{k}) == 1
			out{k,1} = feature_wrapper(x,objects,feature_fun{k});
		else
			error('Invalid number of inputs for feature function!')
		end
	end
	
	if length(feature_fun) == 1
		out = out{1};
	else
		out = cellfun(@(x)(permute(x,[2 1 3])),out,'UniformOutput',false);
		out = permute([out{:}],[2 1 3]);
	end
end
