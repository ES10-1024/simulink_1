%% Setting up the optimization problem and solving it.
function [up1,uAll] = mpcRunV2(data,uPrev,scaled)
% The inputs is:
% Standard constant, which also have the current water volume, and demand
c=scaled_standard_constants; 

c.d=data.d(:,:,end); 
c.Je=data.Je(:,end); 
c.V=data.V(end,1); 
%Defining the total number of varaibles which has to be determinted
total=c.Nc*c.Nu;

%% Defining optimization variable
 %% Need a few empty matrix to allow for the change in option for the solver
 Aeq=[];
 beq=[];
 lb=[];
 ub=[];
 nonlcon=[];

 %If it desired to change the settings for the solver, use the one listed
 %below: 
 %options = optimoptions(@fmincon,'MaxFunctionEvaluations',10e4);
 options = optimoptions(@fmincon,'Algorithm','sqp');

%% Making A and v matrices for the constraints
%A_1 each row have 3 ones such that the flow from the given time stamp is
%added
c.A_1=[];
for i=1:c.Nc
    c.A_1 = blkdiag(c.A_1,ones(1,c.Nu));
end
%Lower trangiular matrix to add consumption and inflow 
c.A_2 = tril(ones(c.Nc,c.Nc));

%Making vi vectors utilized to pick out 1 of the 3 pumps values, add them up
%and used to make extration limit. 
c.v1=ones(c.Nu*c.Nc,1);
c.v1(2:c.Nu:end) =0; 

c.v2=ones(c.Nu*c.Nc,1);
c.v2(1:c.Nu:end) =0;

%Making matrix which picks out 1 of the pumps for the enitre control
%horizion
c.A_31=[];
for i=1:c.Nc
    c.A_31 = blkdiag(c.A_31,[1 0]);
end

c.A_32=[];
for i=1:c.Nc
    c.A_32 = blkdiag(c.A_32,[0 1]);
end

%% Setting up constraints
%All pumps mass flows should be above zero: 
A.pumpL = -eye(total);
B.pumpL = zeros(total,1);

% Pump one 
A.extract1 = c.v1'*c.ts/3600;  
B.extract1 = c.TdMax1;
A.pumpU1 = c.A_31; 
B.pumpU1 = ones(c.Nc,1)*c.umax1; 
%Pump two 
A.extract2 = c.v2'*c.ts/3600;  
B.extract2 = c.TdMax2;
A.pumpU2 = c.A_32; 
B.pumpU2 = ones(c.Nc,1)*c.umax2; 
%Water Tower: 
A.towerL=-c.A_2*c.A_1*c.ts/3600; 
B.towerL=-c.Vmin*ones(c.Nc,1)+c.V*ones(c.Nc,1)-c.A_2*c.ts*c.d/3600;  

A.towerU=c.A_2*c.A_1*c.ts/3600;
B.towerU=c.Vmax*ones(c.Nc,1)-c.V*ones(c.Nc,1)+c.A_2*c.ts*c.d/3600;  

%Collecting all into one matrix: 
AA=[A.pumpL;A.extract1;A.pumpU1;A.extract2;A.pumpU2;A.towerL;A.towerU];
BB=[B.pumpL;B.extract1;B.pumpU1;B.extract2;B.pumpU2;B.towerL;B.towerU];

%% Defining cost functions: 
% Water level in water tower (need for the cost functions)
 h=@(u) 1/c.At*(c.A_2*(c.A_1*c.ts*u/3600-c.ts*c.d/3600)+c.V);

if scaled == false 


    %Defining part which is about the height: 
    height1=@(u) c.g0*c.rhoW*(h(u)+c.z1);
    
    height2=@(u) c.g0*c.rhoW*(h(u)+c.z2); 
    
    %Defining  part due to pipe resitance which is separated: 
    PipeResistance1= @(u) c.rf1/3600^2*c.A_31*(u/3600.*abs(u/3600)); 
    
    PipeResistance2= @(u) c.rf2/3600^2*c.A_32*(u/3600.*abs(u/3600)); 
    
    %Definine pipe resistance in the end with all flows: 
    PipeResistanceTogether= @(u) c.rfTogether/3600^2*(abs(c.A_1*u/3600-c.d/3600).*abs(c.A_1*u/3600-c.d/3600)); 
    
    
    %Defining the cost function for the two pumps: 
    %Pump 1
    Jl1= @(u) c.ts*ones(1,c.Nc)*(c.e1*c.Je/(3600*1000).*(c.A_31*u/3600.*(PipeResistance1(u)+PipeResistanceTogether(u)+height1(u)))); 
    %Pump 2 
    Jl2= @(u) c.ts*ones(1,c.Nc)*(c.e2*c.Je/(3600*1000).*(c.A_32*u/3600.*(PipeResistance2(u)+PipeResistanceTogether(u)+height2(u)))); 


