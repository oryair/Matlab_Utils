% z - input signal of size: features X time samples

% addpath('scattlab-master')
% addpath_scattlab;

winlen = 16;%1024;
filt_opt.filter_type = 'morlet_1d';
filt_opt.Q = 1;
filt_opt.J = T_to_J(winlen*2, filt_opt.Q);

sc_opt = struct();
sc_opt.antialiasing = 1; % by default 1 -> 2^1
tmp = log2(length(z(1,:)));
cascade = wavelet_factory_1d(2^floor(tmp), filt_opt, sc_opt, 1);
% This scattering transform works only with signals of size 2^i

% Application of the transform
sig=1;
[S, U] = scat(z(sig,1:2^floor(tmp)).', cascade);
[S_table, meta] = format_scat(S);
S_table = reshape(S_table, [size(S_table,1), size(S_table,3)]);

% S_table is of size: time segments X scattering features

% You can add also the following:
S_table = log(abs(S_table )+1e-20);