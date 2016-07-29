%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         基于802.15.6框架下的动态MAC时隙分配
%         Author:Ljg
%         Date:2015/03/18
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
clc

%---------载入MDP模型数据-------------------------------------
% A: action space
% S：state space
% R: reward
% T: state transion probability
% P: optimal strategy
% load MDPresult(UP0,E0.05-B0.05,N2-12,Em20-Bm20).mat

global E_TX E_CCA t Succ_TX_time Emax Bmax lambdaE lambdaB B_of EH_of B EH%CWmin CWmax UP UPnode 
%% 载入MDP结果
%------------802.15.6相关的全局参数---------
UP = 0:7;  %8个优先级
CWmin = [16,16,8,8,4,4,2,1];
CWmax = [64,32,32,16,16,8,8,4];

%----------------------设置参数---------------
Tslot = 10;  % slot length (ms)
Pkt_len = 512; %packet length, unit is bit
Data_rate = 51.2; % transmission rate (kilo bits per second)
Emax = 20;%
Bmax = 20;%
%
lambdaB = 0.05;
block = 1;
E_CCA = 0.025;   %信道检测消耗的能量,发送、接受、侦听比例10:5：3
E_TX = 1;       %发送数据包需要的能量
TB = 200; %len_TDMA + len_RAP
Tsim = 200; %NO. of superframes simulated
% E_rate = 0.02:0.01:0.08;
UPH = 6;
UPL = 0;
NH = 4;
% NLnode = 3:3:18;
E_rate=0.02:0.01:0.08;
Tpcmin = 2;
%% ------------------------------------------------------------------------
for indE = 1:length(E_rate)%   多种优先级情况下
%     NL = NLnode(indE);
%     lambdaE = 0.05;
    NL = 6;
    lambdaE = E_rate(indE);
    
    UPclass = [UPH,UPL];%0,,6,7    
    N_UP = [NH,NL];  %每一种优先级节点的个数
    UPnode = [];
    for up=1:length(UPclass)
       node = UPclass(up)*ones(1,N_UP(up)); 
       UPnode = [UPnode node];
    end
    indL = find( UPnode==UPclass(find(UPclass==UPL)) );
    indH = find( UPnode==UPclass(find(UPclass==UPH)) );
    N = length(UPnode);
    T_intv = max(1/lambdaE,1/lambdaB);
    %-----信道模型使用马尔科夫链对信道状态建模，设置信道状态转移概率---------
    % Vc = unifrnd(0.1,0.5,1,N);
    % Sc = unifrnd(0.91,0.99,1,N);
    % Pbg = Sc.*Vc;  %using Markov Chain to model channel,
    % Pgb = Vc-Pbg;  %Pbg is the probability of channel changing from bad to good, Pgb is oppsite
    Pbg = zeros(1,N);
    Pgb = zeros(1,N);   %如此为理想信道条件，信道恒定为GOOD不变
    
    %------------------初始化电池和数据缓存区----------------
    E_buff = (0)*ones(1,N); % 初始化各节点能量状态为0
    B_buff = zeros(1,N);
    
    %--------------一需要统计的结果-------------------------------  
    Colli = zeros(1,N);
    PS = zeros(1,N);   %成功传输的包数           
    ELE = zeros(1,N);%记录能耗
    
    B_of = zeros(1,N);%记录溢出的能量
    B = zeros(1,N);
    EH_of = zeros(1,N);%记录溢出的能量
    EH = zeros(1,N);
    last_TX_time = ones(1,N); 
    %历史状态记录
    hist_E = zeros(Tsim,N);
    hist_B = zeros(Tsim,N);
    
    Swait = waitbar(0,'仿真进度');   %设置进度条
    t = 0;
    T = Tsim*TB;
    Succ_TX_time = zeros(T,N);
    flag = 0;
    while(t<=T&&flag==0)
        [PS_PC,Colli_PC,ELE_PC,E_buff,B_buff] = PC_poll(1,E_buff(indL),B_buff(indL),indL); 
        ELE = ELE + ELE_PC;
        PS = PS + PS_PC;
        Colli = Colli + Colli_PC; 
        [E_overflow,B_overflow,e_flow,b_flow,E_buff,B_buff] = buff_update_HEHMAC(L_idle,E_buff(indH),B_buff(indH),lambdaE,lambdaB,Emax,Bmax);
        B_of(indH) = B_of(indH) + B_overflow;
        B(indH) = B(indH) + b_flow;  
        EH_of(indH) = EH_of(indH) + E_overflow;
        EH(indH) = EH(indH) + e_flow; 
       
        %--------------进度显示-------------------------------
         str = ['仿真完成', num2str(t*100/T), '%'];     
         waitbar(t/T,Swait,str);
    end
    close(Swait);

    for n=1:N
        ind_Intv = find(Succ_TX_time(:,n)==1);
        Intv(n) = mean( diff(ind_Intv) );
        Slot_ulti(n) = length(ind_Intv)*100/length(Succ_TX_time(:,n));  %信道利用率
    end
    
    %-------------统计通信参数需要的结果-------------------------------
    for up=1:length(UPclass)
        indUP = find(UPnode==UPclass(up));
                
        EH_t(up,indE) = mean( EH(:,indUP) );  %总采集到的能量
        EH_of_t(up,indE) = mean( EH_of(:,indUP) );
        B_t(up,indE) = mean( B(:,indUP) );  %总采集到的能量
        B_of_t(up,indE) = mean( B_of(:,indUP) );
       Interval_avg(up,indE) = mean( Intv(indUP) );  %平均成功发包间隔 ,去各节点的平均数
                
%         Ulit_rate(up,indE) = mean( Slot_ulti(indUP) ); %平均信道利用率
%         Pktloss = PL_t./(PL_t+PS_t);
%         Pktloss_rate(up,indE) = mean( sum( PL_RAP_sp(:,indUP)+PL_MAP_sp(:,indUP) )./sum( PS_RAP_sp(:,indUP)+PS_MAP_sp(:,indUP) ) );   %将属于同一优先级的节点的平均丢包率保存起来        
                              
    end
        ELE_L_t(indE) = mean( ELE_L);
        ELE_H_t(indE) = mean( ELE_H );
        PS_L_t(indE) = mean( PS_L );      %总的RAP阶段发送的超帧数，取所有节点的平均数   
        PS_H_t(indE) = mean( PS_H );       
      
        Colli_t(indE) = mean(Colli_L);  %总冲突数，取所有节点的平均数                        %     
    disp(['indE NumUP lambdaE: ',num2str([indE N lambdaE])]) ;
end
disp('unsaturation VaringN-E simulation done!')
save('ProbPoll_VarE(UP0-6,NH4-NL6)(Em20-Bm20,B0.05)(E0.02-0.01-0.08).mat');