function plotOnsetByClusteringNormalized(meanMat, ttl, timeFrames, th_activation)


if nargin == 2
    timeFrames = 1:size(meanMat, 2);
end
if iscell(meanMat)
    finalMat = [];
    for n = 1:length(meanMat)
        
        finalMat = [finalMat; meanMat{n}(:, timeFrames)];
        
    end
    
    for k = 1:size(finalMat, 1)
        ind = find(finalMat(k, :) > 0);
        v(k, :) = zeros(size(finalMat(k, :)));
        v(k, ind(1)) = 1;
        v(k, :) = finalMat(k, :) > th_activation;
        
    end
    
    figure;
    subplot(1,2,1);
    for n = 1:size(finalMat, 1)
        
        plot(finalMat(n, :)-(n-1)*2, 'b');
        hold on;
    end
    axis tight;
    title(ttl);
    subplot(1,2,2);
    imagesc(v);title('Activation Map');colormap gray;
    
else
    
      M2 = meanMat(:, timeFrames);  
    
    figure;
    subplot(1,2,1);
    for n = 1:size(M2, 1)
        
        plot(M2(n, :)-(n-1)*2, 'b');
        hold on;
    end
    axis tight;
    title(ttl);
    subplot(1,2,2);
    for n = 1:size(M2, 1)
        ind = find(M2(n, :) > 0);
        v(n, :) = zeros(size(M2(n, :)));
        v(n, ind(1)) = 1;
        v(n, :) = M2(n, :) > th_activation;
        
    end
    imagesc(v);title('Activation Map');colormap gray;
end

% figure;
% for k=1:size(meanMat,1)
%    subplot(length(allMat), 1, k);
%    imagesc(meanMat(k, :));
%    set(gca, 'XtickLabel',{});
%    set(gca, 'YtickLabel',{});
%    ylabel(num2str(k));
% end
