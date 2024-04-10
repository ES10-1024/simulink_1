clear 
clf 
clc
close all 
%Loading in the simulation results 
globalCon=load("200_hours_global_scaled.mat");

consensusCon=load("200_hours_new_simulation.mat"); 
%consensusCon=load("short_ADMM_consensus_test.mat");
c=scaled_standard_constants;
%% 


for index=2:size(globalCon.simData.logsout{1}.Values.Data,3) 
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

subplot(3,1,1)
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

legend('Global Summed pump mass flow','Consensus Summed pump mass flow','Eletricity prices') 
xlim([0 200])
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
xlim([0 200])
grid 
xlabel('Hours scaled') 
set(gca,'fontname','times')


subplot(3,1,3)
hold on 
stairs(globalCon.consumptionPred)
stairs(consumptionNoise)
hold off 
grid 
legend('Predicted consumption','Actual consumption')
xlim([0 200])
ylabel('Mass flow [m^{3}/h]' )
xlabel('Hours scaled') 
set(gca,'fontname','times')


%% Determine the electricity bill: 
for index1=2:size(consensusCon.out.logsout{14}.Values.Data,1)
    index=1; 
    for i=1:c.Nu*c.Nc
        consensusCon.uAll(i,index1)=consensusCon.out.logsout{13}.Values.Data(i,index,index1);
        index=index+1; 
        if index==3 
            index=1; 
        end 
    end 
end 

for index=2:size(globalCon.simData.logsout{1}.Values.Data,3) 
    c.d=globalCon.simData.logsout{4}.Values.Data(:,:,index);
    if index==2 
        [globalCon.Bill(index-1,1), ~]= eletrictyBill(globalCon.simData.logsout{2}.Values.Data(index,:)',globalCon.simData.logsout{6}.Values.Data(:,:,index),c,globalCon.Volume(index-1,1));
        [consensusCon.Bill(index-1,1), ~]= eletrictyBill(consensusCon.uAll(:,index),globalCon.simData.logsout{6}.Values.Data(:,:,index),c,consensusCon.Volume(index-1,1));
    else 
       [globalCon.Bill(index-1,1), ~] = eletrictyBill(globalCon.simData.logsout{2}.Values.Data(index,:)',globalCon.simData.logsout{6}.Values.Data(:,:,index),c,globalCon.Volume(index-1,1));
      globalCon.Bill(index-1,1)=globalCon.Bill(index-1,1)+globalCon.Bill(index-2,1);
       [consensusCon.Bill(index-1,1), ~]= eletrictyBill(consensusCon.uAll(:,index),globalCon.simData.logsout{6}.Values.Data(:,:,index),c,consensusCon.Volume(index-1,1));
        consensusCon.Bill(index-1,1)=consensusCon.Bill(index-1,1)+consensusCon.Bill(index-2,1);
    end 
end 
%%  Plotting the electricity bill: 
hold on 
plot(globalCon.Bill)
plot(consensusCon.Bill)
hold off 
legend('Global','Consensus')
grid 

xlabel('Scaled hours') 
ylabel('Electricity Bill [Euro]') 

%% 
disp("Electricity bill difference is") 
elProDiff=(globalCon.Bill(end,1)-consensusCon.Bill(end,1))/globalCon.Bill(end,1)*100
disp("Procent")