else 

    %Defining part which is about the height: 
    height1=@(u) c.g0*c.rhoW*(h(u)+c.z1);
    
    height2=@(u) c.g0*c.rhoW*(h(u)+c.z2); 
    
    %Defining  part due to pipe resitance which is separated: 
    PipeResistance1= @(u) c.rf1/3600*c.A_31*(u.*abs(u)); 
    
    PipeResistance2= @(u) c.rf2/3600*c.A_32*(u.*abs(u)); 
    
    %Definine pipe resistance in the end with all flows: 
    PipeResistanceTogether= @(u) c.rfTogether/3600*(abs(c.A_1*u-c.d).*abs(c.A_1*u-c.d)); 
    
    
    
    
    %Defining the cost function for the two pumps: 
    %Pump 1
    Jl1= @(u) ones(1,c.Nc)*(c.e1*c.Je.*(c.A_31*u.*(PipeResistance1(u)+PipeResistanceTogether(u)+height1(u)))); 
    %Pump 2 
    Jl2= @(u) ones(1,c.Nc)*(c.e2*c.Je.*(c.A_32*u.*(PipeResistance2(u)+PipeResistanceTogether(u)+height2(u)))); 

end 









% %Pump one 
%Jl1= @(u) ones(1,c.Nc)*(c.e1*c.Je.*(c.A_31*(u.*u.*abs(u)*(c.rf1/1000) + u*c.g0*c.rhoW*(c.z1/1000))+(c.A_31*u).*(h(u)/1000)+c.A_31*u.*((c.rfTogether/1000)*abs(c.A_1*u-c.d).*abs(c.A_1*u-c.d))));

%Pump two 
%Jl2 = @(u) ones(1,c.Nc)*(c.e2*c.Je.*(c.A_32*(u.*u.*abs(u)*(c.rf2/1000) + u*c.g0*c.rhoW*(c.z2/1000))+(c.A_32*u).*(h(u)/1000)+c.A_32*u.*((c.rfTogether/1000)*abs(c.A_1*u-c.d).*abs(c.A_1*u-c.d))));

% % % Pump one 
%   Jl1= @(u) ones(1,c.Nc)*(c.e1*c.ts*c.Je/(3600*1000).*(c.A_31*(u/3600.*u/3600.*abs(u/3600)*(c.rf1/3600^2) + u/3600*c.g0*c.rhoW*(c.z1))+(c.A_31*u/3600).*(c.g0*c.rhoW*h(u))+c.A_31*u/3600.*((c.rfTogether/3600^2)*abs(c.A_1*u/3600-c.d/3600).*abs(c.A_1*u/3600-c.d/3600))));
% % % 
% % % %Pump two 
%   Jl2 = @(u) ones(1,c.Nc)*(c.e2*c.ts*c.Je/(3600*1000).*(c.A_32*(u/3600.*u/3600.*abs(u/3600)*(c.rf2/3600^2) + u/3600*c.g0*c.rhoW*(c.z2))+(c.A_32*u/3600).*(c.g0*c.rhoW*h(u))+c.A_32*u/3600.*((c.rfTogether/3600^2)*abs(c.A_1*u/3600-c.d/3600).*abs(c.A_1*u/3600-c.d/3600))));



%Defining that the amount of water in the tower in the start and end
%has to be the same 
Js= @(u) c.K*(c.ts*ones(1,c.Nc)*(c.A_1*u/3600-c.d/3600))^2;


%Setting up the cost function: 
costFunction=@(u) (Jl1(u)+Jl2(u)+Js(u));

    
%Inital guess 
x0 =[uPrev(2:end,1);uPrev(end,end)]; 

%Solving the problem  
u_hat = fmincon(costFunction,x0,AA,BB,Aeq,beq,lb,ub,nonlcon,options);

%Setting output from the function
up1=u_hat(1:c.Nu); 
uAll=u_hat;


end
