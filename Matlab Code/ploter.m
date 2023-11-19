
clc

[XYZ, H, D, I, F] = wrldmagm(1250, 35.704955 , 51.241222, decyear(2022,11,21),'2020');
R = norm(XYZ)/1000;
c = [0; 0; 0]; % ellipsoid center
r = [R; R; R]; % semiaxis radii

[x,y,z] = ellipsoid(c(1),c(2),c(3),r(1),r(2),r(3),20);
D = [x(:),y(:),z(:)];
figure(1)
plot3(x(:),y(:),z(:),'LineStyle','none','Marker','X','MarkerSize',8)
hold on

LD = 15;
GoodData = dataLoger(1:end-LD , :) ;
Time = GoodData(:,end);
plot3(GoodData(:,1),GoodData(:,2),GoodData(:,3),'*')
grid(gca,'on')

D2 = [GoodData(:,1),GoodData(:,2),GoodData(:,3)];
[A,b,expmfs] = magcal(D2); % calibration coefficients
expmfs; % Dipaly expected  magnetic field strength in uT

C = (D2-b)*A; % calibrated data
C = (D2-b)*A*R/expmfs; % calibrated data

plot3(C(:,1),C(:,2),C(:,3),'LineStyle','none','Marker', ...
            'o','MarkerSize',8,'MarkerFaceColor','r') 


C2 = (D*(A^-1))+b; % calibrated data
C2 = (D*(A^-1)*expmfs/R)+b; % calibrated data

plot3(C2(:,1),C2(:,2),C2(:,3),'LineStyle','none','Marker', ...
            'o','MarkerSize',8,'MarkerFaceColor','r') 


axis equal
xlabel('uT')
ylabel('uT')
zlabel('uT')
legend('Desired Samples', 'Uncalibrated Samples', 'Calibrated Samples','Location', 'southoutside')
title("Uncalibrated vs Calibrated" + newline + "Magnetometer Measurements")
hold off


[azimuth,elevation,radius]  = cart2sph(C(:,1),C(:,2),C(:,3));
azimuthEdges = -pi:pi/6:pi;
elevationEdges = -pi/2:pi/6:pi/2;

radiusEdges = linspace(0.7*R , 1.3*R , 6);
H = histcounts2(azimuth,elevation,'XBinEdges',azimuthEdges , 'YBinEdges',elevationEdges);

figure(2)
histogram2(azimuth,elevation,'XBinEdges',azimuthEdges , 'YBinEdges',elevationEdges);

figure(3)
histogram(radius,radiusEdges);

H2 = histcounts(radius,radiusEdges);

if ( (H2(round(max(size(H2))/2))/sum(H2) > 0.85) && (1) )
    disp("  Calibrated")
else
    disp("  Not Calibrated, Try agane")
end

radius_consentration = H2(round(max(size(H2))/2))/sum(H2)





