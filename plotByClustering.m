function plotByClustering(meanMat, ttl, timeFrames)
if iscell(meanMat)
    figure;
if nargin == 2
    timeFrames = 1:size(meanMat{1}, 2);
end
for k=1:length(meanMat)
   subplot(length(meanMat), 1, k);
%    subplot(length(allMat), 2, 2*k);
   imagesc(meanMat{k}(:,timeFrames));
   set(gca, 'XtickLabel',{});
   set(gca, 'YtickLabel',{});
   colorbar;
   ylabel(num2str(k));
   if k == 1
       title(ttl);
   end
   
end
else
if nargin == 2
    timeFrames = 1:size(meanMat, 2);
end
figure;
imagesc(meanMat(:, timeFrames));
set(gca, 'Ytick', 1:size(meanMat,2));title(sprintf('%s\nMean Image', ttl));
end
% figure;
% for k=1:size(meanMat,1)
%    subplot(length(allMat), 1, k);
%    imagesc(meanMat(k, :));
%    set(gca, 'XtickLabel',{});
%    set(gca, 'YtickLabel',{});
%    ylabel(num2str(k));
% end
