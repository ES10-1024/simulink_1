close
clear 

%% Loading in the data needed, all of these is on onedrive and NOT github! 
folder = 'C:\Users\is123\Documents\GitHub\P10_Simulink_V2\Global controller\7 days test\Lab ADMM'

%Consensus ADMM data
load(folder+"\controller.mat");
load(folder+"\pipe20.mat");
load(folder+"\consumer32.mat");
load(folder+"\consumption_ref.mat");
load(folder+"\pump41.mat");
load(folder+"\pump43.mat");

%Making a struct of the data: 
ADMM.ctrl=ctrl; 
ADMM.pipe20=pipe20; 
ADMM.con32=con32; 
ADMM.con_ref=con_ref; 
ADMM.pump41=pump41;
ADMM.pump41=pump43;

%Link: https://aaudk-my.sharepoint.com/personal/llaur19_student_aau_dk/_layouts/15/onedrive.aspx?e=5%3A691d3ed844e74bea9acc942f22505a6b&sharingv2=true&fromShare=true&at=9&cid=6b5fb676%2Dde35%2D4dfa%2Db995%2D77d14df8f194&FolderCTID=0x0120009878F72CDD1F8D4F9D8FC8AAF16F760F&id=%2Fpersonal%2Fllaur19%5Fstudent%5Faau%5Fdk%2FDocuments%2F10%2E%20semester%2FLog%5Ffiles%2FEaster%20test
folder = 'C:\Users\is123\Documents\GitHub\P10_Simulink_V2\Global controller\7 days test\Lab global'
load(folder+"\controller.mat");
load(folder+"\pipe20.mat")
load(folder+"\consumer32.mat")
load(folder+"\consumption_ref.mat")
load(folder+"\pump41.mat")
load(folder+"\pump43.mat")

%Loading in simulated data 
load("GlobalControllerSimulink_7_days.mat") 
load("consensus_ADMM.mat");
ADMM.sim=out;
clear out

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
    xlim([0 15])
    %xlim([0 length(ctrl.mathcal_U.Data)])    
    ylim([0 0.2])

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
    
    %ADMM acutation: 
    timeADMM=0:size(ADMM.ctrl.actuation.Data,1)-1;
    sum_flow_ADMM_commanded =(ADMM.ctrl.actuation.Data(:,1)+ADMM.ctrl.actuation.Data(:,2))/6;  %squeeze(ADMM.ctrl.actuation.Data(1,:,1:k) + ADMM.ctrl.actuation.Data(2,:,1:k));
    stairs(timeADMM,sum_flow_ADMM_commanded)
    %Simulated Global 
    time=0:216;
    sim_flow=squeeze(sum(simData.logsout{1}.Values.Data));
    stairs(time,sim_flow(1:217,1))
    
    %Simulated ADMM 
    timeSimADMM=0:size(ADMM.sim.logsout{15}.Values.data,1)-1;
    sim_flow_ADMM=ADMM.sim.logsout{14}.Values.data+ADMM.sim.logsout{15}.Values.data;
    stairs(timeSimADMM,sim_flow_ADMM)

    legend('Lab Global','Lab ADMM','Sim Global','Sim Consensus')

    
    
    ylabel('Sum of flow [m^3/h_s]')
    grid
    xlim([0 15])
    %xlim([0 length(ctrl.mathcal_U.Data)])
    ylim([0 0.1])
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
    %Past ADMM 
    volume_past_ADMM = getsampleusingtime(ADMM.ctrl.volume,0,current_time);
    plot(volume_past_ADMM.Time/3600*6,squeeze(volume_past_ADMM.Data*1000))

    %Global Simulated water volume
    simVolume=(simData.logsout{3}.Values.Data)/1000*(c.At)*1000;
    plot(time,simVolume(1:217,1)) 

    %ADMM Simulated water volume
    simVolumeADMM=(ADMM.sim.logsout{11}.Values.Data)/1000*(c.At)*1000;
    plot(timeSimADMM,simVolumeADMM) 


    yline(28)
    yline(155)
    ylabel("Volume in tower [L]")
    grid
    xlim([0 15])
    %xlim([0 length(ctrl.mathcal_U.Data)])
    
    ylim([20 170])
    title("Volume in Tower [L]")

    legend('Lab Global','Lab ADMM','Simulation')

    subplot(2,2,4)
    hold on
    
    %Demand prediction
    %stairs(time_prediction,ctrl.Preducted_demand_vector.Data(:,:,k))

    %Demand past
    sum_consumption = con32.q_32_v1 + con32.q_32_v2;
    sum_consumption = getsampleusingtime(sum_consumption,0,current_time);
    plot(sum_consumption.Time/3600*6,movmean(squeeze(sum_consumption.Data)/6,100))
    %Demand past Consensus ADMM 
    sum_consumption_ADMM = ADMM.con32.q_32_v1 + ADMM.con32.q_32_v2;
    sum_consumption_ADMM = getsampleusingtime(sum_consumption_ADMM,0,current_time);
    plot(sum_consumption_ADMM.Time/3600*6,movmean(squeeze(sum_consumption_ADMM.Data)/6,100))

    stairs(time,simData.logsout{5}.Values.Data(1:217,1))
    %Demand commanded
    %stairs(con_ref.Time(1:k)/3600*6,squeeze(con_ref.Data(1:k)))

    ylabel('Consumption [m^3/h_s]')
    grid
    %legend("Prediction", "Commanded" , "Realized")
    legend("Commanded Simulation" , "Realized global", "Realized ADMM")
    xlim([0 15])

    %xlim([0 length(ctrl.mathcal_U.Data)])
    ylim([0 0.1])

    fontname(f,"Times")
    drawnow
    %exportgraphics(f,folder+"\plot.gif", Append=true)
