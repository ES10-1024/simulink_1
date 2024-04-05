%% Describtion
% This short script is utilized to run the simulink simulation  
%% Making alot of clears 
clf 
clc 
clear
%% Adding path and standard values
addpath("Global controller\Simple Simulink implemtation\Functions\")
c=scaled_standard_constants; 
%% 
simHour=48; 
simTime=simHour/c.AccTime*3600; 


c.Tsim=num2str(simTime); 
c.tsSim=num2str(c.ts*3600); 

simData=sim('GlobalMPC.slx',"StartTime",'0',"StopTime",c.Tsim,'FixedStep','200');

%save("GlobalControllerSimulink_7_days.mat",simData)


%% Plotting a comparision between Matlab and Simulink global implementation
f=figure
addpath("Global controller\Simple Simulink implemtation\Data to compare\")
Vglobal=load('Global controller\Simple Simulink implemtation\Data to compare\Vglobal')
Vglobal=Vglobal.V;
%Makign a plot of the volume
waterLevelmm=simData.logsout{3}.Values.Data;
V=waterLevelmm/1000*c.At;
hold on 
plot(V)
plot(Vglobal(2:end))
yline(c.Vmax)
yline(c.Vmin)
hold off 
ylabel('Volume [m^{3}]')
xlabel('Samples [*]')
grid on
xlim([0 49])
legend('Simulink Volume','Matlab Volume','Constraints')
%% Plotting the input for the two different setups 
f=figure
load('Global controller\Simple Simulink implemtation\Data to compare\uAllGlobal.mat')
uMatlab=uAll(:,2:end);
clear uAll 
uSimulink=simData.logsout{1}.Values.Data;
uSimulink=squeeze(uSimulink)'; 
clf
hold on 
stairs(uMatlab(1:2,:)')
stairs(uSimulink(1:2,:)')
xlim([0 48])
hold off 
legend('Matlab','Matlab','Simulink','Simulink')

