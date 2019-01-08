% So first we need edges from both our original image and
% from our depth image
depth = imread('Depth and Images/d1.jpg');
og = imread('Depth and Images/i1.png');

% edges
depth_edges = edge(rgb2gray(depth), 'canny', 0.1);
og_edges = edge(rgb2gray(og), 'canny', 0.9);
imshow (og_edges);

% ask user for a box
% now crop the images to have only what the rect is
[cropped_depth_edges, rect]= imcrop(depth_edges);
% [454.510000000000,117.510000000000,99.9800000000000,43.9800000000000]
cropped_og_edges = imcrop(og_edges, rect);

imshow(cropped_depth_edges);
figure, imshow(cropped_og_edges);

% Then we employ pratts figure of merit to see whether the two edge are
% similar or not. This is just to determine where the edge should actually
% be

% We need Nf, Na, Ns -> max(Nf, Na)
Nf = numel(cropped_depth_edges(cropped_depth_edges == 1));
Na = numel(cropped_og_edges(cropped_og_edges == 1));

Ns = max(Nf, Na);

alpha = 0.5
FoM = 0;

foundEdges = ones(Ns, 3);
l = 1
for i = 1:size(cropped_depth_edges, 1)
    for j = 1:size(cropped_depth_edges, 2)
        if (cropped_depth_edges(i, j) == 1)
            foundEdges(l, 1) = i;
            foundEdges(l, 2) = j;
            l = l+1;
        end
    end
end

% now we loop over the whole thing to see if we get any better
for i = 1:size(cropped_depth_edges, 1)
    for j = 1:size(cropped_depth_edges, 2)
        if (cropped_og_edges(i, j) == 1)
            for k = 1:Ns
                if (foundEdges(k, 3) == 1)
                    min_dist = power(pow2(i-foundEdges(k, 1)) + pow2(j-foundEdges(k, 2)),0.5);
                    min_k = k;
                    foundEdges(k, 3) = 0;
                    break;
                end
            end
            
            FoM = FoM + (1/(1+(alpha * pow2(min_dist))));
            
        end
    end
end

FoM = (1/Ns) * FoM