
% We first say what the pixel to meter ratio is
man_height = 6; %6 feet in height
relative_pixelcount = 540;
pixeltofeet = man_height/relative_pixelcount;

imshow('comparison.jpg');
rect = getrect;
height = string(rect(4) * pixeltofeet);
uiwait(msgbox(char(height),'The height of this object was','modal'));

