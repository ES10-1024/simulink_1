clear 
clf 
c=scaled_standard_constants; 

SQP=load("simulationSQP.mat"); 
normal=load("simulationOutput.mat"); 
anotherSolution=load("consensus_24h_no_underrelaxation_rho=0_08.mat");
Casadi=load("simulationCasadi.mat");

xUsedMatlab=anotherSolution.xUsed;
close all 
clf 
%%
hold on 
plot(normal.out.logsout{11}.Values.Data/1000*c.At)
plot(SQP.out.logsout{11}.Values.Data/1000*c.At)
plot(Casadi.out.logsout{11}.Values.Data/1000*c.At)
plot(anotherSolution.Vglobal(1:8,1))
hold off 

grid 

legend("Inter","SQP","Casadi","Global")
%%
c.A_1=[];
for i=1:c.Nc
    c.A_1 = blkdiag(c.A_1,ones(1,c.Nu));
end

%Lower trangiular matrix to add consumption and flows 
c.A_2 = tril(ones(c.Nc,c.Nc));


%Making vi vectors utilized to pick out 1 of the 3 pumps values, add them up
%used to make extration limit. 
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

%% 
SQPuAll=SQP.out.logsout{12}.Values.data; 
InteruAll=normal.out.logsout{12}.Values.data;
CasadiuAll=Casadi.out.logsout{12}.Values.data;


%% 
index=1;
for k=1:size(SQPuAll,3)
    for i=1:c.Nu*c.Nc
         xUsedSQP(i,k)=SQPuAll(i,index,k);
         xUsedInter(i,k)=InteruAll(i,index,k);
         xUsedCasadi(i,k)=CasadiuAll(i,index,k);
         index=index+1;
         if index==c.Nu+1  
             index=1; 
         end 
    end
    index=1; 
end 

consumption=normal.out.logsout{4}.Values.Data; 
Elprice=normal.out.logsout{6}.Values.Data
for i=1:size(SQPuAll,3)
    c.d=consumption(:,:,i);
    c.Je=Elprice(:,:,i);
    costSQP(i)=costFunction(xUsedSQP(:,i),c); 
    costInter(i)=costFunction(xUsedInter(:,i),c);
    costCasadi(i)=costFunction(xUsedCasadi(:,i),c);
    costMatlab(i)=costFunction(xUsedMatlab(:,i),c);


    costDifferenceSQP(i)= (costSQP(i)-costMatlab(1,i))/costMatlab(1,i)*100;
    costDifferenceInter(i)= (costInter(i)-costMatlab(1,i))/costMatlab(1,i)*100;
    costDifferenceCasadi(i)= (costCasadi(i)-costMatlab(1,i))/costMatlab(1,i)*100;

end 

%% 
clf
hold on 
plot(costDifferenceSQP)
plot(costDifferenceInter)
plot(costDifferenceCasadi)
hold off
ylabel("Procent wise cost difference from problem structure")
xlabel("Hours [Hr]")
legend('SQP','inter','Casadi')
grid on 
