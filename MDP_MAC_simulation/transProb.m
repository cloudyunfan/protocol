function [prob ,prob_B ,prob_E ,b ,e]= transProb( Si,Sj,a,E_rap_avg,E_map_avg,B_rap_avg,B_map_avg)
%  we take use of the function to calculate transition matrix
% Input:
%     Si: state at time i，Si = {Bi,Ei} is a cell of union state
%     Sj: state at time j
%     a:  action
%     E_rap_avg:RAP 阶段平均能消耗掉的能量
%     E_map_avg:MAP 阶段平均能消耗掉的能量
%     B_rap_avg:RAP阶段平均能传输的包数
%     B_map_avg:MAP阶段平均能传输的包数
% Output:
%     prob:  probability of transition from Si to Sj with action a
%     prob_B : probability of packets buffer state transition
%     prob_E : probability of energy buffer state transition
%     b : number of pakcets coming during state transmission
%     e : number of energy coming during state transmission
global TB Emax Bmax lambdaB lambdaE ;

Sbi = Si(1);
Sei = Si(2);
Sbj = Sj(1);
Sej = Sj(2);

[T,E] = throughput_new(Sbi,Sei,a,E_rap_avg,E_map_avg,B_rap_avg,B_map_avg);
b = Sbj - Sbi + T;
e = Sej - Sei + E;
b = ceil(b);
e = ceil(e);

%% calculate poisson probability
% probability of packet
if(b>=0)
    if(Sbj<(Bmax-1))
       prob_B = exp(-lambdaB*TB)*(lambdaB*TB)^(b)/factorial(b);
    else
       kb=0:b-1;
       temp = exp(-lambdaB*TB)*(lambdaB*TB).^(kb)./factorial(kb); 
       prob_B = 1-sum(temp);
    end
else
    prob_B = 0;
end
% probability of energy
if(e>=0)
    if(Sej<(Emax-1))
       prob_E = exp(-lambdaE*TB)*(lambdaE*TB)^(e)/factorial(e);
    else
       ke=0:e-1;
       temp = exp(-lambdaE*TB)*(lambdaE*TB).^(ke)./factorial(ke); 
       prob_E = 1-sum(temp);
    end
else 
    prob_E = 0;
end

prob = prob_B*prob_E;

end