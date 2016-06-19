function plotOnsetByClustering(meanMat, ttl, timeFrames, th_activation, toNormalize, D)

if nargin < 6
    D  = 2;
end
if nargin < 5
    toNormalize = false;
end
if nargin < 4
    th_activation = .5;
end
if nargin < 3
    timeFrames = 1:size(meanMat, 2);
end

if iscell(meanMat)
    finalMat = [];
    for n = 1:length(meanMat)
        if toNormalize
        M=meanMat{n}(:, timeFrames).';
        M1 = bsxfun(@minus, M, mean(M));
        M2 = bsxfun(@rdivide, M1, std(M1)).';
        finalMat = [finalMat; M2];
        else
        finalMat = [finalMat; meanMat{n}(:, timeFrames)];
        end
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
    if toNormalize
        M=meanMat(:, timeFrames).';
        M1 = bsxfun(@minus, M, mean(M));
        M2 = bsxfun(@rdivide, M1, std(M1)).';
    else
      M2 = meanMat(:, timeFrames);  
    end
    figure;
    subplot(1,2,1);
    for n = 1:size(M2, 1)
        
        plot(M2(n, :)-(n-1)*D, 'b');
        hold on;
    end
    axis tight;
    title(ttl);
    subplot(1,2,2);
    for n = 1:size(M2, 1)
%         ind = find(M2(n, :) > 0);
        v(n, :) = zeros(size(M2(n, :)));
%         v(n, ind(1)) = 1;
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
