function [Bill]= eletrictyBill(u,Je,c,V)
%Determine the eletricty Bill now (Bill) and a prediction (BillPred) with the given U 
%U=current and expected input
%Je= eletricty prices 
%c= getting standard constant and some matrix needed for writting up the
%cost functions 
%V= voulme in the water tower 
%% Setting up a few matrix to help write the cost. 
%A_1 each row have 3 ones such that the flow from the given time stamp is
%added
c.A_1=[];
for i=1:c.Nc
    c.A_1 = blkdiag(c.A_1,ones(1,c.Nu));
end
%Lower trangiular matrix to add consumption and inflow 
c.A_2 = tril(ones(c.Nc,c.Nc));

%% Determing the Water heigh: 
h=V/c.At;
%% Determine the eletricity bill for each of the pumps: 

%Pump 1
i=1;
Jp1=0; 
index=1; 
    P1(1,1)=c.e1*u(index,1)/3600*(c.rf1*u(index,1)/3600*u(index,1)/3600+c.rhoW*c.g0*(c.z1+h(i,1))+c.rfTogether*(u(index,1)/3600+u(index+1,1)/3600)*(u(index,1)/3600+u(index+1,1)/3600)); 
    Jp1(1,1)=1/(1000)*Je(i,1)*P1(i,1); 


%Pump 2 
index=2; 
Jp2=0; 
    P2(1,1)=c.e2*u(index,1)/3600*(c.rf2*u(index,1)/3600*u(index,1)/3600+c.rhoW*c.g0*(c.z2+h(i,1))+c.rfTogether*(u(index-1,1)/3600+u(index,1)/3600)*(u(index-1,1)/3600+u(index,1)/3600)); 
    Jp2(1,1)=1/(1000)*Je(i,1)*c.ts*P2(i,1); 
 

%% Adding the bill for the 3 pumps, for the input applied 
Bill=Jp1(1,1)+Jp2(1,1);


end 

