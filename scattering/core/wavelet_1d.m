% wavelet_1d: 1D wavelet transform.
% Usage
%    [x_phi, x_psi, meta_phi, meta_psi] = wavelet_1d(x, filters, options)
% Input
%    x: The signal to be transformed.
%    filters: The filters of the wavelet transform.
%    options: Various options for the transform. options.antialiasing controls
%       the antialiasing factor when subsampling.
% Output
%    x_phi: x filtered by lowpass filter phi
%    x_psi: cell array of x filtered by wavelets psi
%    meta_phi, meta_psi: meta information on x_phi and x_psi, respectively

function [x_phi, x_psi, meta_phi, meta_psi] = wavelet_1d(x, filters, options)
	if nargin < 3
		options = struct();
	end

	options = fill_struct(options, 'antialiasing', 1);
	options = fill_struct(options, ...
		'psi_mask', true(1, numel(filters.psi.filter)));
	options = fill_struct(options, 'x_resolution',0);
	
	N = size(x,1);
	
	[temp,psi_bw,phi_bw] = filter_freq(filters);
	
	%N_padded = filters.N/2^(floor(log2(filters.N/(2*N))));
	N_padded = filters.N/2^options.x_resolution;
	
	% resolution of x - how much have we subsampled by?
	j0 = log2(filters.N/N_padded);
	
	x = pad_signal_1d(x, N_padded, 'symm');
	
	xf = fft(x,[],1);
	
	ds = round(log2(2*pi/phi_bw)) - ...
	     j0 - ...
	     options.antialiasing;
	ds = max(ds, 0);
	
	x_phi = real(conv_sub_1d(xf, filters.phi.filter, ds));
	x_phi = unpad_signal_1d(x_phi, ds, N);
	meta_phi.j = -1;
	meta_phi.bandwidth = phi_bw;
	meta_phi.resolution = ds;
	
	x_psi = cell(1, numel(filters.psi.filter));
	meta_psi.j = -1*ones(1, numel(filters.psi.filter));
	meta_psi.bandwidth = -1*ones(1, numel(filters.psi.filter));
	meta_psi.resolution = -1*ones(1, numel(filters.psi.filter));
	for p1 = find(options.psi_mask)
		ds = round(log2(2*pi/psi_bw(p1)/2)) - ...
		     j0 - ...
		     options.antialiasing;
		ds = max(ds, 0);
		
		x_psi{p1} = conv_sub_1d(xf, filters.psi.filter{p1}, ds);
		x_psi{p1} = unpad_signal_1d(x_psi{p1}, ds, N);
		meta_psi.j(:,p1) = p1-1;
		meta_psi.bandwidth(:,p1) = psi_bw(p1);
		meta_psi.resolution(:,p1) = ds;
	end
end
