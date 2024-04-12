close
clear 
%% Data can be achived from: 
%https://aaudk-my.sharepoint.com/personal/llaur19_student_aau_dk/_layouts/15/onedrive.aspx?e=5%3A691d3ed844e74bea9acc942f22505a6b&sharingv2=true&fromShare=true&at=9&cid=6b5fb676%2Dde35%2D4dfa%2Db995%2D77d14df8f194&FolderCTID=0x0120009878F72CDD1F8D4F9D8FC8AAF16F760F&id=%2Fpersonal%2Fllaur19%5Fstudent%5Faau%5Fdk%2FDocuments%2F10%2E%20semester%2FLog%5Ffiles%2Fscaled%5Fglobal%5Fcontroller%5Fkappa%3D450
%% Loading in the data needed, all of these is on onedrive and NOT github! 


%Link: https://aaudk-my.sharepoint.com/personal/llaur19_student_aau_dk/_layouts/15/onedrive.aspx?e=5%3A691d3ed844e74bea9acc942f22505a6b&sharingv2=true&fromShare=true&at=9&cid=6b5fb676%2Dde35%2D4dfa%2Db995%2D77d14df8f194&FolderCTID=0x0120009878F72CDD1F8D4F9D8FC8AAF16F760F&id=%2Fpersonal%2Fllaur19%5Fstudent%5Faau%5Fdk%2FDocuments%2F10%2E%20semester%2FLog%5Ffiles%2FEaster%20test
folder = 'C:\Users\is123\Documents\GitHub\P10_Simulink_V2\Lab test\Global test with kappa\Data'
load(folder+"\controller.mat");
load(folder+"\pipe20.mat")
load(folder+"\consumer32.mat")
load(folder+"\consumption_ref.mat")
load(folder+"\pump41.mat")
load(folder+"\pump43.mat")

%Loading in global simulated data 
load("global_mpc_sim_kappa=450") 

%%
c = scaled_standard_constants;
f= figure('Position', [10 10 900 600]);
figure(1)
for l=con32.p11_32.Time(end)%600:100:con32.p11_32.Time(end)
    %l=600*78-120
    l/con32.p11_32.Time(end)*100
    current_time = l;%con32.p11_32.Time(end);

    time_last_control = floor(current_time/3600*6)*3600/6;
    k = time_last_control / 600 +1;
    
    clf
    subplot(2,2,1)
    %Electricity pice
    hold on
    
    %Future price
    time_prediction = k:24+k-1;
    stairs(time_prediction,ctrl.El_price_vector.Data(:,:,k));
    %Past price 
    stairs(1:k,squeeze(ctrl.El_price_vector.Data(1,:,1:k)));
    
    ylabel('Electricty price [EUR/kWh]')
    xlabel('Time [h]')
    grid 
    xlim([0 150])
    %xlim([0 length(ctrl.mathcal_U.Data)])    
    ylim([0 0.2])

    title('Eletricity price')

    subplot(2,2,2)
    time_prediction = k-1:24+k-2;
    hold on
    sum_flow_prediction = zeros(24,1);
    %Predicted flow
    for i =1:24
        sum_flow_prediction(i) = sum(ctrl.mathcal_U.Data(2*i-1:2*i,:,k));
    end
    %stairs(time_prediction,sum_flow_prediction)
    %Past comanded
    sum_flow_commanded = squeeze(ctrl.actuation.Data(1,:,1:k) + ctrl.actuation.Data(2,:,1:k));
    
    
    stairs(ctrl.actuation.Time(1:k)/3600*6, sum_flow_commanded)



    %Past flow
    sum_flow_past = pipe20.q3_20 + pipe20.q4_20;
    sum_flow_past = getsampleusingtime(sum_flow_past,0,current_time);
    %plot(sum_flow_past.Time/3600*6, movmean(squeeze(sum_flow_past.Data)/6,600))
   

    %Simulated Global 
    
    sim_flow=squeeze(sum(simData.logsout{1}.Values.Data));
    stairs(sim_flow)
    

    legend('Lab Global','Sim Global')

    
    
    ylabel('Sum of flow [m^3/h_s]')
    grid
    xlim([1 150])
    %xlim([0 length(ctrl.mathcal_U.Data)])
    ylim([0 0.6])
    title("Summed Acutation [m^3/h_s]")


    subplot(2,2,3)
    %Volume in tower
    hold on
    %Prediction
    tower_volume = zeros(1,25);
    tower_volume(1) = getsampleusingtime(ctrl.volume, time_last_control+1).Data*1000;
    for i=2:25
        tower_volume(i) = tower_volume(i-1) + sum_flow_prediction(i-1)*1000 -ctrl.Preducted_demand_vector.Data(i-1,:,k)*1000;
    end
    time_tower_volume = k-1:24+k-1;
    %stairs(time_tower_volume,tower_volume)
    %Past Global 
    volume_past = getsampleusingtime(ctrl.volume,0,current_time);
    plot(volume_past.Time/3600*6,squeeze(volume_past.Data*1000))

    %Global Simulated water volume
    simVolume=(simData.logsout{3}.Values.Data)/1000*(c.At)*1000;
    plot(simVolume) 


    yline(28)
    yline(155)
    ylabel("Volume in tower [L]")
    grid
    xlim([1 150])
    %xlim([0 length(ctrl.mathcal_U.Data)])
    
    ylim([20 170])
    title("Volume in Tower [L]")

    legend('Lab Global','Sim Global')
    
        title('Volume in tower [L]')

    subplot(2,2,4)
    hold on
    
    %Demand prediction
    %stairs(time_prediction,ctrl.Preducted_demand_vector.Data(:,:,k))

    %Demand past
    sum_consumption = con32.q_32_v1 + con32.q_32_v2;
    sum_consumption = getsampleusingtime(sum_consumption,0,current_time);
    plot(sum_consumption.Time/3600*6,movmean(squeeze(sum_consumption.Data)/6,100))


    stairs(simData.logsout{5}.Values.Data)
    %Demand commanded
    %stairs(con_ref.Time(1:k)/3600*6,squeeze(con_ref.Data(1:k)))

    ylabel('Consumption [m^3/h_s]')
    grid
    %legend("Prediction", "Commanded" , "Realized")
    legend("Commanded Simulation" , "Realized global")
    xlim([1 150])

    %xlim([0 length(ctrl.mathcal_U.Data)])
    ylim([0 0.1])
        title('Consumption')


    fontname(f,"Times")
    drawnow
    %exportgraphics(f,folder+"\plot.gif", Append=true)
