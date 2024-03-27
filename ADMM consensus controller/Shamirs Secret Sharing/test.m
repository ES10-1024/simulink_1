%% Making a test implementation of shamirs secret sharing 
 
clear 
clc



c=scaled_standard_constants;
%% Defining the secret
secret=ones(48,3); 
%Scaling and rounding the secret: 
secretScaling=round(secret*c.scaling);
%secretScaling=round(secret);
%% Making 3 polynium with the secret: 
yOut1=generatedOutFromFunction(secretScaling(:,1)); 
yOut2=generatedOutFromFunction(secretScaling(:,2)); 
yOut3=generatedOutFromFunction(secretScaling(:,3)); 

%% Making a sum: 
yOutSum=yOut1+yOut2+yOut3; 



%% Determine the summed value: 
a=GetFunctionParameter(yOutSum);

%% Descaling it 
aDescaled=a/c.scaling;

%% Displaying result 
disp("Scret is: ")
disp(sum(secret))

disp("a was determinted to be: ")
disp(aDescaled) 







