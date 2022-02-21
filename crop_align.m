function [ imgf pixelsize ] = crop_align(fname)
%   crop_align() function

%   Disclaimer: 
%   “This software and/or documentation is provided ‘as is’. No warranty or representation of any kind is made, given or implied, as to for example but not limited thereto, the merchantability,
%   sufficiency or fitness for a particular purpose nor as to the absence of any infringement of any proprietary rights of third parties. This software is provided free for non-commercial purposes.
%   By downloading the software, you agree that you will use it for research and not for commercial purposes, and that you will not distribute it outside of your own institution.”

%	Description:
%		Align and crop the viewing window area of the liquid cell
%       By clicking clockwise at four corners of the window, the window  will be aligned (top left --> top right --> bottom right --> bottom left)
%       By clicking clockwise at four corners again, the window  will be cropped
%   Input format: .SER image
%	Parameters:
%		fname - the filename of the SER file of the LP-TEM image with the viewing window
%       
%	Output:
% 		imgf - intensity map of the aligned viewing window area
%       pixelsize - pixelsize of the readed file

%	Author:
%		Hanglong Wu, Arthur D. A. Keizer, Laura. S. van Hazendonk, Hao Su, Heiner Friedrich

%% read file, and add the marker, presuming the shape of the window is rectangular
[img pixelsize] = ser2img( fname );
s =  size(img);
figure(1);clf
imshow(img,[]); % second input is grayscale
title('Click clockwise at the four corners of the window','FontSize',15)
colormap(gca,gray)
set(gcf, 'Position', get(0,'Screensize'));
coordi=ginput(4); % (coordinates(1,1)=x point 1, (coordinates(1,2))=y point 1
xc = (coordi(1,1)+coordi(2,1)+coordi(3,1)+coordi(4,1))/4;
yc = (coordi(1,2)+coordi(2,2)+coordi(3,2)+coordi(4,2))/4;

hold on 
plot(coordi(1,1),coordi(1,2),'oy','MarkerSize',10)
plot(coordi(2,1),coordi(2,2),'oy','MarkerSize',10)
plot(coordi(3,1),coordi(3,2),'oy','MarkerSize',10)
plot(coordi(4,1),coordi(4,2),'oy','MarkerSize',10)
plot(xc,yc,'xr','MarkerSize',10)
plot([coordi(1,1) coordi(2,1) coordi(3,1) coordi(4,1) coordi(1,1)],[coordi(1,2) coordi(2,2) coordi(3,2) coordi(4,2) coordi(1,2)],'--b','LineWidth',1);
hold off


a1 = atand((coordi(1,2)-coordi(2,2))/(coordi(1,1)-coordi(2,1)));
a2 = atand((coordi(4,2)-coordi(3,2))/(coordi(4,1)-coordi(3,1)));
a3 = -acotd((coordi(1,2)-coordi(4,2))/(coordi(1,1)-coordi(4,1)));
a4 = -acotd((coordi(2,2)-coordi(3,2))/(coordi(2,1)-coordi(3,1)));
a_r = (a1+a2+a3+a4)/4;

% image rotate
j = imrotate(img,a_r,'bilinear');
figure(2);clf
imshow(j,[])
title('Click clockwise at the four corners of the window','FontSize',15)
% colormap(gca,parula)
set(gcf, 'Position', get(0,'Screensize'));
c2=ginput(4); % (coordinates(1,1)=x point 1, (coordinates(1,2))=y point 1
xc2 = (c2(1,1)+c2(2,1)+c2(3,1)+c2(4,1))/4;
yc2 = (c2(1,2)+c2(2,2)+c2(3,2)+c2(4,2))/4;


%% Crop the area
offset = 0*(s(1)); % pixels % can change it to 10%
w = (abs(c2(2,1)-c2(1,1))+abs(c2(3,1)-c2(4,1)))/2;
l = (abs(c2(1,2)-c2(4,2))+abs(c2(2,2)-c2(3,2)))/2;
imgf = j((yc2-l/2-offset):(yc2+l/2+offset),(xc2-w/2-offset):(xc2+w/2+offset));

figure(3);clf
imshow(imgf,[])
colormap(gca,gray)
end