end

%% Determing the eletricity bill for all the cases: 

ADMMsimInputs=[ADMM.sim.logsout{14}.Values.data,ADMM.sim.logsout{15}.Values.data];
clear index
Je=simData.logsout{6}.Values.Data;
TimeOfDay=1;
for index=1:size(timeADMM,2)
    c.d=simData.logsout{5}.Values.Data(index,1);
    if index==1 
        simGlobalBill(index)=eletrictyBill(simData.logsout{1}.Values.Data(:,:,index),Je(:,1,index),c,simVolume(index,1)/1000); 
        
        simADMMBill(index)=eletrictyBill(ADMMsimInputs(index,:)',Je(:,1,index),c,simVolumeADMM(index,1)/1000);
    
        labGlobalBill(index)=eletrictyBill(ctrl.actuation.Data(:,:,index),Je(:,1,index),c, getdatasamples(volume_past,TimeOfDay));
    
        labADMMBill(index)=eletrictyBill(ADMM.ctrl.actuation.Data(index,:)'/6,Je(:,1,index),c,getdatasamples(volume_past_ADMM,TimeOfDay));


    else
        simGlobalBill(index)=eletrictyBill(simData.logsout{1}.Values.Data(:,:,index),Je(:,1,index),c,simVolume(index,1)/1000)+simGlobalBill(index-1); 
    
        simADMMBill(index)=eletrictyBill(ADMMsimInputs(index,:)',Je(:,1,index),c,simVolumeADMM(index,1)/1000)+simADMMBill(index-1);
    
       labGlobalBill(index)=eletrictyBill(ctrl.actuation.Data(:,:,index),Je(:,1,index),c, getdatasamples(volume_past,TimeOfDay))+labGlobalBill(index-1);
    
        labADMMBill(index)=eletrictyBill(ADMM.ctrl.actuation.Data(index,:)'/6,Je(:,1,index),c,getdatasamples(volume_past_ADMM,TimeOfDay))+labADMMBill(index-1); 
    end 
    TimeOfDay=TimeOfDay+600;
end 

%% 
figure(2)
hold on
plot(simGlobalBill)
plot(simADMMBill)
plot(labGlobalBill)
plot(labADMMBill)
grid on
hold off 
legend("Sim Global","Sim ADMM"," lab Global","lab ADMM")

%% 
clear index
for index=1:size(simGlobalBill,2)
    % ProcentDiffGlobal(index)=(simGlobalBill(index)-labGlobalBill(index))/simGlobalBill(index); 
    % ProcentDiffADMMSim(index)= (simGlobalBill(index)-simADMMBill(index))/simGlobalBill(index);
    % ProcentDiffADMMLab(index)= (simGlobalBill(index)-labADMMBill(index))/simGlobalBill(index);
    ProcentDiff(index)=(labGlobalBill(index)-labADMMBill(index))/labGlobalBill(index)*100;
end 
figure(3)
plot(ProcentDiff)
grid 





