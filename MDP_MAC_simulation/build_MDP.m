%% ����״̬ת�Ƹ��ʾ�������溯����ʹ��ֵ�����㷨������Ų���
clear all
clc

addpath('MDPtoolbox');
%% ----------�������----------------------------------
%------------ȫ�ֱ���------------
global block State Act TB Emax Bmax lambdaE lambdaB E_tx RAP Delta
len_Pkt = 1;  %����һ������Ҫ��ʱ϶��
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

%-----------------�ֲ�����-----------
UP_indeed = [0,2,4,6];  %WBAN�д��ڵ����ȼ����
N_up = [2,2,2,1];
N = sum(N_up);
Delta = M/N*block;
lambdaB = 0.05; %const pkt rate
E_rate = 0.02:0.01:0.08; %varing energy rate
gamma = 0.6;   % �ۿ�����
epsi = 0.01;  %������ֹ����
maxiter = 100; %����������

%% -----------����ͳ�Ƶ�ͨ�Ų���---------------------------------------
%-------------------------------VarE----------------------------
%----����ͳ��ֵ
load MDP_result(UP0-2-4-6,N3-3-3-1)(Em20-Bm20,B0.05)(E0.02-0.01-0.08).mat
load para_CSMACA(theory)(UP0-2-4-6,N3-3-3-1).mat 
Ps = Ps*Ptr; %�ڵ�ÿ��ʱ϶�ɹ��������ݵĸ���
%ע���������ÿ�����ȼ���CSMA�еİ�������S���ܺ�E������1*4������

N1 = length(E_rate);
N2 = length(S);
%% �����нڵ����������MDPtoolbox���ֵ��������������Ų��� 
% T = cell(N1,N2);
R = cell(N1,N2);
P = cell(N1,N2);

for indE = 1:length(E_rate)
    lambdaE = E_rate(indE);
    for n=1:N2%
        disp(['build MDP for UP' num2str(UP_indeed(n)) ' when lambdaE is ' num2str(lambdaE)]);
    %----------------����MDPģ�ͣ�����ת�Ƹ��ʾ�������溯��------------         
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
        %---�������溯�����з���-----------------
    %          plot(R1,'d');
    %          legend('a==0','a==1','a==2','a==3');
        %------------------------ʹ��ֵ�����㷨���------------------------
        V0 = zeros(length(State),1);
        [p, iter, cpu_time] = mdp_value_iteration(T1, R1, gamma, epsi, maxiter, V0);
        disp(['resolve MDP done! iteration is ',num2str(iter),' consumed time is ',num2str(cpu_time),'seconds.'])
    %         p(ind0) = 4;   %ǿ��ʹB==0||E==0ʱʹ�õ�4����Ϊ
        P{indE,n} = p;       
    end
end
% stem(policy);
save('MDP_result(UP0-2-4-6,N3-3-3-1)(Em20-Bm20,B0.05)(E0.02-0.01-0.08).mat')