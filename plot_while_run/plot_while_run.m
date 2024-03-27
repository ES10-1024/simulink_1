close

folder = 'C:\Users\pppc\Desktop\es1024_2023_git2\log'
load(folder+"\controller.mat");
load(folder+"\pipe20.mat")
load(folder+"\consumer32.mat")
load(folder+"\consumption_ref.mat")
load(folder+"\pump41.mat")
load(folder+"\pump43.mat")
c = scaled_standard_constants;
f= figure('Position', [10 10 900 600]);

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
    xlim([0 length(ctrl.mathcal_U.Data)])
    ylim([0 0.2])

    subplot(2,2,2)
    time_prediction = k-1:24+k-2;
    hold on
    sum_flow_prediction = zeros(24,1);
    %Predicted flow
    for i =1:24
        sum_flow_prediction(i) = sum(ctrl.mathcal_U.Data(2*i-1:2*i,:,k));
    end
    stairs(time_prediction,sum_flow_prediction)
    %Past comanded
    sum_flow_commanded = squeeze(ctrl.actuation.Data(1,:,1:k) + ctrl.actuation.Data(2,:,1:k));
    stairs(ctrl.actuation.Time(1:k)/3600*6, sum_flow_commanded)
    %Past flow
    sum_flow_past = pipe20.q3_20 + pipe20.q4_20;
    sum_flow_past = getsampleusingtime(sum_flow_past,0,current_time);
    plot(sum_flow_past.Time/3600*6, movmean(squeeze(sum_flow_past.Data)/6,600))
    
    
    
    
    ylabel('Sum of flow [m^3/h_s]')
    grid
    xlim([0 length(ctrl.mathcal_U.Data)])
    ylim([0 0.1])
    
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
    stairs(time_tower_volume,tower_volume)
    %Past
    volume_past = getsampleusingtime(ctrl.volume,0,current_time);
    plot(volume_past.Time/3600*6,squeeze(volume_past.Data*1000),Color=[0.9290 0.6940 0.1250])
    yline(28)
    yline(155)
    ylabel("Volume in tower [L]")
    grid
    xlim([0 length(ctrl.mathcal_U.Data)])
    ylim([20 170])
    
    subplot(2,2,4)
    hold on
    
    %Demand prediction
    stairs(time_prediction,ctrl.Preducted_demand_vector.Data(:,:,k))
    %Demand commanded
    stairs(con_ref.Time(1:k)/3600*6,squeeze(con_ref.Data(1:k)))
    %Demand past
    sum_consumption = con32.q_32_v1 + con32.q_32_v2;
    sum_consumption = getsampleusingtime(sum_consumption,0,current_time);
    plot(sum_consumption.Time/3600*6,movmean(squeeze(sum_consumption.Data)/6,100))
    
    ylabel('Consumption [m^3/h_s]')
    grid
    legend("Prediction", "Commanded" , "Realized")
    xlim([0 length(ctrl.mathcal_U.Data)])
    ylim([0 0.1])

    fontname(f,"Times")
    drawnow
    %exportgraphics(f,folder+"\plot.gif", Append=true)
end
%% Check pump flows
figure()
subplot(3,1,1)
hold on
plot(pump41.pump_41_ctrl_1.Time/3600*6,pump41.pump_41_ctrl_1.Data)
plot(pump43.pump_43_ctrl_3.Time/3600*6,squeeze(pump43.pump_43_ctrl_3.Data))
subplot(3,1,2)
hold on
sum_flow_commanded = squeeze(ctrl.actuation.Data(1,:,1:k));
stairs(ctrl.actuation.Time(1:k)/3600*6, sum_flow_commanded)
%Past flow
sum_flow_past = pipe20.q2_20;
sum_flow_past = getsampleusingtime(sum_flow_past,0,current_time);
plot(sum_flow_past.Time/3600*6, movmean(squeeze(sum_flow_past.Data)/6,600))


subplot(3,1,3)
hold on
sum_flow_commanded = squeeze(ctrl.actuation.Data(2,:,1:k));
stairs(ctrl.actuation.Time(1:k)/3600*6, sum_flow_commanded)
%Past flow
sum_flow_past = pipe20.q3_20;
sum_flow_past = getsampleusingtime(sum_flow_past,0,current_time);
plot(sum_flow_past.Time/3600*6, movmean(squeeze(sum_flow_past.Data)/6,600))

sum_flow_past = pipe20.q1_20;
sum_flow_past = getsampleusingtime(sum_flow_past,0,current_time);
plot(sum_flow_past.Time/3600*6, movmean(squeeze(sum_flow_past.Data)/6,600))
