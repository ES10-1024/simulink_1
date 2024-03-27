function [consumption,consumptionNoise] = consumption(currentTime,usedAccTime)
% Here it is desired to make a model for the consumption for the entire controller horizion, given the current time and control horizion. 
%The input is: 
%currentTime: the currentTime
% usedAccTime if acclereted time is used, is a true false statement
%% Define some values 
%Importing constant valus: 
c=scaled_standard_constants();
%The time between samples 
TimeBetweenSamples=(3600*c.ts)/4;

% Definig the amount of seconds per day 
SecondsPerDay=24*3600;

%Defining amount of seconds per week 
SecondsPerWeek=24*3600*7;
%% Checking if the given sample time is dividable with the sample time for the measurements of demand!
  % Define size: 
    consumption=zeros(c.Nc,1); 
    consumptionNoise=zeros(c.Nc,1);
if floor((c.ts*3600)/TimeBetweenSamples)==(c.ts*3600)/TimeBetweenSamples 
else
    disp("CAN NOT WORK WITH THE GIVEN SAMPLE TIME PLZ CHANGE IT");
   
    return;
end 


%% Loading in the data needed for the consumption model
std_week=load('prediction_scaled.mat'); 
std_week=std_week.scaled_prediction';

demand_data=load('consumption_scaled.mat'); 

demand_data=demand_data.scaled_consumption;

%% Making a new average given the sample time
%First the changes in sample is added for instance going 
% from 15 mins sample to one hour and the average is taken 

%Determine the changes in samples
samplesChanges=(c.ts*3600)/TimeBetweenSamples; 

%adding those sample together
index=1;  
NewStd_week=zeros(size(std_week,1)/samplesChanges,1);
for i=1:samplesChanges:size(std_week,1) 
    NewStd_week(index,1)=sum(std_week(i:samplesChanges+i-1,1)); 
    index=index+1; 
end 

%Determine the average: 
NewStd_week=NewStd_week/samplesChanges;

%% Next the same thing is done for the all the demand data 
index=1; 
NewDemand_data=zeros(ceil(size(demand_data,1)/samplesChanges),1);
for i=1:samplesChanges:size(demand_data,1)-samplesChanges 
    NewDemand_data(index,1)=sum(demand_data(i:samplesChanges+i-1,1)); 
    index=index+1; 
end 
%Taking a average of the varaince 
NewDemand_data=NewDemand_data/samplesChanges;

%% Determining consumption model
%First the start position is determinted in regard to time of week. 
if usedAccTime == true 
    StartPosition=(currentTime*c.AccTime);%-(floor((currentTime*c.AccTime)/(SecondsPerWeek))*SecondsPerWeek);
else 
    StartPosition=(currentTime);%-(floor((currentTime)/(SecondsPerWeek))*SecondsPerWeek);
end 
StartPosition=round(StartPosition)/3600+1;
%The consumption with noise is not weekly wrap around and can therefore be set: 
consumptionNoise=NewDemand_data(StartPosition:StartPosition+c.Nc-1,1); 
%Changing to m^3/s 
%consumptionNoise=consumptionNoise/3600; 

%Checking if enough data is avable els wrap around is needed. 
if StartPosition+c.Nc<=size(NewStd_week,1) 
    consumption=NewStd_week(StartPosition:StartPosition+c.Nc-1,1);
    %Changing to m^3/s 
    %consumption=consumption/3600;
    return; 
else 
    consumption=NewStd_week(StartPosition:end); 
    %Determine how much is still missing
    Left=c.Nc-size(consumption,1);
    %The left is taken from the start resulting in: 
    consumption=[consumption;NewStd_week(1:Left,1)-1]; 
    %Changing to m^3/s 
    %consumption=consumption/3600;
    return; 
end 

end