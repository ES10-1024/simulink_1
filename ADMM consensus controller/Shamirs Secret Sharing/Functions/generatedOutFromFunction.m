function [yOut] = generatedOutFromFunction(secret) 
%Here it is desired to determine the output from the random chosen values
%for the Shamirs secret sharing. 
%Taking in the standard values 
cc=scaled_standard_constants;

yOut=zeros(cc.Nu+1,size(secret,1)); 

for index=1:size(secret,1)
    %a correspondes to the secret: 
    a=round(secret(index,1)); 
    %b and c is determinted from a unifrom distrubtion from 0 to fininth field
    %prime-1
    b=round(unifrnd(0,cc.prime-1));
    c=round(unifrnd(0,cc.prime-1));
    
    %Making a matrix for it: 
    constants=[a;b;c]; 
    %Making matrix of the different x values: 
    Q=[1 1 1; 1 2 4; 1 3 9];
    
    %Making the output from the function: 
    yOut(:,index)=Q*constants; 
end 


%Making it finith
%yOut=FinithFields(yOutTemp);
end

