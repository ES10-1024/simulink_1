function u_hat = u_consensus_fmincon(lambda, data, z, n_unit,x)
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
%sqp-legacy
 options = optimoptions(@fmincon,'Algorithm','sqp-legacy');
 %options = optimoptions(@fmincon,'Algorithm','interior-point');


 %options = optimoptions(@fmincon,'MaxFunctionEvaluations',3e3);

%% Defining the total number of varaibles which has to be determinted
total=c.Nc*c.Nu;
 %% Need a few empty matrix to allow for the change in option for the solver
 Aeq=[];
 beq=[];
 lb=[];
 ub=[];
 nonlcon=[];

 %If it desired to change the settings for the solver, use the one listed
 %below: 
 %options = optimoptions(@fmincon,'MaxFunctionEvaluations',10e4);


%% Water level in water tower (need for the cost functions)
    h=@(u) c.g0*c.rhoW*1/c.At*(c.A_2*(c.A_1*u(1:total,1)-c.d)+c.V);

    
    %% Making cost function 
    %Pump one
if (n_unit==1) 
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
        J_l= @(u) ones(1,c.Nc)*(c.e1*c.Je/1000.*(c.A_31*(u(1:total,1).*abs(u(1:total,1)).*u(1:total,1)/3600^3*c.rf1 + u(1:total,1)/3600*c.g0*c.rhoW*c.z1)+ (c.A_31*u(1:total,1)/3600).*h(u)+c.A_31*u(1:total,1)/3600.*(c.rfTogether*(c.A_1*abs(u(1:total,1))/3600).*(c.A_1*u(1:total,1)/3600))));
end  

%Pump two 
if (n_unit==2)
        %Defining constraints on matrix form 
        A.extract = c.v2';  
        B.extract = c.TdMax2;
        A.pumpU = c.A_32; 
        B.pumpU = ones(c.Nc,1)*c.umax2; 
        A.pumpL = -eye(total);
        B.pumpL = zeros(total,1);

        %Collecting constraints into two matrix one which is mutliple with the optimization varaible (AA), and a costant BB: 
        AA=[A.extract;A.pumpU;A.pumpL];
        BB=[B.extract;B.pumpU;B.pumpL];

        %Defining the cost function
        J_l = @(u) ones(1,c.Nc)*(c.e2*c.Je/1000.*(c.A_32*(u(1:total,1).*u(1:total,1).*abs(u(1:total,1))/3600^3*c.rf2 + u(1:total,1)/3600*c.g0*c.rhoW*c.z2)+(c.A_32*u(1:total,1)/3600).*h(u)+c.A_32*u(1:total,1)/3600.*(c.rfTogether*(c.A_1*abs(u(1:total,1))/3600).*(c.A_1*u(1:total,1)/3600))));
end 


%Water tower
if n_unit==3
    %Defining constraints, each pump mass flow has to be above zero, upper
    %and lower water volumen limit
    A.pumpL = -eye(total);
    B.pumpL = zeros(total,1);
    
    A.towerL=-c.A_2*c.A_1; 
    B.towerL=-c.Vmin*ones(c.Nc,1)+c.V*ones(c.Nc,1)-c.A_2*c.d;  

    A.towerU=c.A_2*c.A_1;
    B.towerU=c.Vmax*ones(c.Nc,1)-c.V*ones(c.Nc,1)+c.A_2*c.d;  

   %Collecting constraints into two matrix one which is mutliple with the optimization varaible (AA), and a costant BB: 
    AA=[A.pumpL;A.towerL;A.towerU];
    BB=[B.pumpL;B.towerL;B.towerU];
    
    %Defining the cost function: 
    J_l= @(u) 0; 
end 

    %% Cost function definition

    %Defining the part of the cost function which is in regard to the ADMM consensus
    %algortime 
    J_con_z = @(u) lambda'*(u(1:total,1)-z)+c.rho/2*((u(1:total,1)-z)'*(u(1:total,1)-z));



    %Defining that the amount of water in the tower in the start and end
    %has to be the same 
    Js= @(u) c.K*(ones(1,c.Nc)*(c.A_1*u(1:total,1)-c.d))^2;
    
    %Making the entire cost function
    costFunction=@(u) (J_l(u)+Js(u)+J_con_z(u));
    
    %Initial guess
    x0 = x;
    
    %Solving the problem  
    u_hat = fmincon(costFunction,x0,AA,BB,Aeq,beq,lb,ub,nonlcon,options);
    %u_hat = fmincon(costFunction,x0,AA,BB);

end

