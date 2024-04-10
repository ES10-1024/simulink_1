clear 
clf 
clc
close all 
%Loading in the simulation results 
globalCon=load("200_hours_global.mat");

consensusCon=load("200_hours_new_simulation.mat"); 
%consensusCon=load("short_ADMM_consensus_test.mat");
c=scaled_standard_constants;
%% 


for index=2:size(globalCon.simData.logsout{1}.Values.Data,3) 
    globalCon.summedMassflow(index-1,1)=globalCon.simData.logsout{1}.Values.Data(1,1,index)+globalCon.simData.logsout{1}.Values.Data(2,1,index);
    consensusCon.summedMassflow(index-1,1)=consensusCon.out.logsout{14}.Values.Data(index,1)+consensusCon.out.logsout{15}.Values.Data(index,1);
end 

ElPrices=squeeze(globalCon.simData.logsout{6}.Values.Data(1,1,2:end));

consumptionNoise=globalCon.simData.logsout{5}.Values.Data(2:end,1); 

consumptionPred=squeeze(globalCon.simData.logsout{4}.Values.Data(1,1,2:end)); 

globalCon.Volume=globalCon.simData.logsout{3}.Values.Data/1000*c.At; 
consensusCon.Volume=consensusCon.out.logsout{17}.Values.Data;

subplot(3,1,1)
hold on
ylabel('Mass flow [m^{3}/h]' )
hold on 
stairs(globalCon.summedMassflow) 
stairs(consensusCon.summedMassflow)
hold off 
yyaxis right 
ylabel('El Prices [Euro/kWh]') 
stairs(ElPrices)
xlabel('Hours scaled') 
grid 

legend('Global Summed pump mass flow','Consensus Summed pump mass flow','Eletricity prices') 
xlim([0 72])
hold off 
set(gca,'fontname','times')


subplot(3,1,2) 
hold on 
plot(globalCon.Volume)
plot(consensusCon.Volume)
yline(c.Vmax)
yline(c.Vmin)
hold off 
legend('Global Volume','Consensus Volume','Constraints')
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
