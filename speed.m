v = VideoReader('highway2.mov');
v_Height = v.Height;
v_Width = v.Width;
total_framecount = floor(v.FrameRate * v.Duration);

red_threshold = 185;
others_threshold = 150;


% frames = zeros(total_framecount * v_Height, v_Width, 3);
frames = []
for i = 1:total_framecount
    video = readFrame(v);
    frames = [frames; video];
%     frames((i-1)*v_Height + 1:(i)*v_Height, :,1) = video(:, :, 1);
%     frames((i-1)*v_Height + 1:(i)*v_Height, :,2) = video(:, :, 2);
%     frames((i-1)*v_Height + 1:(i)*v_Height, :,3) = video(:, :, 3);
end

imshow(frames(1:v_Height, :, :));

% now we ask user to select two points on tcohe road.
uiwait(msgbox('Please select a point on the high way through which the red car will pass','','modal'));
[x1,y1] = ginput(1)

% this is the point after which we perform calculation
uiwait(msgbox('Please select another point on the high way through which the red car will pass','','modal'));
[x2,y2] = ginput(1)

y1 = int32(y1)
y2 = int32(y2)

videoPlayer = vision.VideoPlayer;
passed_y1 = false;
frame_y1 = 0;
frame_y2 = 0;

for k = 1:total_framecount
%     here we check whether the car has passed through the first point
    curr_frame = frames((k-1)*v_Height + 1:(k)*v_Height, :, :);
    videoPlayer(curr_frame);

    if passed_y1 == false
%        here check if any pixel value at the horizontal line y1 == red
        for j = 1:v_Width
           colors = curr_frame(y1, j, :);
           if colors(1) >= red_threshold && colors(2) <= others_threshold && colors(3) <= others_threshold
%             This pixel is red we want to save the frame and break the
%             loop
              passed_y1 = true
              frame_y1 = k;
              break;  
           end
        end
    else
%         check if any pixel value at the horizontal line y2 == red
        for j = 1:v_Width
            colors = curr_frame(y2, j, :);
            if colors(1) >= red_threshold && colors(2) <= others_threshold && colors(3) <= others_threshold
                %             This pixel is red we want to save the frame and break the
                %             loop
                frame_y2 = k
                break;  
            end
        end  
    end
    if frame_y2 ~= 0
        break;
    end
    
    pause(0.1)
end

release(videoPlayer);

% Calculate speed
frames_counted = frame_y2 - frame_y1;
time_taken = frames_counted / v.FrameRate;
distance_travelled = abs(y2 - y1);
speed_of_car = string(distance_travelled/time_taken) + 'km/h';

uiwait(msgbox(char(speed_of_car),'The speed of the car was','modal'));
