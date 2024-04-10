%% Describtion
% This short script is utilized to run the simulink simulation  
%% Making alot of clears 
clf 
clc 
clear
close all
%% Adding path and standard values
addpath("Global controller\Simple Simulink implemtation\Functions\")
c=scaled_standard_constants; 
%% 
simHour=72; 
simTime=simHour/c.AccTime*3600; 


c.Tsim=num2str(simTime); 
c.tsSim=num2str(c.ts*3600); 

simData=sim('GlobalMPC.slx',"StartTime",'0',"StopTime",c.Tsim,'FixedStep','200');

%save("GlobalControllerSimulink_7_days.mat",simData)
%% 
clf 
for index=2:size(simData.logsout{1}.Values.Data,3) 
summedMassflow(index-1,1)=simData.logsout{1}.Values.Data(1,1,index)+simData.logsout{1}.Values.Data(2,1,index);
end 

ElPrices=squeeze(simData.logsout{6}.Values.Data(1,1,2:end));

consumptionNoise=simData.logsout{5}.Values.Data(2:end,1); 

consumptionPred=squeeze(simData.logsout{4}.Values.Data(1,1,2:end)); 

Volume=simData.logsout{3}.Values.Data/1000*c.At; 


f=figure

subplot(3,1,1)
hold on
ylabel('Mass flow [m^{3}/h]' )
stairs(summedMassflow) 
yyaxis right 
ylabel('El Prices [Euro/kWh]') 
stairs(ElPrices)
xlabel('Hours scaled') 
grid 

legend('Summed pump mass flow','Eletricity prices') 
xlim([0 72])
hold off 
set(gca,'fontname','times')


subplot(3,1,2) 
hold on 
plot(Volume)
yline(c.Vmax)
yline(c.Vmin)
hold off 
legend('Volume','Constraints')
ylabel('Volume [m^{3}]') 
xlim([0 72])
grid 
xlabel('Hours scaled') 
set(gca,'fontname','times')


subplot(3,1,3)
hold on 
stairs(consumptionPred)
stairs(consumptionNoise)
hold off 
grid 
legend('Predicted consumption','Actual consumption')
xlim([0 72])
ylabel('Mass flow [m^{3}/h]' )
xlabel('Hours scaled') 
set(gca,'fontname','times')




exportgraphics(f,'global_controller_not_scaled_with_disturbance.pdf')


%% 
f=figure

subplot(3,1,1) 
hold on 
plot(Volume)
yline(c.Vmax)
yline(c.Vmin)
hold off 
legend('Volume','Constraints')
ylabel('Volume [m^{3}]') 
xlim([0 72])
grid 
xlabel('Hours scaled') 

set(gca,'fontname','times')
%exportgraphics(f,'global_controller_volume_not_scaled_without_disturbance.pdf')



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
%xlim([0 49])
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

