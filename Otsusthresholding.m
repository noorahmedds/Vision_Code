% lets implement a simple between between class minimization algorithm

img = imread('../Depth and Images/i8.jpg');
img = rgb2gray(img);

hist = imhist(img)

% for every threshold value from 0 to 255. We first need
minimum_variance_w = 0;
minimum_threshold = 0;
for i=1:255
%   we need to caluclate the weights for foreground and backgroun
%   we need to caluclate the mean values for both the boreground and
%   background
%   we need determine the within class variance by iterating over all
%   grayscale values

    grayscale = i-1;
    Mf = 0; Mb = 0;
    varf = 0; varb = 0;
    
    M = numel(img);
    
%   iterate over the whole histogram
    for curr_thresh = 1:256
        if curr_thresh <= i
            Mb = Mb + ((curr_thresh - 1) * hist(curr_thresh));
        else
            Mf = Mf + ((curr_thresh - 1) * hist(curr_thresh));
        end
    end
    
    countb = sum(hist(1:i));
    countf = sum(hist(i+1:256));
    
    Mb = Mb/countb;
    Mf = Mf/countf;
    
    Wb = countb / M;
    Wf = countf / M;
    
    for curr_thresh = 1:256
        if curr_thresh <= i
            varb = varb + (hist(curr_thresh) * pow2(curr_thresh-1 - Mb));
        else
            varf = varf + (hist(curr_thresh) * pow2(curr_thresh-1 - Mf));
        end
    end
    
    if (countb > 0)
        varb = varb / sum(hist(1:i));
    else
        varb = 0;
    end
    
    if (countf > 0)
        varf = varf / sum(hist(i+1:256));
    else
        varf = 0;
    end
    
    current_withinclass_variance = (Wb*varb) + (Wf*varf);
    
    if current_withinclass_variance < minimum_variance_w || i == 1
        minimum_variance_w = current_withinclass_variance;
        minimum_threshold = grayscale;
    end
end


threshold = ((minimum_threshold)/255)
imshow(im2bw(img, threshold))

