function [f_pos,f_neg]  = UPfactor(up)
%用于生成一个与UP相关的正向影响因子
% Input:
%     up: up of WBAN node
% Output:
%     f_pos:  positive factor
%     f_neg: negative factor
if(length(up)>1)
   disp('length of up should be 1. thanks!');
   return;    
end
if(up<0||up>7)
    disp('illegal UP! please check your input^_^');
    return;
else
    f_pos = 1+log(up+1)/(1+log(8));%
    f_neg = 1/(1+log(up+1));
end
end