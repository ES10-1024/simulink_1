load("pump_station_step_response_and_pipe_resistances\Pipe_resistance_estimation\test_pipe_resistance_41_ 2_m_tower.mat")
out41 = out;
load("pump_station_step_response_and_pipe_resistances\Pipe_resistance_estimation\test_pipe_resistance_43_ 2_m_tower.mat")
out43 = out;
load("pump_station_step_response_and_pipe_resistances\Pipe_resistance_estimation\test_pipe_resistance_144_ 2_m_tower.mat")
out144 = out;


%% pump stattion 41
p_drop41 = (out41.pipe_20.p41_20-out41.pipe_20.p43_20)

times41 =50:60:length(out41.pipe_20.q4_20.Data)-100
q_analysis41 = squeeze(out41.pipe_20.q4_20.Data(times41));
p_analysis41 = squeeze(p_drop41.Data(times41));


f = figure
subplot(2,1,1)
yyaxis left
plot(out41.pipe_20.q4_20)
hold on 
plot(times41,q_analysis41,'X', LineWidth=3, MarkerSize=9)
ylabel("Flow [m^3/h]")
yyaxis right

plot(p_drop41)
hold on
plot(times41,p_analysis41,'X', LineWidth=3, MarkerSize=9)
ylabel("Pressure drop [bar]")
xlabel("Time [s]")
legend("Measuremets", "Used datapoints", Location="southeast")
title("")
grid

subplot(2,1,2)
hold on
plot(out41.pump_41.pump_41_ctr_1)
plot(times41,out41.pump_41.pump_41_ctr_1.Data(times41),'X', LineWidth=3, MarkerSize=9, Color=[0 0.4470 0.7410])
xlabel("Time [s]")
ylabel("Pump frequqncy [0-100]")
title("")
grid

fontname(f,'Times')
exportgraphics(f,'pump_station_step_response_and_pipe_resistances\Pipe_resistance_estimation\pipe_resistance_used_data_module41.pdf')
%% Pump station 43
p_drop43 = (out43.pipe_20.p21_20-out43.pipe_20.p23_20)

times43 =50:60:length(out43.pipe_20.q2_20.Data)-50
q_analysis43 = squeeze(out43.pipe_20.q2_20.Data(times43));
p_analysis43 = squeeze(p_drop43.Data(times43));


f = figure
subplot(2,1,1)
yyaxis left
plot(out43.pipe_20.q2_20)
hold on 
plot(times43,q_analysis43,'X', LineWidth=3, MarkerSize=9)
ylabel("Flow [m^3/h]")
yyaxis right

plot(p_drop43)
hold on
plot(times43,p_analysis43,'X', LineWidth=3, MarkerSize=9)
ylabel("Pressure drop [bar]")
xlabel("Time [s]")
legend("Measuremets", "Used datapoints", Location="southeast")
title("")
grid

subplot(2,1,2)
hold on
plot(out43.pump_43.pump_43_ctrl_2)
plot(times43,out43.pump_43.pump_43_ctrl_2.Data(times43),'X', LineWidth=3, MarkerSize=9, Color=[0 0.4470 0.7410])
xlabel("Time [s]")
ylabel("Pump frequqncy [0-100]")
title("")
grid

fontname(f,'Times')
exportgraphics(f,'pump_station_step_response_and_pipe_resistances\Pipe_resistance_estimation\pipe_resistance_used_data_module43.pdf')

%% Pump station 144
p_drop144 = (out144.pipe_20.p31_20-out144.pipe_20.p33_20)

times144 =50:60:length(out144.pipe_20.q3_20.Data);
q_analysis144 = squeeze(out144.pipe_20.q3_20.Data(times144));
p_analysis144 = squeeze(p_drop144.Data(times144));


f = figure
subplot(2,1,1)
yyaxis left
plot(out144.pipe_20.q3_20)
hold on 
plot(times144,q_analysis144,'X', LineWidth=3, MarkerSize=9)
ylabel("Flow [m^3/h]")
yyaxis right

plot(p_drop144)
hold on
plot(times144,p_analysis144,'X', LineWidth=3, MarkerSize=9)
ylabel("Pressure drop [bar]")
xlabel("Time [s]")
legend("Measuremets", "Used datapoints", Location="southeast")
title("")
grid

subplot(2,1,2)
hold on
plot(out144.pump_144.pump_144_ctr_2)
plot(times144,out144.pump_144.pump_144_ctr_2.Data(times144),'X', LineWidth=3, MarkerSize=9, Color=[0 0.4470 0.7410])
xlabel("Time [s]")
ylabel("Pump frequqncy [0-100]")
title("Data Missing Fault in logging system")
grid

fontname(f,'Times')
exportgraphics(f,'pump_station_step_response_and_pipe_resistances\Pipe_resistance_estimation\pipe_resistance_used_data_module144.pdf')

%% Scond order apporximation


X41 = [ones(size(q_analysis41)) q_analysis41.^2];
a41 = X41\p_analysis41;
y41 = a41(2)*q_analysis41.^2 + a41(1);

X43 = [ones(size(q_analysis43)) q_analysis43.^2];
a43 = X43\p_analysis43;
y43 = a43(2)*q_analysis43.^2 + a43(1);

X144 = [ones(size(q_analysis144)) q_analysis144.^2];
a144 = X144\p_analysis144;
y144 = a144(2)*q_analysis144.^2 + a144(1);


f= figure();
hold on

map = get(gca,'ColorOrder')
set(gca,'ColorOrder',[map(1:3,:); map(1:3,:)])

plot(q_analysis41,y41)
plot(q_analysis43,y43)
plot(q_analysis144,y144)


plot(q_analysis41, p_analysis41,'x', LineWidth=3)
plot(q_analysis43, p_analysis43,'x', LineWidth=3)
plot(q_analysis144, p_analysis144,'x', LineWidth=3)

legend_string = [   'p_1(u) = ', num2str(a41(2),'%.2f'),'u^2 ', num2str(a41(1),'%.2f');...
                    'p_2(u) = ', num2str(a43(2),'%.2f'),'u^2 ', num2str(a43(1),'%.2f');...
                    'p_3(u) = ', num2str(a144(2),'%.2f'),'u^2 ', num2str(a144(1),'%.2f')];
xlabel("Flow [m^3/h]")
ylabel("Pressure drop  [bar]")
legend(legend_string, Location="northwest")
grid 
fontname(f,'Times')
exportgraphics(f,'pump_station_step_response_and_pipe_resistances\Pipe_resistance_estimation\pipe_resistance_model_module41.pdf')

%% Estimating pipe resistance into tower
% In all cases the tower elevation has been 2m. Pump station 3 has been
% elevated 1 meter.

elevation = 2; %[m]
meter2bar = 0.1;
pressure_tank_entrance = elevation*meter2bar + out41.tower_34.tank_34_mm/1000*meter2bar;
pressure_drop = out41.pipe_20.p43_20 - pressure_tank_entrance;
flow = out41.pipe_20.q4_20;


yyaxis left
ylabel("Flow [m^3/h]")
yyaxis right 
plot(pressure_drop)
ylabel("Pressure drop  [bar]")
xlabel("Time [s]")
grid
%%
figure
plot(out144.consumer_32.v11_32)


