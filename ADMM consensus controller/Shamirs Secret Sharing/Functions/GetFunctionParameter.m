function [a] = GetFunctionParameter(summed)
%Determine the polynium values
a=zeros(size(summed,2),1);
%Inverse of the x matrix used to determine the values for the polyniums in
%the start 
for index=1:size(summed,2)
    r=[3 -3 1];
    %Determine the contants values for the polynium 
    a(index,1)=r*summed(:,index); 
    
    %Making it finith
    a(index,1)=FinithFields(a(index,1)); 
end 

end

