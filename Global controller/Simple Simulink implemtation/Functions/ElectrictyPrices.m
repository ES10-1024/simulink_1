function [ElPrices] = ElectrictyPrices(currentTime,usedAccTime)
%% In this script it is desired to return a vector of the eletricty prices which are neccesary for the MPC to run

%% First define some variables
% Input
% currentTime The current Time in seconds! 
% usedAccTime if acclereted time is used, is a true false statement


%% Making a few definitions
%Current time with respect to hours. 
c=scaled_standard_constants();

if usedAccTime==true
    CurrentTimeHours=floor(currentTime*c.AccTime/3600)+1;   
else 
    CurrentTimeHours=floor(currentTime/3600)+1;  
end 

ElPrices=zeros(c.Nc,1);

%% Loading in the eletricty prices
ElpriceAlot=load("ElPrice.mat");
% Data=load("ElectrictyPrices.mat");
% Data=Data.Data;
% %Going from MWh to kWh: 
% Data.NewPrice=Data.NewPrice/1000; 
Data.NewPrice=ElpriceAlot.Elprice;
for index=1:c.Nc
ElPrices(index,1)=Data.NewPrice(CurrentTimeHours+index-1);
end 
%% Making vector of eletricty prices 
% Determine the row to be entered based on how many days has gone by,
% and the time of day. 
% TimeHours=(CurrentTimeHours);
% %Determing time to next hour 
% TimeNextHour=3600*(currentTime/3600-CurrentTimeHours); 
% 
% %Maing a for loop to make the vector of eletricty prices
% ElPrices=zeros(c.Nc,1);
% for index=1:c.Nc 
%     %Load the eletricty into the vector
%     ElPrices(index,1)=Data.NewPrice(TimeHours,1); 
%     %adding the sample time to the present time 
%     TimeNextHour=TimeNextHour+3600*c.ts; 
%     %If the TimeNextHour is above 3600s (one hour), TimeHours is move 
%     %one step forward (next eletricty price)
%     if TimeNextHour>= 3600 
%         TimeNextHour=TimeNextHour-3600; 
%         TimeHours=TimeHours+1; 
%     end 
% end 




end