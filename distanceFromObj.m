% First lets define some parameters for the camera
theta = 60; %this is the angle of the camera plane with the horizontal
height = 51; %cm this is height of the camera sensor from the ground
r = height / sin(deg2rad(theta)); %position from the intersection point of ground and image plane to the centre of the image frame
proximity_threshold = 10; %proximity threshold
[y, Fs] = audioread('beep.mov'); %Beep sound
constant = 200;

renderer = VideoReader('cb_input2.mov');
v_height = renderer.Height;
v_width = renderer.Width;
video = struct('cdata',zeros(v_height, v_width, 3,'uint8'), 'colormap',[]);


k = 1;
while hasFrame(renderer)
    video(k).cdata = readFrame(renderer,'native');
    k = k+1;
end

edge_videoPlayer = vision.VideoPlayer;
edge2_videoPlayer = vision.VideoPlayer;
original_videoPlayer = vision.VideoPlayer;

estimated_distance = distance(edge(video(1).cdata(:,:,1), 'canny', 0.6, 2), 1, r, theta);
alpha = 0.5;
canny_weightage = 0.8;

previous_distance = 0;
averaged_distance = 0;
distance_threshold = 100; %if the previous distance and current averaged distance differ too much then we will ignore the current averaged distance

for i = 100:400
    canny_frame = edge(video(i).cdata(:,:,1), 'canny', 0.6, 2); %applying a high threshold canny in the horizontal direction
    sobel_frame = edge(video(i).cdata(:,:,1), 'sobel', 0.1, 'horizontal'); % a noisy sobel filter
    original_frame = video(i).cdata;

    
%   averaging the distance obtained from both canny and sobel
%   estimating distance my using exponential moving average
    previous_distance = averaged_distance;
    averaged_distance = ((canny_weightage*distance(canny_frame, 1, r, theta) + (1-canny_weightage)*distance(sobel_frame, 1, r, theta))) + constant
    
%   ignores extremely noisy distances
    if i > 100 && abs(previous_distance - averaged_distance) > distance_threshold
        averaged_distance = previous_distance;
    end
    
    estimated_distance = ((1-alpha) * estimated_distance) + (alpha * averaged_distance)
    
    
    edge_videoPlayer(canny_frame);
    edge2_videoPlayer(sobel_frame);
    original_videoPlayer(original_frame);
    
%   here we play the sound only if were in proximity of the object. We also
%   dont make the beep sound if we're moving away from the object.
    if (estimated_distance <= proximity_threshold && (estimated_distance < previous_distance) && mod(i, 5) == 0)
        sound(y,Fs);
    end

%     pause(0.5);

end



% We then do edge detection and try to find horizontal edges in the picture
% These horizontal edges represent the bottom edges of an object which is
% in the path


% Alternatively we could detect objects. See the bottom edge of the object
% which is in contact with the ground.



function output = distance(edge_frame, rgb_n, r, theta)
    frame_height = size(edge_frame, 1);
    
%     first we find the lowest edge point
    y_dash = 0;
    for i = (frame_height: -1 :1)
        if (isempty(find(edge_frame(i, :, rgb_n), 1)) == false)
            y_dash = i;
            break;
        end
    end
    
    distance_origin = (frame_height-y_dash) - (frame_height/2);
    
    % The formulas we will use are 
    % y = (r ? distance_from_origin) Sin(Q) this gets us the y coordinates
    % in the cartesian coordinates. This will be the height of the edge in
    % our image plane
    % distance = y * Tan(Q) // by using simple trignometry we will yeild a
    % distance by finding the diagonal between the image plane and the
    % projected edge
    
    y = (r + distance_origin) * sin(deg2rad(theta));
    output = y * tan(deg2rad(theta));
end