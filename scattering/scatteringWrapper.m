function S_table = scatteringWrapper(inputMat, winlen, filt_opt, sc_opt)

if nargin < 4
sc_opt = struct();
    sc_opt.antialiasing = 1; % by default 1 -> 2^1
end
if nargin < 3    
    filt_opt.filter_type = 'morlet_1d';
    filt_opt.Q = 1;
    filt_opt.J = T_to_J(winlen*2, filt_opt.Q);
end
if nargin < 2    
    winlen = 4;%1024;
end

if winlen==0
    S_table = permute(inputMat, [2, 3, 1]);
    
else
tmp = log2(length(inputMat(1,:)));
cascade = wavelet_factory_1d(2^floor(tmp), filt_opt, sc_opt, 1);

S = scat(inputMat(:,1:2^floor(tmp)).', cascade);
S_table = format_scat(S);
S_table = permute(S_table, [1 3 2]);
S_table = log(abs(S_table )+1e-20);
end