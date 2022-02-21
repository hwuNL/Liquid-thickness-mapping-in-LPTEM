function [wim wls pixelsize m_ca c_flat] = MTC_map(fname,ffd, t, thSiN, mfpw, corner_d, center_d)
%   MTC_map() function
%   Disclaimer: 
%   “This software and/or documentation is provided ‘as is’. No warranty or representation of any kind is made, given or implied, as to for example but not limited thereto, the merchantability,
%   sufficiency or fitness for a particular purpose nor as to the absence of any infringement of any proprietary rights of third parties. This software is provided free for non-commercial purposes.
%   By downloading the software, you agree that you will use it for research and not for commercial purposes, and that you will not distribute it outside of your own institution.”
%	Description:
%		map the liquid thickness in the whole viewing window area using the	mass-thickness approximation (MTC method)
%   Input format: .SER image
%	Parameters:
%		fname - the filename of the SER file of the LP-TEM image with the viewing window
%       ffd - the filename of the SER file of the flat field image without sample
%       mfpw - the elastic mean free path of the system liquid in the liquid cell; % nm
%       t - exposure time of the LP-EM image containging the viewing window, note that here the default expo time of ffd image is 1 s;
%       thSiN - the thickness of the single-layer silicon nitride window 
%       corner_d - the size of the corner area used for calculating the flat thickness % pixel
%       center_d - the size of area in the center used for calculating the total thickness % pixel
%	Output:
% 		wim - intensity map of the viewing window area
%       wls - absolute thickness map of the liquid thickness in the viewing window area
%       pixelsize - pixelsize of the readed file
%       m_ca - the total liquid thickness in the center of the window area
%       c_flat - the flat thickness
%	Author:
%		Hanglong Wu, Arthur D. A. Keizer, Laura. S. van Hazendonk, Hao Su, Heiner Friedrich


mfps = 123; % nm, EMFP of Si3N4 at 200 KV

if not(isfloat(ffd))
  ffd = ser2img(ffd); %Read I0 image for processing
end

% t: exposure time for the captured image.
ffd = mean (mean(ffd(:,:)))*t; 

IW0 = ffd.*exp(-2*thSiN./mfps); % correction for the thickness from the two silicon layer
%% function execution
[ wim pixelsize ] = crop_align(fname);

px = pixelsize/1000; % get pixelsize from crot function, unit: um

a = size(wim);

wim = double(wim);
%
wls = real(-log(wim./IW0).*mfpw);

x = [1:size(wls,2)]*px;
y = [1:size(wls,1)]*px;

%% imshow intensity map

colorscale = [round(prctile(wim(:),0.3)) round(prctile(wim(:),99.7))]
figure(7);clf
imagesc([0 x],[0 y],wim,colorscale);
daspect([1 1 1])
grid on
colormap gray
% yticks([0 10 20 30])
% xticks([0 10 20 30])
set(gca,'FontSize',30,'FontWeight','bold')
ylabel('Y (um)','FontSize',30)
xlabel('X (um)','FontSize',30)

colorbar off

c = colorbar('east'); 
set(c,'position',[.8 .05 .03 0.4])
c.Label.String = 'Intensity (counts)';

%% imshow thickness map

colorscale = [round(prctile(wls(:),0.3)) round(prctile(wls(:),99.7))]

figure(6);clf
imagesc([0 x],[0 y],wls,colorscale);
daspect([1 1 1])
grid on
colormap parula
set(gca,'FontSize',30,'FontWeight','bold')
ylabel('Y (um)','FontSize',30)
xlabel('X (um)','FontSize',30)
% yticks([0 10 20 30])
% xticks([0 10 20 30])
colorbar off

c = colorbar('east'); 
set(c,'position',[.8 .05 .03 0.4])
c.Label.String = 'Thickness (nm)';


%% liquid thickness in the center of the window area
%get the center coordinates
cc = [round((size(wls,1)/2)) round((size(wls,2)/2))];
% crop the center area out; 
d_c = round(center_d/2); % 50 nm,size 50*50
ca = wls((cc(1)-d_c):(cc(1)+d_c-1),(cc(2)-d_c):(cc(2)+d_c-1));
% averaged thickness
m_ca = mean(ca(:)); %averaged thickness in the center
%standard deviation
m_std = std(ca(:));


%% calculate the flat and bulging thickness

 s_g = size(wls);
% 
 le = corner_d % e.g. 50 nm, crop 50x50pixel in 4 each corner
 %clockwise numbered 
 corner1  = wls(1:le,1:le);
 corner2  = wls(1:le,((s_g(2)-le+1):s_g(2)));
 corner3  = wls(((s_g(1)-le+1):s_g(1)),1:le);
 corner4  = wls(((s_g(1)-le+1):s_g(1)),((s_g(2)-le+1):s_g(2)));
% the mean thickness of the flat area
 c_flat = (mean(corner1(:))+mean(corner2(:))+mean(corner3(:))+mean(corner4(:)))/4;
 
 % calculate the thickness of the bulging only;
 bulgC = (m_ca-c_flat)/2
 c_bulg = (wls-c_flat)/2;

%% output

save('thicknessmap.mat','wls')
save('intensitymap.mat','wim')
save('x.mat','x')
save('y.mat','y')

% display

disp(strcat('liquid thickness in the center:',sprintf(' %d nm.',round(m_ca))))
disp(strcat('flat thickness:',sprintf(' %d nm.',round(c_flat))))
end

function [img pixelsize] = ser2img( name )
data = serReader(name);
img  = data.image;
img = rot90(img,1);
pixelsize = data.pixelSizeX/10^-9; % nm
end

