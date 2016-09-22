function savemove2avi(filename, mov, reps)

if nargin == 2
    reps=1;
end

vidObj = VideoWriter(filename);
open(vidObj);

for k = 1:length(mov)
    for t=1:reps
        writeVideo(vidObj,mov(k));
    end
end

% Close the file.
close(vidObj);