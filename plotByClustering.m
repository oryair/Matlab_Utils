function normalized_centroids = plotByClustering(meanMat, ttl, timeFrames, toNormalize)
normalized_centroids = [];
if nargin <4
    toNormalize = false;
end
if iscell(meanMat)
    figure;
    if nargin == 2
        timeFrames = 1:size(meanMat{1}, 2);
    end
    for k=1:length(meanMat)
        subplot(length(meanMat), 1, k);
        
        
        
        imagesc(meanMat{k}(:,timeFrames));colormap gray;
        set(gca, 'XtickLabel',{});
        set(gca, 'YtickLabel',{});
        ylabel(num2str(k));
        if k == 1
            title(ttl);
        end
        if toNormalize
        M=meanMat{k}(:, timeFrames).';
        M1 = bsxfun(@minus, M, mean(M));
        M2 = bsxfun(@rdivide, M1, std(M1)).';
        normalized_centroids(:, k) = mean(M2, 1);
        else
            normalized_centroids(:, k) = mean(meanMat{k}(:, timeFrames), 1);
        end
%         subplot(length(meanMat), 2, 2*k);
%         imagesc(M2);colormap jet;
%         set(gca, 'XtickLabel',{});
%         set(gca, 'YtickLabel',{});
%         if k == 1
%             title(['Normalized - ' ttl]);
%         end
            
        
    end
    
    figure;
    normalized_centroids = normalized_centroids.';
    imagesc(normalized_centroids);
    title([ttl ' - Normalized Centroids' ]);
    colormap gray;
    
else
    if nargin == 2
        timeFrames = 1:size(meanMat, 2);
    end
    figure;
    if toNormalize
        M=meanMat(:, timeFrames).';
        M1 = bsxfun(@minus, M, mean(M));
        normalized_centroids = bsxfun(@rdivide, M1, std(M1)).';
            imagesc(normalized_centroids);colormap jet;

    else
        
    
    imagesc(meanMat(:, timeFrames));colormap jet;
    end
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
