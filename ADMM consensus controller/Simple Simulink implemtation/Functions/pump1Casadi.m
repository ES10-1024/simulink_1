function u_hat = pump1(lambda, data, z,x)
% Making the consensus problem for each of the pumps stations  where n_unit
% describes which of the pumps the problem is solved for. 
%Lambda= Lagrangian mulptipler 
%z the consensus variable   
%n_unit which of the pumps is running 
%x is the previous solution and i utilize as initial condition for the
%solver
%u_hat returns the solution for the given pump 
%% loading in scaled standard constants 
c=scaled_standard_constants; 
%Moving data for eletricity price and demand: 
c.Je=data.Je; 
c.d=data.d;
c.V=data.V; 


c.A_1=data.A_1; 
c.A_2=data.A_2; 

c.v1=data.v1; 
c.v2=data.v2; 

c.A_31=data.A_31; 
c.A_32=data.A_32; 


%Defining the total number of varaibles which has to be determinted
total=c.Nc*c.Nu;

%% Setting up the optimization problem: 
import casadi.* 
opti=casadi.Opti(); 
%Definining optimiztion varaible: 
u=opti.variable(total,1);


%% Water level in water tower (need for the cost functions)
h= c.g0*c.rhoW*1/c.At*(c.A_2*(c.A_1*u(1:total,1)-c.d)+c.V);

%Defining inequality constraints on matrix form 
        A.extract = c.v1';  
        B.extract = c.TdMax1;
        A.pumpU = c.A_31; 
        B.pumpU = ones(c.Nc,1)*c.umax1; 
        A.pumpL = -eye(total);
        B.pumpL = zeros(total,1);

        %Collecting constraints into two matrix one which is mutliple with the optimization varaible (AA), and a costant BB: 
        AA=[A.extract;A.pumpU;A.pumpL];
        BB=[B.extract;B.pumpU;B.pumpL];

        %Defining the cost function:
        J_l=ones(1,c.Nc)*(c.e1*c.Je/1000.*(c.A_31*(u(1:total,1).*abs(u(1:total,1)).*u(1:total,1)/3600^3*c.rf1 + u(1:total,1)/3600*c.g0*c.rhoW*c.z1)+ (c.A_31*u(1:total,1)/3600).*h+c.A_31*u(1:total,1)/3600.*(c.rfTogether*(c.A_1*abs(u(1:total,1))/3600).*(c.A_1*u(1:total,1)/3600))));
    %% Defining constraints 
    opti.subject_to(AA*u<=BB);
    %% Cost function definition

    %Defining the part of the cost function which is in regard to the ADMM consensus
    %algortime 
    J_con_z = lambda'*(u(1:total,1)-z)+c.rho/2*((u(1:total,1)-z)'*(u(1:total,1)-z));



    %Defining that the amount of water in the tower in the start and end
    %has to be the same 
    Js=  c.K*(ones(1,c.Nc)*(c.A_1*u(1:total,1)-c.d))^2;
    
    %Making the entire cost function
    costFunction= (J_l+Js+J_con_z);
    %Defining that the cost function is to be minimized: 
    opti.minimize(costFunction); 

    %Selecting solver (just using the recommanded!) 
    opti.solver('ipopt');
    
    %Solving the problem  
    sol=opti.solve();
    %Taking out the solution: 
    u_hat=sol.value(u);
end

