clear
clc
% PortToOpen.delete ;
% PortToOpen = tcpclient("192.168.4.1",8888)
PortToOpen = serialport("COM17",250000)
PortToOpen.readline;
PortToOpen.readline;
PortToOpen.readline;
PortToOpen.readline;
PortToOpen.readline;
PortToOpen.readline;

PortToOpen.flush ;
data = str2num(PortToOpen.readline);
data = str2num(PortToOpen.readline);
data = str2num(PortToOpen.readline);
data = str2num(PortToOpen.readline);
data = str2num(PortToOpen.readline);
data = str2num(PortToOpen.readline);
data = str2num(PortToOpen.readline);
data = str2num(PortToOpen.readline);
data = str2num(PortToOpen.readline);
data = str2num(PortToOpen.readline);
data = str2num(PortToOpen.readline);
data = str2num(PortToOpen.readline);

statingTime = data(end) ;
corenMaxtTime = statingTime ;
tic
matlabStartingTime = toc ;
BoardStartingTime = statingTime ;

maxTime = 20 ;
countData = 10 * maxTime ;
dataLoger = zeros(countData ,size(data,2)-2);
PortToOpen.flush ;
PortToOpen.flush ;
PortToOpen.flush ;
data = str2num(PortToOpen.readline);
data = str2num(PortToOpen.readline);
data = str2num(PortToOpen.readline);

PortToOpen.flush ;
data = str2num(PortToOpen.readline);
data = str2num(PortToOpen.readline);
S_Time = toc;
T = 0 ;
i = 0 ;
while (T < maxTime)
    data = str2num(PortToOpen.readline);
    while ((size(data,2) ~= 6 ) || ...
            (data(1)~=9999) || (data(end)~=8888))
        data = str2num(PortToOpen.readline);
    end
    i = i +1 ;
    T = toc - S_Time
        
    lastData = data ;
    dataLoger(i,1:end-1) = lastData(2:end-2);
    dataLoger(i,end) = lastData(end-1)/1000;
    
    
end
 

PortToOpen.delete ;
ploter

