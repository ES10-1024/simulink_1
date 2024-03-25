function [Vp1] = Model(V,u,d)
%Function for the model, which gives the next water volume given the
%current input.
% 
% as inputs has:
%V volumen in the water twoer
%u pump mass flows in m^3/h for the entire control horizion
%d demand in m^3/h for the entire control horizion

%% Define constant from the rapport
c=scaled_standard_constants;
%% Define the state space matrixs (from the report) 
A=1; 
Bu=ones(1,c.Nu)*c.ts; 
Bd=ones(1,c.Nd)*c.ts;

%% Determine the next output corresponding to the output of the function 
Vp1=A*V+Bu*u(1:c.Nu,1)-Bd*d(1,1);

end