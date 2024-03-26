load("pump_station_step_response_and_pipe_resistances\Pipe_resistance_estimation\Flow_combinations_tower_pipe_resistance.mat")

figure
subplot(3,1,1)
hold on
plot(out.pipe_20.p23_20)
plot(out.pipe_20.p33_20)
plot(out.pipe_20.p43_20)
grid
xlabel("Time [s]")
ylabel("Pressure out of pipe module [bar]")

subplot(3,1,2)
hold on
plot(out.pipe_20.q2_20 + out.pipe_20.q3_20 + out.pipe_20.q4_20)


subplot(3,1,3)
hold on
plot(out.pipe_20.q2_20)
plot(out.pipe_20.q3_20)
plot(out.pipe_20.q4_20)


%plot(out.pump_41.pump_41_ctr_1)
%plot(out.pump_43.pump_43_ctr_1)
%plot(out.pump_144.pump_144_ctr_2)
grid
xlabel("Time [s]")
ylabel("Flow though pipe module [m^3/h]")
%%
load("pump_station_step_response_and_pipe_resistances\Pipe_resistance_estimation\Pipe_resistance_into_tower.mat")
p_tower = out.tower_34.tank_34_mm/1000/10; %[bar]
p_drop = out.pipe_20.p43_20 - p_tower

times = 115:60:500;
p_analysis = squeeze(p_drop.Data(times));
q_analysis = squeeze(out.pipe_20.q4_20.Data(times));

f = figure
subplot(2,1,1)
yyaxis left
plot(out.pipe_20.q4_20)
hold on 
plot(times,q_analysis,'X', LineWidth=3, MarkerSize=9)
ylabel("Flow [m^3/h]")
yyaxis right

plot(p_drop)
hold on
plot(times,p_analysis,'X', LineWidth=3, MarkerSize=9)
ylabel("Pressure drop [bar]")
xlabel("Time [s]")
legend("Measuremets", "Used datapoints", Location="southeast")
title("")
grid

subplot(2,1,2)
hold on
plot(out.pump_41.pump_41_ctr_1)
plot(times,out.pump_41.pump_41_ctr_1.Data(times),'X', LineWidth=3, MarkerSize=9, Color=[0 0.4470 0.7410])
xlabel("Time [s]")
ylabel("Pump frequqncy [0-100]")
title("")
grid

fontname(f,'Times')
exportgraphics(f,'pump_station_step_response_and_pipe_resistances\Pipe_resistance_estimation\pipe_resistance_used_data_tower.pdf')

%% Estimate
X = [ones(size(q_analysis)) q_analysis.^2];
a = X\p_analysis
q=0:0.01:1;
y = a(2)*q.^2 + a(1);

f= figure();
hold on

map = get(gca,'ColorOrder');
set(gca,'ColorOrder',[map(1,:); map(1,:)]);

plot(q,y)



plot(q_analysis, p_analysis,'x', LineWidth=3)


legend_string = [   'p_1(u) = ', num2str(a(2),'%.2f'),'u^2 +', num2str(a(1),'%.2f')];
xlabel("Flow [m^3/h]")
ylabel("Pressure drop  [bar]")
legend(legend_string, Location="northwest")
grid 
fontname(f,'Times')
exportgraphics(f,'pump_station_step_response_and_pipe_resistances\Pipe_resistance_estimation\pipe_resistance_tower.pdf')