% gtzan_src: Creates a source for the GTZAN dataset.
% Usage
%    src = gtzan_src(directory)
% Input
%    directory: The directory containing the GTZAN dataset.
% Output
%    src: The GTZAN source.

function src = gtzan_src(directory,N)
	if nargin < 1
		directory = 'gtzan';
	end
	
	if nargin < 2
		N = 5*2^17;
	end
	
	src = create_src(directory,@(file)(gtzan_objects_fun(file,N)));
end

function [objects,classes] = gtzan_objects_fun(file,N)
	objects.u1 = 1;
	objects.u2 = N;
	
	path_str = fileparts(file);
	
	path_parts = regexp(path_str,filesep,'split');
	
	classes = {path_parts{end}};
end