end

%% Determing the eletricity bill for all the cases: 
% % 
% % ADMMsimInputs=[ADMM.sim.logsout{14}.Values.data,ADMM.sim.logsout{15}.Values.data];
% % clear index
% % Je=simData.logsout{6}.Values.Data;
% % TimeOfDay=1;
% % for index=1:size(timeADMM,2)
% %     c.d=simData.logsout{5}.Values.Data(index,1);
% %     if index==1 
% %         simGlobalBill(index)=eletrictyBill(simData.logsout{1}.Values.Data(:,:,index),Je(:,1,index),c,simVolume(index,1)/1000); 
% % 
% %         simADMMBill(index)=eletrictyBill(ADMMsimInputs(index,:)',Je(:,1,index),c,simVolumeADMM(index,1)/1000);
% % 
% %         labGlobalBill(index)=eletrictyBill(ctrl.actuation.Data(:,:,index),Je(:,1,index),c, getdatasamples(volume_past,TimeOfDay));
% % 
% %         labADMMBill(index)=eletrictyBill(ADMM.ctrl.actuation.Data(index,:)'/6,Je(:,1,index),c,getdatasamples(volume_past_ADMM,TimeOfDay));
% % 
% % 
% %     else
% %         simGlobalBill(index)=eletrictyBill(simData.logsout{1}.Values.Data(:,:,index),Je(:,1,index),c,simVolume(index,1)/1000)+simGlobalBill(index-1); 
% % 
% %         simADMMBill(index)=eletrictyBill(ADMMsimInputs(index,:)',Je(:,1,index),c,simVolumeADMM(index,1)/1000)+simADMMBill(index-1);
% % 
% %        labGlobalBill(index)=eletrictyBill(ctrl.actuation.Data(:,:,index),Je(:,1,index),c, getdatasamples(volume_past,TimeOfDay))+labGlobalBill(index-1);
% % 
% %         labADMMBill(index)=eletrictyBill(ADMM.ctrl.actuation.Data(index,:)'/6,Je(:,1,index),c,getdatasamples(volume_past_ADMM,TimeOfDay))+labADMMBill(index-1); 
% %     end 
% %     TimeOfDay=TimeOfDay+600;
% % end 
% % 
% % %% 
% % figure(2)
% % hold on
% % plot(simGlobalBill)
% % plot(simADMMBill)
% % plot(labGlobalBill)
% % plot(labADMMBill)
% % grid on
% % hold off 
% % legend("Sim Global","Sim ADMM"," lab Global","lab ADMM",'Location','south')
% % xlabel('Time [hr]')
% % ylabel('Eletricity bill [Euros]') 
% % title('Eletricity bill [Euros]')
% % 
% % %% 
% % clear index
% % for index=1:size(simGlobalBill,2)
% %     % ProcentDiffGlobal(index)=(simGlobalBill(index)-labGlobalBill(index))/simGlobalBill(index); 
% %     % ProcentDiffADMMSim(index)= (simGlobalBill(index)-simADMMBill(index))/simGlobalBill(index);
% %     % ProcentDiffADMMLab(index)= (simGlobalBill(index)-labADMMBill(index))/simGlobalBill(index);
% %     ProcentDiff(index)=(labGlobalBill(index)-labADMMBill(index))/labGlobalBill(index)*100;
% % end 
% % figure(3)
% % plot(ProcentDiff)
% % grid 
% % xlabel('Time [hr]')
% % ylabel('Procent Wise  difference in cost function lab global and ADMM')
% % title('Procent Wise  difference in cost function lab global and ADMM')




