% morlet_filter_bank_2d : Build a bank of Morlet wavelet filters
%
% Usage
%	filters = morlet_filter_bank_2d(size_in, options)
%
% Input 
% - size_in : <1x2 int> size of the input of the scattering
% - options : [optional] <1x1 struct> contains the following optional fields
%   - v          : <1x1 int> the number of scale per octave
%   - J          : <1x1 int> the total number of scale.
%   - nb_angle   : <1x1 int> the number of orientations
%   - sigma_phi  : <1x1 double> the width of the low pass phi_0
%   - sigma_psi  : <1x1 double> the width of the envelope
%                                   of the high pass psi_0
%   - xi_psi     : <1x1 double> the frequency peak
%                                   of the high_pass psi_0
%   - slant_psi  : <1x1 double> the excentricity of the elliptic
%  enveloppe of the high_pass psi_0 (the smaller slant, the larger
%                                      orientation resolution)
%   - margins    : <1x2 int> the horizontal and vertical margin for 
%                             mirror pading of signal
%
% Output 
% - filters : <1x1 struct> contains the following fields
%   - psi.filter{p}.type : <string> 'fourier_multires'
%   - psi.filter{p}.coefft{res+1} : <?x? double> the fourier transform
%                          of the p high pass filter at resolution res
%   - psi.meta.k(p,1)     : its scale index
%   - psi.meta.theta(p,1) : its orientation scale
%   - phi.filter.type     : <string>'fourier_multires'
%   - phi.filter.coefft
%   - phi.meta.k(p,1)
%   - meta : <1x1 struct> global parameters of the filter bank

function filters = morlet_filter_bank_2d(size_in, options)
	
	options.null = 1;
	
	v = getoptions(options, 'v', 1); % number of scale per octave
	J = getoptions(options, 'J', 4); % total number of scales
	nb_angle = getoptions(options, 'nb_angle', 8); % number of orientations
	
	sigma_phi  = getoptions(options, 'sigma_phi',   0.8);
	sigma_psi  = getoptions(options, 'sigma_psi',  0.8);
	xi_psi     = getoptions(options, 'xi_psi',     3*pi/4);
	slant_psi  = getoptions(options, 'slant_psi',  0.5);
	
	res_max = floor(J/v);
	% compute margin for padding
	% make sure size_in is multiple of 2^res_max
	if (sum(size_in/2^res_max == floor(size_in/2^res_max))~=2)
		error('size_in must be multiple of downsampling');
	end
	margins_default = min(sigma_phi*2^((J-1)/v), size_in/2);
	margins_default = 2^res_max * ceil(margins_default/2^res_max);
	margins = ...
		getoptions(options, 'margins', margins_default);
	% make sure margin is multiple of 2^res_max
	if (sum(margins/2^res_max == floor(margins/2^res_max))~=2)
		error('margin must be multiple of downsampling');
	end
	size_filter = size_in + 2*margins;
	
	phi.filter.type = 'fourier_multires';
	
	% compute all resolution of the filters
	
	for res = 0:res_max
		
		N = ceil(size_filter(1) / 2^res);
		M = ceil(size_filter(2) / 2^res);
		
		% compute low pass filters phi
		scale = 2^((J-1) / v - res);
		filter_spatial =  gabor_2d(N, M, sigma_phi*scale, 1, 0, 0);
		phi.filter.coefft{res+1} = fft2(filter_spatial);
		phi.meta.J = J;
		
		littlewood_final = zeros(N, M);
		% compute high pass filters psi
		angles = (0:nb_angle-1)  * pi / nb_angle;
		p = 1;
		for j = 0:J-1
			for theta = 1:numel(angles)
				
				psi.filter{p}.type = 'fourier_multires';
				
				angle = angles(theta);
				scale = 2^(j/v - res);
				if (scale >= 1)
					if (res==0)
						filter_spatial = morlet_2d_noDC(N, ...
							M,...
							sigma_psi*scale,...
							slant_psi,...
							xi_psi/scale,...
							angle) ;
						psi.filter{p}.coefft{res+1} = fft2(filter_spatial);
					else
						% no need to recompute : just downsample by periodizing in
						% fourier
						psi.filter{p}.coefft{res+1} = ...
							sum(extract_block(psi.filter{p}.coefft{1}, [2^res, 2^res]), 3) / 2^res;
						
					end
					littlewood_final = littlewood_final + abs(psi.filter{p}.coefft{res+1}).^2;
				end
				
				psi.meta.j(p) = j;
				psi.meta.theta(p) = theta;
				p = p + 1;
			end
		end
		
		% second pass : renormalize psi by max of littlewood paley to have
		% an almost unitary operator
		% NOTE : phi must not be renormalized since we want its mean to be 1
		K = max(littlewood_final(:));
		for p = 1:numel(psi.filter)
			if (numel(psi.filter{p}.coefft)>=res+1)
				psi.filter{p}.coefft{res+1} = psi.filter{p}.coefft{res+1} / sqrt(K/2);
			end
		end
	end
	
	filters.phi = phi;
	filters.psi = psi;
	
	filters.meta.v = v;
	filters.meta.J = J;
	filters.meta.nb_angle = nb_angle;
	filters.meta.sigma_phi = sigma_phi;
	filters.meta.sigma_psi = sigma_psi;
	filters.meta.xi_psi = xi_psi;
	filters.meta.slant_psi = slant_psi;
	filters.meta.size_in = size_in;
	filters.meta.size_filter = size_filter;
	filters.meta.margins = margins;
	
	
end
