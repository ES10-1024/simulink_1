close
clear 

%folder = 'C:\Users\laula\OneDrive - Aalborg Universitet\10. semester\Log_files\Consensus_ADMM_test_2'
%folder = 'C:\Users\laula\OneDrive - Aalborg Universitet\10. semester\Log_files\Consensus_ADMM_test_2'
folder= 'C:\Users\pppc\Desktop\es1024_2023_git2\log'

ADMM_consensus = false;
load(folder+"\controller.mat");
 
%ctrl.actuation.Data = ctrl.actuation.Data/6;     %Fix position of divsion, BE CAREFUL
 
load(folder+"\pipe20.mat");
load(folder+"\consumer32.mat");
load(folder+"\consumption_ref.mat");
load(folder+"\pump41.mat");
load(folder+"\pump43.mat");
c = scaled_standard_constants;
f= figure('Position', [10 10 900 600]);


for l=100:600:con32.p11_32.Time(end)
    
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
    xlabel('Time [h_s]')
    grid 
    xlim([0 length(ctrl.mathcal_U.Data)])
    ylim([min(min(squeeze(ctrl.El_price_vector.Data))) max(max(squeeze(ctrl.El_price_vector.Data)))])

    subplot(2,2,2)
    time_prediction = k-1:24+k-2;
    hold on
    sum_flow_prediction = zeros(24,1);
    %Predicted flow
    for i =1:24
        if(ADMM_consensus==true)
            sum_flow_prediction(i) = ctrl.mathcal_U.Data(2*i-1,1,k) + ctrl.mathcal_U.Data(2*i,2,k);
        else
            sum_flow_prediction(i) = sum(ctrl.mathcal_U.Data(2*i-1:2*i,:,k));
        end
    end
    stairs(time_prediction,sum_flow_prediction)
    %Past flow
    sum_flow_past = pipe20.q3_20 + pipe20.q4_20;
    sum_flow_past = getsampleusingtime(sum_flow_past,0,current_time);
    plot(sum_flow_past.Time/3600*6, movmean(squeeze(sum_flow_past.Data)/6,600))
    %Past comanded
    if(ADMM_consensus==true)
        sum_flow_commanded = squeeze(ctrl.actuation.Data(1:k,1) + ctrl.actuation.Data(1:k,2));
    else
        sum_flow_commanded = squeeze(ctrl.actuation.Data(1,:,1:k) + ctrl.actuation.Data(2,:,1:k));
    end
    stairs(ctrl.actuation.Time(1:k)/3600*6, sum_flow_commanded)
    
    
    
    
    ylabel('Sum of flow [m^3/h_s]')
    xlabel('Time [h_s]')
    grid
    xlim([0 length(ctrl.mathcal_U.Data)])
    ylim([0 0.1])
    
    subplot(2,2,3)
    %Volume in tower
    
    hold on
    %Prediction
    tower_volume = zeros(1,25);
    %tower_volume(1) = getsampleusingtime(ctrl.volume, time_last_control+1).Data*1000
    tower_volume(1) = interp1(ctrl.volume.Time, squeeze(ctrl.volume.Data) ,time_last_control+1, 'nearest')*1000;
    for i=2:25
        tower_volume(i) = tower_volume(i-1) + sum_flow_prediction(i-1)*1000 -ctrl.Preducted_demand_vector.Data(i-1,:,k)*1000;
    end
    time_tower_volume = k-1:24+k-1;
    plot(time_tower_volume,tower_volume)
    %Past
    volume_past = getsampleusingtime(ctrl.volume,0,current_time);
    plot(volume_past.Time/3600*6,squeeze(volume_past.Data*1000))
    yline(28)
    yline(155)
    ylabel("Volume in tower [L]")
    xlabel('Time [h_s]')
    grid
    xlim([0 length(ctrl.mathcal_U.Data)])
    ylim([20 170])
    
    subplot(2,2,4)
    hold on
    
    %Demand prediction
    stairs(time_prediction,ctrl.Preducted_demand_vector.Data(:,:,k));
    %Demand past
    sum_consumption = con32.q_32_v1 + con32.q_32_v2;
    sum_consumption = getsampleusingtime(sum_consumption,0,current_time);
    plot(sum_consumption.Time/3600*6,movmean(squeeze(sum_consumption.Data)/6,100))
    %Demand commanded
    stairs(con_ref.Time(1:k)/3600*6,squeeze(con_ref.Data(1:k)))
    
    ylabel('Consumption [m^3/h_s]')
    xlabel('Time [h_s]')
    grid
    legend("Prediction", "Measured", "Commanded")
    xlim([0 length(ctrl.mathcal_U.Data)])
    ylim([0 0.1])

    fontname(f,"Times")
    drawnow
    exportgraphics(f,folder+"\plot.gif", Append=true)
end

