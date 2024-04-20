%% Describtion
% Use this script to run the consensus ADMM controller in Simulink  
%% Making alot of clears 
clf 
clc 
clear
close all
%adding a few path: 
% addpath("..\..\")
% addpath("..\..\Global controller\")
% 
% addpath("..\..\log\")
% addpath("log\")
% 
% addpath("Functions\")
% addpath("..\Subsystem Reference\")


%% Adding path and standard values
c=scaled_standard_constants; 
%% Define the amount of scaled hours it is desired to simulate for: 
simHour=24; 

%Making calculatation to get it to fit with the sacled time and make it
%such matlab likes it 
simTime=simHour/c.AccTime*3600; 
c.Tsim=num2str(simTime); 

%c.tsSim=num2str(c.ts*3600); 

%% Running the simulation 
simData=sim('ADMM_consensus.slx',"StartTime",'0',"StopTime",c.Tsim,'FixedStep','200');

%% Making a plot of the result  
clf 
% adding the mass flows for the given time stamp  
for index=2:size(simData.logsout{15}.Values.Data,1) 
summedMassflow(index-1,1)=simData.logsout{15}.Values.Data(index,1)+simData.logsout{16}.Values.Data(index,1);
end 

% Getting the electricity prices,

for index=2:size(simData.logsout{14}.Values.Data,3) 
    [temp]=ElectrictyPrices(index*c.ts); 
    ElPrices(index-1)=temp(1,1);
end 

%Getting  the actual consumption, prediction horizion
% and the volume in the water tower 
consumptionActual=simData.logsout{6}.Values.Data(2:end,1); 

consumptionPred=squeeze(simData.logsout{5}.Values.Data(1,1,2:end)); 

Volume=simData.logsout{19}.Values.Data; 

%Taking out the last rho value of each run 
rhoValue=simData.logsout{17}.Values.Data;
%% Making the plot 
f=figure
% Electricity prices and summed mass flow for each time stamp 
subplot(4,1,1)
hold on
yyaxis left
ylabel('Summed pump flow [m^{3}/h]' )
stairs(summedMassflow) 
yyaxis right 
ylabel('Electri prices [Euro/kWh]') 
stairs(ElPrices)
xlabel('Time [h_{a}]') 
grid 
xlim([0 72])
hold off 
set(gca,'fontname','times')

% Volume in the water tower: 
subplot(4,1,2) 
hold on 
plot(Volume)
yline(c.Vmax)
yline(c.Vmin)
hold off 
legend('Volume','Constraints')
ylabel('Volume [m^{3}]') 
xlim([0 72])
grid 
xlabel('Time [h_{a}]') 
set(gca,'fontname','times')

%Predicted consumption and presented consumption
subplot(4,1,3)
hold on 
stairs(consumptionPred)
stairs(consumptionActual)
hold off 
grid 
legend('Predicted flow','Actual flow')
xlim([0 72])
ylabel('Mass flow [m^{3}/h]' )
xlabel('Time [h_{a}]') 
set(gca,'fontname','times')

%rhoValue
subplot(4,1,4)
hold on 
stairs(rhoValue)
hold off 
grid 
xlim([0 72])
ylabel('Peanlty parameter' )
xlabel('Time [h_{a}]') 
set(gca,'fontname','times')



a = annotation('rectangle',[0 0 1 1],'Color','w');

%exportgraphics(f,'global_controller_scaled_with_disturbance_with_Kappa.pdf')

delete(a)
%% 

for index=2:size(simData.logsout{14}.Values.Data,3) 
     for entire=1:c.Nu*c.Nc
        if mod(index, 2) == 1
            %The number is odd use first entire 
            uUsed(entire,index-1)=simData.logsout{14}.Values.Data(entire,1,index);
        else
            %The number is not odd use second entire
            uUsed(entire,index-1)=simData.logsout{14}.Values.Data(entire,2,index);
        end
     end 

end 

%% 
for index=2:size(simData.logsout{14}.Values.Data,3) 
    [VolumePred(:,index-1)] = ModelPredicted(Volume(index,1),uUsed(:,index-1),simData.logsout{5}.Values.Data(:,:,index)); 
end 

%% 
clear meanDiffFromConsensus 
clear DiffFromConsensus
for index=2:size(simData.logsout{14}.Values.Data,3) 
       for entires =1:19
            if mod(entires, 2) == 1
                %The number is odd use first entire 
                DiffFromConsensus(entires,index-1)=(simData.logsout{14}.Values.Data(entire,1,index)-simData.logsout{14}.Values.Data(entire,3,index));
            else
                %The number is not odd use second entire
                DiffFromConsensus(entires,index-1)=(simData.logsout{14}.Values.Data(entire,2,index)-simData.logsout{14}.Values.Data(entire,3,index));
            end
       end
     meanDiffFromConsensus(:,index-1)=sum(DiffFromConsensus(:,index-1));
end 