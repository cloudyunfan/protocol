%% 根据状态转移概率矩阵和收益函数，使用值迭代算法求解最优策略

addpath('MDPtoolbox');
% load ProbMatr_3_3.mat
% rewardComput   %重新计算reward

%----------定义变量----------------------------------
%全局变量
global S A TB Emax Bmax lambdaB lambdaE
TB = 200;
Bmax = 30;
Emax = 40;
lambdaB = 0.03;
lambdaE = 0.04;
% B = linspace(0,Bmax-1,Bmax); %buffer state
% E = linspace(0,Emax-1,Emax); %energy state
S = {};
ind_S = 1;
ind0 = [];
for b =0:Bmax-1
    for e=0:Emax-1
        S{ind_S} = [b,e];
        ind_S = ind_S + 1;
        if(b==0||e==0)
            ind0 = [ind0 ind_S];
        end
    end
end
A = [0,1,2,3]; % set of actions 

%局部变量
No_node = 5:5:35;
gamma = 0.9;   % 折扣因子
epsi = 0.01;  %迭代终止条件
maxiter = 100; %最大迭代次数

%-----------载入RAP通信参数----------------------------------------
%变量（TX_RAP_avg_t,,PS_RAP_avg,TX_MAP_avg_t,PS_MAP_avg）
load CSMACA_para_optCHN_3_9.mat
load TDMA_para_optCHN_3_9.mat%载入RAP和MAP阶段平均发送一个包需要的能量
%取所有优先级情况下的平均值
TX_RAP = mean(TX_RAP_avg_t);
TX_MAP = mean(TX_MAP_avg_t);
PS_RAP = mean(PS_RAP_avg);
PS_MAP = mean(PS_MAP_avg);

%% 对所有节点数情况调用MDPtoolbox里的值迭代函数求解最优策略
N =5:5:35;
% t_total = zeros(1,length(N));
% policy = zeros(length(N),length(S));
% iter = zeros(1,length(N));
% cpu_time = zeros(1,length(N));
t_total = 0;

for n=1:length(N)
    %----------------建立MDP模型，计算转移概率矩阵和收益函数------------
    [T,R,t_comput] = ProbComput(TX_RAP(n),TX_MAP(n),PS_RAP(n),PS_MAP(n));   
    %------------------------使用值迭代算法求解------------------------
    V0 = zeros(length(S),1);
    [p, i, t] = mdp_value_iteration(T, R, gamma, epsi, maxiter, V0);
    t_total = t_total + t_comput + t;
    policy(n,:) = p;
    iter(n) = i;
    cpu_time(n) = t;
    [N(n) t_comput]
end
% stem(policy);
% save('MDPresult_3_7.mat','policy','iter','cpu_time');
 save('MDPresult_3_9.mat','policy','iter','cpu_time');


% %% ******************自己写的值迭代函数求解************************
% %------初始化值函数--------------------------------------
% V = zeros(maxiter,length(S));   %initialize value function
% P = -1*ones(100,length(S));
% for s=1:length(S)
%     [maxval,optAct] = maxValue(R,T,A,S,V(1,:),s,gamma);
%     V(2,s) = maxval;
%     P(2,s) = optAct;
% end
% %------迭代更新值函数V直到满足停止条件--------------------
% t = 2;      %迭代计数器
% while(max(abs( V(t,:)-V(t-1,:) )) > epsi)
%     for s=1:length(S)
%        [maxval,optAct] = maxValue(R,T,A,S,V(t,:),s,gamma);
%        V(t+1,s) = maxval;
%        P(t+1,s) = optAct;
%     end
%     t = t + 1
% end
% 
% %---------------根据最优的值函数V计算出最优策略--------------
% for s=1:length(S)
%    for a=1:length(A)
%         tempR = 0;
%         for s1=1:length(S)
%             tempR = tempR + T(s,s1,a)*V(s1);
%         end
%         val(a) = R(s,a) + gamma*tempR;
%    end
%    [maxV ind_A] = max(val);
%    P1(s) = ind_A;    
% end