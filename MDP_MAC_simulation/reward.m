function R = reward(S,a,TX_rap_avg,TX_map_avg,B_rap_avg,B_map_avg)
% to calculate reward for transmission from state Si to Sj with action a 
% Input:
%     S: state
%     a: action
%     TX_rap_avg: RAP阶段平均传输一个包需要的能量
%     TX_map_avg: MAP阶段平均传输一个包需要的能量
%     B_rap_avg:RAP阶段平均能传输的包数
%     B_map_avg:MAP阶段平均能传输的包数
% Output:
%     R: reward
global Emax Bmax lambdaB lambdaE TB ;

%% -----------提取数据和能量状态-------------------
Sb = S(1);
Se = S(2);
[Tb,Te] = throughput1(Sb,Se,a,B_rap_avg,B_map_avg,TX_rap_avg,TX_map_avg);
gammaB = Sb/(Bmax-1);%数据包折扣因子
gammaE = Se/(Emax-1);%能量折扣因子

%% ---------由传输的包数量带来的奖励-------------------
R1 = Tb/(lambdaB*TB);   
% R1 = R1*gammaB;%

%% -----------由让出的时隙资源带来的奖励-----------------
S_map = B_map_avg;
S_rap = B_rap_avg;
S_t = S_map + S_rap;
switch a
    case 0
        R2 = S_map/S_t;   %归一化的奖励
    case 1
        R2 = S_rap/S_t;
    case 2
        R2 = 0;
    case 3
        R2 = 1;
end
%根据节点buffer中能量和数据量来计算折扣因子，buffer中能量或数据量越大，折扣因子越小
R2 = R2*( 1 - min(gammaB,gammaE) );

%% ----------由消耗的能量带来的惩罚---------------------
D1 = Te/(lambdaE*TB);
% D1 = D1*( 1-gammaE );%

%% -------------由浪费时隙资源带来的惩罚-----------
switch a
    case 0
       D2 = max( S_rap - min(Sb,Se/TX_rap_avg),0 )/(S_rap+S_map);  
    case 1
       D2 = max( S_map - min(Sb,Se/TX_map_avg),0 )/(S_rap+S_map);    
    case 2
       D2 = max( S_rap - min(Sb,Se/TX_rap_avg),0 );
       [b,e] = throughput1(Sb,Se,0,B_rap_avg,B_map_avg,TX_rap_avg,TX_map_avg);  %减去RAP阶段的消耗
       D2 = D2 + max( S_map - min(Sb-b,(Se-e)/TX_map_avg),0 );
       D2 = D2/(S_rap+S_map);
    case 3
       D2 = 0;
end

%% ------------选择不同的行为策略的门限得到的额外收益--------
%----数据包门限---
eta1 = S_rap;   %S_rap 小，作为第一门限
eta2 = S_map; %S_rap < S_map
%----能量门限-----
% niu1 = B_map_avg*TX_map_avg;   %map阶段耗能小，作为第一个门限
% niu2 = B_rap_avg*TX_rap_avg;
B_eff_rap = min(Sb,Se/TX_rap_avg);
B_eff_map = min(Sb,Se/TX_map_avg);
switch a
    case 0         
        R3 = (B_eff_rap-eta1)/eta1;  
    case 1        
        R3 = (B_eff_map-eta2)/eta2;  
    case 2
        R3 = (B_eff_map - eta2)/eta2 + (B_eff_rap-eta1)/eta1;
    case 3
        R3 = 0;
end
%% ----------------计算总收益---------------------------
R = R1 ;% + R3 - D2 - D1 + R2

end %end function