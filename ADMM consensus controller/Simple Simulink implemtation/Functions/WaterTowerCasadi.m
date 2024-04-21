function u_hat = WaterTower(lambda, data, z,x,rhoValue)
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
c.rho=rhoValue; 



c.A_1=data.A_1; 
c.A_2=data.A_2; 

c.v1=data.v1; 
c.v2=data.v2; 

c.A_31=data.A_31; 
c.A_32=data.A_32; 


%% Defining the total number of varaibles which has to be determinted
%Defining the total number of varaibles which has to be determinted
total=c.Nc*c.Nu;

%% Setting up the optimization problem: 
import casadi.* 
opti=casadi.Opti(); 
%Definining optimiztion varaible: 
u=opti.variable(total,1);



%% Water level in water tower (need for the cost functions)
     %Setting up constraints on the form Ax<=b 
    %Lower limith for the pump mass flow 
    A.pumpL = -eye(total);
    B.pumpL = zeros(total,1);
    
    %Lower volume limith for the water tower 
    A.towerL=-c.A_2*c.A_1*c.ts/3600; 
    B.towerL=-c.Vmin*ones(c.Nc,1)+c.V*ones(c.Nc,1)-c.A_2*c.ts*c.d/3600;  
    
    %Upper volume limith for the water tower 
    A.towerU=c.A_2*c.A_1*c.ts/3600;
    B.towerU=c.Vmax*ones(c.Nc,1)-c.V*ones(c.Nc,1)+c.A_2*c.ts*c.d/3600;  

   %Collecting constraints into two matrix one which is mutliple with the optimization varaible (AA), and a costant BB: 
    AA=[A.pumpL;A.towerL;A.towerU];
    BB=[B.pumpL;B.towerL;B.towerU];
    %% Cost function 
    %Defining that the amount of water in the tower in the start and end
    %has to be the same 
    Js= c.K/3*(c.ts*ones(1,c.Nc)*(c.A_1*u/3600-c.d/3600))^2;

    %Defining the cost function: 
    costFunction= Js;
    %% Defining constraints  in casadi 
    opti.subject_to(AA*u<=BB);
    %% Cost function definition

    %Defining the part of the cost function which is in regard to the ADMM consensus
    %algortime 
    J_con_z = lambda'*(u(1:total,1)-z)+c.rho/2*((u(1:total,1)-z)'*(u(1:total,1)-z));

    
    %Making the entire cost function
    costFunctionAll= (costFunction+J_con_z);
    %Defining that the cost function is to be minimized: 
    opti.minimize(costFunctionAll); 

    %Selecting solver (just using the recommanded!) 
    opti.solver('ipopt');
    
    %Solving the problem  
    sol=opti.solve();
    %Taking out the solution: 
    u_hat=sol.value(u);

end

