v = VideoReader('delback1.mov');
v_Height = v.Height;
v_Width = v.Width;
new_background = reshape(rgb2gray(imread('newback.png')), [1, v_Height *v_Width]);
% total_framecount = floor(v.FrameRate * v.Duration);
total_framecount = 150;

% frames = zeros(total_framecount, v_Height * v_Width);
frames = [];
for i = 1:total_framecount
    video = rgb2gray(readFrame(v));
    video = reshape(video, [1, v_Height * v_Width]);
    frames = [frames; video];
end

% We use the histogram to find a threshold between after which we will
% replace the background
background_frame = frames(1, :);
% background_frame = reshape(frames(1, :), [v_Height, v_Width]);
% imhist(background_frame);
% uiwait(msgbox('Please select a threshold','','modal'));
% [threshold_value,y] = ginput(1)
% threshold_value = floor(threshold_value)

uiwait(msgbox('First we remove the background','','modal'));

videoPlayer = vision.VideoPlayer;
new_frame = zeros(1, v_Height * v_Width);
threshold = 5;
for i = 1:size(frames,1)
%     new_frame = abs(background_frame - frames(i, :));
    for j = 1:size(frames, 2)
%         if abs(background_frame(j) - frames(i, j)) <= threshold
%             new_frame = [new_frame, 0];
%         else
%             new_frame = [new_frame, frames(i,j)];
%         end
        if abs(background_frame(j) - frames(i, j)) <= threshold
            frames(i, j) = 0;
        end
    end
%     new_frame = reshape(frames(i, :) - background_frame, [v_Height, v_Width]);
    new_frame = reshape(frames(i, :), [v_Height, v_Width]);
    videoPlayer(new_frame);
%     pause(0.1)
end

uiwait(msgbox('Now we replace the background','','modal'));

% And now to replace the background with a picture of something
for k = 1:size(frames, 1)
%     new_frame = abs(background_frame - frames(i, :));
    for l = 1:size(frames, 2)
        if frames(k, l) == 0
            frames(k, l) = new_background(l);
        end
    end
%     new_frame = reshape(frames(i, :) - background_frame, [v_Height, v_Width]);
    new_frame = reshape(frames(k, :), [v_Height, v_Width]);
    videoPlayer(new_frame);
    pause(0.1)
end



release(videoPlayer);
