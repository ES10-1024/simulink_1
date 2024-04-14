clear 
clf 
clc
close all 
%Loading in the simulation results 
globalCon=load("200_hours_global_scaled.mat");

%globalCon=load("200_hours_global_with_no_kappa_no_el_scaled_Nc=16.mat");
%globalCon=load("200_hours_global_with_kappa_no_el_scaled.mat");


%consensusCon=load("varying_rho_200_hours_el_scaled_rho_start1_mu=10_tau=2_K=0_Nc=16.mat");
consensusCon=load("varying_rho_200_hours_el_scaled_rho_start1_mu=10_tau=2_K=0_Nc=16.mat");
%consensusCon=load("200_hours_consensus_with_kappa.mat"); 
%consensusCon=load("short_ADMM_consensus_test.mat");
c=scaled_standard_constants;
clf 
clc
close all 
%% 


for index=2:size(consensusCon.out.logsout{14}.Values.Data,1)-1
    globalCon.summedMassflow(index-1,1)=globalCon.simData.logsout{1}.Values.Data(1,1,index)+globalCon.simData.logsout{1}.Values.Data(2,1,index);
    consensusCon.summedMassflow(index-1,1)=consensusCon.out.logsout{14}.Values.Data(index,1)+consensusCon.out.logsout{15}.Values.Data(index,1);
end 

globalCon.ElPrices=squeeze(globalCon.simData.logsout{6}.Values.Data(1,1,2:end));
consensusCon.ElPrices=squeeze(consensusCon.out.logsout{6}.Values.Data(1,1,2:end));

consumptionNoise=globalCon.simData.logsout{5}.Values.Data(2:end,1); 

globalCon.consumptionPred=squeeze(globalCon.simData.logsout{4}.Values.Data(1,1,2:end)); 
consensusCon.consumptionPred=squeeze(consensusCon.out.logsout{4}.Values.Data(1,1,2:end));

globalCon.Volume=globalCon.simData.logsout{3}.Values.Data/1000*c.At; 
consensusCon.Volume=consensusCon.out.logsout{17}.Values.Data(2:end,1);
%% Determine the electricity bill: 
for index1=2:size(consensusCon.out.logsout{14}.Values.Data,1)-1
    index=1; 
    for i=1:consensusCon.c.Nu*consensusCon.c.Nc
        consensusCon.uAll(i,index1)=consensusCon.out.logsout{13}.Values.Data(i,index,index1);
        index=index+1; 
        if index==3 
            index=1; 
        end 
    end 
end 

for index=2:size(consensusCon.out.logsout{14}.Values.Data,1)-1 
    c.d=globalCon.simData.logsout{4}.Values.Data(:,:,index);
    [ElPrices] = ElectrictyPrices(index*c.ts);
    if index==2 
        [globalCon.Bill(index-1,1)]= eletrictyBillV2(globalCon.simData.logsout{2}.Values.Data(index,:)',ElPrices,c,globalCon.Volume(index-1,1));
        [consensusCon.Bill(index-1,1)]= eletrictyBillV2(consensusCon.uAll(:,index),ElPrices,c,consensusCon.Volume(index-1,1));
        procentEldiff(index-1,1)=(consensusCon.Bill(index-1,1)-globalCon.Bill(index-1,1))/globalCon.Bill(index-1,1)*100;
    else 
       [globalCon.Bill(index-1,1)] = eletrictyBillV2(globalCon.simData.logsout{2}.Values.Data(index,:)',ElPrices,c,globalCon.Volume(index-1,1));
      globalCon.Bill(index-1,1)=globalCon.Bill(index-1,1)+globalCon.Bill(index-2,1);
       [consensusCon.Bill(index-1,1)]= eletrictyBillV2(consensusCon.uAll(:,index),ElPrices,c,consensusCon.Volume(index-1,1));
        consensusCon.Bill(index-1,1)=consensusCon.Bill(index-1,1)+consensusCon.Bill(index-2,1);
       procentEldiff(index-1,1)=(consensusCon.Bill(index-1,1)-globalCon.Bill(index-1,1))/globalCon.Bill(index-1,1)*100;
    end 
end 
%% Making the plot 
f=figure
subplot(5,1,1)
hold on
ylabel('Mass flow [m^{3}/h]' )
hold on 
stairs(globalCon.summedMassflow) 
stairs(consensusCon.summedMassflow)
hold off 
yyaxis right 
ylabel('El Prices [Euro/kWh]') 
stairs(globalCon.ElPrices)
xlabel('Hours scaled') 
grid 

legend('Global Summed pump mass flow','Consensus Summed pump mass flow','Eletricity prices','Location','bestoutside') 
xlim([0 200])
hold off 
set(gca,'fontname','times')


subplot(5,1,2) 
hold on 
plot(globalCon.Volume)
plot(consensusCon.Volume)
yline(c.Vmax)
yline(c.Vmin)
hold off 
legend('Global Volume','Consensus Volume','Constraints','Location','bestoutside')
ylabel('Volume [m^{3}]') 
xlim([0 200])
grid 
xlabel('Hours scaled') 
set(gca,'fontname','times')


subplot(5,1,3)
hold on 
stairs(globalCon.consumptionPred)
stairs(consumptionNoise)
hold off 
grid 
legend('Predicted consumption','Actual consumption','Location','bestoutside')
xlim([0 200])
ylabel('Mass flow [m^{3}/h]' )
xlabel('Hours scaled') 
set(gca,'fontname','times')

subplot(5,1,4) 
hold on 
plot(globalCon.Bill)
plot(consensusCon.Bill)
hold off 
legend('Global','Consensus','Location','bestoutside')
grid 
xlabel('Scaled hours') 
ylabel('El Bill [Euro]') 
set(gca,'fontname','times')


subplot(5,1,5) 
hold on 
plot(procentEldiff)
yline(0)
hold off
grid 
xlabel('Scaled hours') 
ylabel('Pro diff el bill')

set(gca,'fontname','times')
exportgraphics(f,'consensus_Nc=16_K=0_vs_global_simulated.pdf')





%% 
disp("Electricity bill difference is") 
elProDiff=(consensusCon.Bill(end,1)-globalCon.Bill(end,1))/globalCon.Bill(end,1)*100
disp("Procent")