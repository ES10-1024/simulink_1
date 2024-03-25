close

folder = 'log'
load(folder+"\controller.mat");
load(folder+"\pipe20.mat")
load(folder+"\consumer32.mat")
c = scaled_standard_constants;
f= figure();
for l=1:60:con32.p11_32.Time(end)
    current_time = l;%con32.p11_32.Time(end);

    time_last_control = floor(current_time/3600*6)*3600/6;
    k = time_last_control / 600 +1;
    
    clf
    subplot(3,2,1)
    %Electricity pice
    hold on
    
    %Future price
    time_prediction = k:24+k-1;
    stairs(time_prediction,ctrl.El_price_vector.Data(:,:,k))
    %Past price 
    stairs(0:k-1,squeeze(ctrl.El_price_vector.Data(1,:,1:k)))
    
    ylabel('Electricty price [EUR/kWh]')
    xlabel('Time [h]')
    grid
    xlim([0 length(ctrl.mathcal_U.Data)])

    subplot(3,2,2)
    hold on
    %Predicted flow
    for i =1:24
        sum_flow_prediction(i) = sum(ctrl.mathcal_U.Data(i:i+1,:,k));
    end
    stairs(time_prediction,sum_flow_prediction)
    %Past comanded
    sum_flow_commanded = squeeze(ctrl.actuation.Data(1,:,1:k) + ctrl.actuation.Data(2,:,1:k));
    stairs(ctrl.actuation.Time(1:k)/3600*6, sum_flow_commanded)
    %Past flow
    sum_flow_past = pipe20.q2_20 + pipe20.q4_20
    sum_flow_past = getsampleusingtime(sum_flow_past,0,current_time)
    plot(sum_flow_past.Time/3600*6, movmean(squeeze(sum_flow_past.Data)/6,600))
    
    
    
    
    ylabel('Sum of flow [m^3/h_s]')
    grid
    xlim([0 length(ctrl.mathcal_U.Data)])
    
    subplot(3,2,3)
    %Volume in tower
    
    hold on
    %Prediction
    tower_volume(1) = getsampleusingtime(ctrl.volume, time_last_control+1).Data*1000;
    for i=2:25
        tower_volume(i) = tower_volume(i-1) + sum_flow_prediction(i-1)*1000/6 -ctrl.Preducted_demand_vector.Data(i-1,:,k)*1000/6;
    end
    time_tower_volume = k:24+k;
    stairs(time_tower_volume,tower_volume)
    %Past
    plot(ctrl.volume.Time/3600*6,squeeze(ctrl.volume.Data*1000))
    yline(28)
    yline(155)
    ylabel("Volume in tower [L]")
    grid
    xlim([0 length(ctrl.mathcal_U.Data)])
    
    subplot(3,2,4)
    hold on
    
    %Demand prediction
    stairs(time_prediction,ctrl.Preducted_demand_vector.Data(:,:,k))
    %Demand commanded
    stairs(ctrl.Preducted_demand_vector.Time(1:k)/3600*6,squeeze(ctrl.Preducted_demand_vector.Data(1,:,1:k)))
    %Demand past
    sum_consumption = con32.q_32_v1 + con32.q_32_v2;
    sum_consumption = getsampleusingtime(sum_consumption,0,current_time);
    plot(sum_consumption.Time/3600*6,movmean(squeeze(sum_consumption.Data)/6,100))
    
    ylabel('Consumption [m^3/h_s]')
    grid
    legend("Prediction", "Commanded" , "Realized")
   xlim([0 length(ctrl.mathcal_U.Data)])

    fontname(f,"Times")
    exportgraphics(f,folder+"\plot.gif", Append=true)
end