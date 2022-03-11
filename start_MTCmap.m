%% Input
%The filename of the SER file of the LP-TEM image with the viewing window
fname = '550x_4s_1.ser';
%The filename of the SER file of the flat field image without sample
ffd = '550x_ffd_1.ser';
%The exposure time of the LP-TEM image containging the viewing window, note that here the default exposure time of the flat field image is 1 s;
t = 4 % s;
%The thickness of the single-layer silicon nitride window 
thSiN = 50 % nm
%The calculated elastic mean free path of the system liquid in the liquid cell; % nm
mfpw = 430 % nm, the elastic mean free path of liquid water at 200 kV
% the size of the corner area used for calculating the flat thickness
corner_d = 50 % pixel
% the size of area in the center used for calculating the total thickness
center_d = 50 % pixel

%% Run  MTC_map

[wim wls pixelsize m_ca c_flat] = MTC_map(fname,ffd, t, thSiN, mfpw, corner_d, center_d);
