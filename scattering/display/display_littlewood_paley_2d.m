function img = display_littlewood_paley_2d(filters)
% function img = display_littlewood_paley(filterbank)
% display the littlehood paley of the fine-resolution filters of the
% filterbank
% that is :
% \sum_{j, \theta} |\hat{\psi_j} (\omega)|^2 + |\hat{\phi_J}(\omega)|^2
%
% input :
% - filters : <1x1 struct> filter bank typically obtained with
%       morlet_filter_bank_2d.m
% output :
% - img : <NxM double> image of the littlewood paley

lp = littlewood_paley_2d(filters);
img = fftshift(lp{1});
imagesc(img);