load("simulationOutput.mat")
consensusUall=out.logsout{12}.Values.data; 


index=1;
load("matlabConsensusU.mat")
xUsedMatlab=xUsed(:,:); 
clear xUsed 
c=scaled_standard_constants


for k=1:size(consensusUall,3)
    for i=1:c.Nu*c.Nc
         xUsedSimulink(i,k)=consensusUall(i,index,k);
         index=index+1;
         if index==c.Nu+1  
             index=1; 
         end 
    end
    index=1; 
end 
close all 
clf 

hold on 
plot(max(abs(xUsedSimulink-xUsedMatlab(:,1:size(consensusUall,3)))))
hold off 
%legend('Simulink','Matlab')
%% Checking cost function difference 

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

consumption=out.logsout{4}.Values.Data; 
Elprice=out.logsout{6}.Values.Data
for i=1:size(consensusUall,3)
    c.d=consumption(:,:,i);
    c.Je=Elprice(:,:,i);
    costSimulink(i)=costFunction(xUsedSimulink(:,i),c); 
    costMatlab(i)=costFunction(xUsedMatlab(:,i),c);
    procentWiseDifference(i)=(costSimulink(i)-costMatlab(i))/costMatlab(i)*100;
end 

plot(procentWiseDifference)

xlabel("hour")
ylabel("Procenwise difference from global")
grid
