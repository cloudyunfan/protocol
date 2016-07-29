function [maxV ind_A]= maxValue(R,T,A,S,V,s,gamma)
%input:
%     V: old value functon
%     s: state s
%     gamma: discount factor
% ouput:
%     maxV: maximum value in this iteration for state s
for a=1:length(A)
    tempR = 0;
    for s1=1:length(S)
        tempR = tempR + T(s,s1,a)*V(s1);
    end
    val(a) = R(s,a) + gamma*tempR;
end
[maxV ind_A] = max(val);
end