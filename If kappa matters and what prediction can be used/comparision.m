clear 
clf 
clc
close all 
%Loading in the simulation results 
globalCon=load("Data to compare\200_hours_global_scaled.mat");

Kap0Nc24=load("Data to compare\kappa=0_Nc=16.mat"); 



%consensusCon=load("short_ADMM_consensus_test.mat");
c=scaled_standard_constants;
%% 


for index=2:size(globalCon.simData.logsout{1}.Values.Data,3) 
    globalCon.summedMassflow(index-1,1)=globalCon.simData.logsout{1}.Values.Data(1,1,index)+globalCon.simData.logsout{1}.Values.Data(2,1,index);
    Kap0Nc24.summedMassflow(index-1,1)=Kap0Nc24.simData.logsout{1}.Values.Data(1,1,index)+Kap0Nc24.simData.logsout{1}.Values.Data(2,1,index);
end 

globalCon.ElPrices=squeeze(globalCon.simData.logsout{6}.Values.Data(1,1,2:end));


globalCon.consumptionPred=squeeze(globalCon.simData.logsout{4}.Values.Data(1,1,2:end)); 

globalCon.Volume=globalCon.simData.logsout{3}.Values.Data/1000*c.At; 
Kap0Nc24.Volume=Kap0Nc24.simData.logsout{3}.Values.Data/1000*c.At; 

%% Making plots 
hold on
ylabel('Mass flow [m^{3}/h]' )
hold on 
stairs(globalCon.summedMassflow) 
stairs(Kap0Nc24.summedMassflow)
hold off 
grid 


%% 
plot(globalCon.summedMassflow-Kap0Nc24.summedMassflow)


% %% Determine the electricity bill: 
% 
% 
% for index=2:size(globalCon.simData.logsout{1}.Values.Data,3) 
%     c.d=globalCon.simData.logsout{4}.Values.Data(:,:,index);
%     if index==2 
%         [globalCon.Bill(index-1,1), ~]= eletrictyBill(globalCon.simData.logsout{2}.Values.Data(index,:)',globalCon.simData.logsout{6}.Values.Data(:,:,index),c,globalCon.Volume(index-1,1));
%         [Kap0Nc24.Bill(index-1,1), ~]= eletrictyBill(Kap0Nc24.simData.logsout{2}.Values.Data(index,:)',globalCon.simData.logsout{6}.Values.Data(:,:,index),c,Kap0Nc24.Volume(index-1,1));
%         procentEldiff(index-1,1)=(globalCon.Bill(index-1,1)-Kap0Nc24.Bill(index-1,1))/globalCon.Bill(index-1,1)*100;
%     else 
%        [globalCon.Bill(index-1,1), ~] = eletrictyBill(globalCon.simData.logsout{2}.Values.Data(index,:)',globalCon.simData.logsout{6}.Values.Data(:,:,index),c,globalCon.Volume(index-1,1));
%       globalCon.Bill(index-1,1)=globalCon.Bill(index-1,1)+globalCon.Bill(index-2,1);
%        [Kap0Nc24.Bill(index-1,1), ~] = eletrictyBill(Kap0Nc24.simData.logsout{2}.Values.Data(index,:)',Kap0Nc24.simData.logsout{6}.Values.Data(:,:,index),c,Kap0Nc24.Volume(index-1,1));
%         Kap0Nc24.Bill(index-1,1)=Kap0Nc24.Bill(index-1,1)+Kap0Nc24.Bill(index-2,1);
%        procentEldiff(index-1,1)=(globalCon.Bill(index-1,1)-Kap0Nc24.Bill(index-1,1))/globalCon.Bill(index-1,1)*100;
%     end 
% end 
% %% Making the plot 
% f=figure
% subplot(5,1,1)
% hold on
% ylabel('Mass flow [m^{3}/h]' )
% hold on 
% stairs(globalCon.summedMassflow) 
% stairs(Kap0Nc24.summedMassflow)
% hold off 
% yyaxis right 
% ylabel('El Prices [Euro/kWh]') 
% stairs(globalCon.ElPrices)
% xlabel('Hours scaled') 
% grid 
% 
% legend('Global Summed pump mass flow','Consensus Summed pump mass flow','Eletricity prices') 
% xlim([0 200])
% hold off 
% set(gca,'fontname','times')
% 
% 
% subplot(5,1,2) 
% hold on 
% plot(globalCon.Volume)
% plot(Kap0Nc24.Volume)
% yline(c.Vmax)
% yline(c.Vmin)
% hold off 
% legend('Global Volume','Consensus Volume','Constraints')
% ylabel('Volume [m^{3}]') 
% xlim([0 200])
% grid 
% xlabel('Hours scaled') 
% set(gca,'fontname','times')
% 
% 
% subplot(5,1,3)
% hold on 
% stairs(globalCon.consumptionPred)
% stairs(consumptionNoise)
% hold off 
% grid 
% legend('Predicted consumption','Actual consumption')
% xlim([0 200])
% ylabel('Mass flow [m^{3}/h]' )
% xlabel('Hours scaled') 
% set(gca,'fontname','times')
% 
% subplot(5,1,4) 
% hold on 
% plot(globalCon.Bill)
% plot(Kap0Nc24.Bill)
% hold off 
% legend('Global','Consensus')
% grid 
% xlabel('Scaled hours') 
% ylabel('El Bill [Euro]') 
% set(gca,'fontname','times')
% 
% 
% subplot(5,1,5) 
% hold on 
% plot(procentEldiff)
% yline(0)
% hold off
% grid 
% xlabel('Scaled hours') 
% ylabel('Pro diff el bill')
% 
% set(gca,'fontname','times')
% exportgraphics(f,'consensus_vs_global_simulated.pdf')
% 
% 
% 
% 
% 
% %% 
% disp("Electricity bill difference is") 
% elProDiff=(globalCon.Bill(end,1)-Kap0Nc24.Bill(end,1))/globalCon.Bill(end,1)*100
% disp("Procent")