load('test_consumer_valve_controller\single_valve_controller.mat')

f=figure()
subplot(2,1,1)
plot(out.consumer_32.v11_12_32_demand)
hold on
plot(out.consumer_32.q_32_v1)
grid
legend('Reference', 'Measurement')
title("")
xlabel("Time [s]")
ylabel("Flow [m^3/h]")
subplot(2,1,2)
plot(out.consumer_32.v11_32, color="#EDB120")
xlabel("Time [s]")
ylabel("Opening degree [0-100]")
legend("Actuation")
grid
title("")
fontname(f,'Times')
exportgraphics(f,'test_consumer_valve_controller\single_valve_controller_test.pdf')


%% Double controller
load('test_consumer_valve_controller\Double_valve_controller.mat')

f=figure('Position', [10 10 500 500])
subplot(3,1,1)
line1 = plot(out.consumer_32.v11_12_32_demand, 'DisplayName','Reference')
hold on
line2 = plot(out.consumer_32.q_32_v1, 'DisplayName','Measured flow valve 1')
line3 = plot(out.consumer_32.q_32_v2, 'DisplayName','Measured flow valve 2')
line4 = plot(out.consumer_32.q_32_v1+out.consumer_32.q_32_v2, 'DisplayName', ' Sum of flows')
grid
title("")
xlabel("Time [s]")
ylabel("Flow [m^3/h]")

subplot(3,1,2)
map = get(gca,'ColorOrder')
set(gca,'ColorOrder',[map(2:3,:)])
hold on
line5 = plot(out.consumer_32.v11_32, 'LineWidth',2, 'DisplayName', 'Actuation valve 1')
line6 = plot(out.consumer_32.v12_32, 'LineWidth',2, 'DisplayName', 'Actuation valve 2')
xlabel("Time [s]")
ylabel("Opening degree [0-100]")
grid
title("")

ax = subplot(3,1,3,'Visible','off');
axPos = ax.Position;
delete(ax)
% Construct a Legend with the data from the sub-plots
hL = legend([line1,line2, line3,line4,line5,line6]);
% Move the legend to the position of the extra axes
hL.Position(2:2) = axPos(2:2);

%legend([line1,line2, line3,line4,line5,line6],Location="southoutside")

fontname(f,'Times')
exportgraphics(f,'test_consumer_valve_controller\double_valve_controller_test.pdf')