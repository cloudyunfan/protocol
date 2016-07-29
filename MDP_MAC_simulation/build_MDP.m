%% 根据状态转移概率矩阵和收益函数，使用值迭代算法求解最优策略
clear all
clc

addpath('MDPtoolbox');
%% ----------定义变量----------------------------------
%------------全局变量------------
global block State Act TB Emax Bmax lambdaE lambdaB E_tx RAP Delta
len_Pkt = 1;  %发送一个包需要的时隙数
E_tx = 1;
Bmax = 20;
Emax = 20;
block = 10;
M = 7;
TB = 200;
MAP = M*block;
RAP = TB - MAP;

State = {};
ind_S = 1;
ind0 = [];
%S={b,e,g}
for b =0:Bmax-1
    for e=0:Emax-1
        for g=0:1
            State{ind_S} = [b,e,g];          
    %         if(b==0||e==0)
    %             ind0 = [ind0 ind_S];
    %         end
            ind_S = ind_S + 1;
        end
    end
end
Act = [1,2,3,4]; % set of actions 

%-----------------局部变量-----------
UP_indeed = [0,2,4,6];  %WBAN中存在的优先级类别
N_up = [2,2,2,1];
N = sum(N_up);
Delta = M/N*block;
lambdaB = 0.05; %const pkt rate
E_rate = 0.02:0.01:0.08; %varing energy rate
gamma = 0.6;   % 折扣因子
epsi = 0.01;  %迭代终止条件
maxiter = 100; %最大迭代次数

%% -----------载入统计的通信参数---------------------------------------
%-------------------------------VarE----------------------------
%----仿真统计值
load MDP_result(UP0-2-4-6,N3-3-3-1)(Em20-Bm20,B0.05)(E0.02-0.01-0.08).mat
load para_CSMACA(theory)(UP0-2-4-6,N3-3-3-1).mat 
Ps = Ps*Ptr; %节点每个时隙成功发送数据的概率
%注：里面包括每个优先级在CSMA中的包传输量S和能耗E，都是1*4的向量

N1 = length(E_rate);
N2 = length(S);
%% 对所有节点数情况调用MDPtoolbox里的值迭代函数求解最优策略 
% T = cell(N1,N2);
R = cell(N1,N2);
P = cell(N1,N2);

for indE = 1:length(E_rate)
    lambdaE = E_rate(indE);
    for n=1:N2%
        disp(['build MDP for UP' num2str(UP_indeed(n)) ' when lambdaE is ' num2str(lambdaE)]);
    %----------------建立MDP模型，计算转移概率矩阵和收益函数------------         
        t_Prob = 0;
        t_Reward = 0;
%         [T1,t_Prob1] = ProbComput1( S(n),E(n),Ps(n) );       
        [R1,t_Reward1] = rewardComput1(S(n),E(n),UP_indeed(N2),Ps(n));
        t_Prob = t_Prob + t_Prob1;
        t_Reward = t_Reward + t_Reward1;
        disp(['build MDP done! time consumed is: ', num2str(t_Reward+t_Prob), ' seconds. now resolve MDP....']); %t_Prob+
            T1 = T{indE,n};
%         T{indE,n} = T1;
        R{indE,n} = R1;
        %---画出收益函数进行分析-----------------
    %          plot(R1,'d');
    %          legend('a==0','a==1','a==2','a==3');
        %------------------------使用值迭代算法求解------------------------
        V0 = zeros(length(State),1);
        [p, iter, cpu_time] = mdp_value_iteration(T1, R1, gamma, epsi, maxiter, V0);
        disp(['resolve MDP done! iteration is ',num2str(iter),' consumed time is ',num2str(cpu_time),'seconds.'])
    %         p(ind0) = 4;   %强行使B==0||E==0时使用第4种行为
        P{indE,n} = p;       
    end
end
% stem(policy);
save('MDP_result(UP0-2-4-6,N3-3-3-1)(Em20-Bm20,B0.05)(E0.02-0.01-0.08).mat')