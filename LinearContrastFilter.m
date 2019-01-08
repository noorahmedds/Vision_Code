kernel = [-3,1,-3; 1,9 ,1; -3,1,-3];
img = imread('Depth and Images/d1_extracted.jpg');

FilteredImage = imfilter(img, kernel);

imshow(FilteredImage);
figure; imshow(img);