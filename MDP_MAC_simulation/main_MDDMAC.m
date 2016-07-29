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

global N Tslot Data_rate TB Pbg Pgb CW CWmin CWmax UP UPnode Pkt_len Emax Bmax lambdaE lambdaB E_TX E_CCA isRAP isMAP
%% 载入MDP结果
load MDP_result(UP0-6,NH4)(Em20-Bm20,B0.05-E0.05)(NL3-3-18).mat
%------------802.15.6相关的全局参数---------
UP = 0:7;  %8个优先级
CWmin = [16,16,8,8,4,4,2,1];
CWmax = [64,32,32,16,16,8,8,4];

%----------------------设置参数-----------------------------------------------------
Tsim = 200; %NO. of superframes simulated
Tslot = 10;  % slot length (ms)
Pkt_len = 512; %packet length, unit is bit
Data_rate = 51.2; % transmission rate (kilo bits per second)
Emax = 20;%
Bmax = 20;%
E_CCA = 0.025;   %信道检测消耗的能量,发送、接受、侦听比例10:5：3
E_TX = 1;       %发送数据包需要的能量
lambdaB = 0.05;   %数据包每秒到达数
lambdaE = 0.05;   %能量每秒到达数

TB = 200; %len_TDMA + len_RAP
act = 2;
M = 7;   %MAP中询问的时隙块数
T_block = 10;  %MAP中每一个块的时隙数
len_MAP = M*T_block;  %MAP的长度
len_RAP = TB-len_MAP; %RAP阶段固定有100个时隙
% E_rate = 0.02:0.01:0.08;
UPH = 6;
UPN = 0;
NH = 4;
NL = 3:3:18;
%% ------------------------------------------------------------------------
for indE = 1:length(NL)%   多种优先级情况下
%     lambdaE = E_rate(indE);   
    NLnode = NL(indE);
%   -------------设置节点的优先级----------------------------
    UPclass = [UPH,UPN];%0,,6,7
    N_UP = [NH,NLnode];  %每一种优先级节点的个数
    UPnode = [];
    for up=1:length(UPclass)
       node = UPclass(up)*ones(1,N_UP(up)); 
       UPnode = [UPnode node];
    end
    N = length(UPnode);
    %初始化竞争窗口
    for n=1:N
        CW(n) = CWmin(find(UP==UPnode(n)));  %初始化CW为节点对应优先级的CWmin
    end

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
    
     %----------------仿真变量-----------------------------
    RAP_CHN_Sta = ones(1,N); % initial channel assumed to be GOOD. temperal variable to record every INITIAL state in a superframe
    TDMA_CHN_Sta = ones(1,N);    % initial channel assumed to be GOOD
    last_TX_time = ones(1,N); 
    CSMA_Sta_Pre = zeros(1,N);   % initial CSMA state assumed to be all 0
    Def_Time_Pre = (-1)*ones(1,N); % initial deferred time -1
    ReTX_time_pre = zeros(1,N);  % 标记节点重传次数
    Succ_TX_time = zeros(Tsim*TB,N);   %记录成功传输的时刻
    lastout = zeros(1,N);        % last outcome of node i
    G = ones(1,N);   %MAP时隙资格初始化为1
    Req = zeros(1,N); %是否在发送请求数据包，初始化为0，不发送请求数据包
    isRAP = ones(1,N); %用于标志节点是否使用RAP阶段，有两个目的使用RAP：发送数据，发送请求包
    isMAP = ones(1,N); %用于标志节点是否使用MAP阶段
    

    %--------------一需要统计的结果-------------------------------
    PL_RAP_sp = zeros(Tsim,N);  %丢包数
    PL_MAP_sp = zeros(Tsim,N);     
    Colli_RAP_sp = zeros(Tsim,N);
    PS_RAP_sp = zeros(Tsim,N);   %成功传输的包数           
    PS_MAP_sp = zeros(Tsim,N);
    ELE_RAP_sp = zeros(Tsim,N);%记录能耗
    ELE_MAP_sp = zeros(Tsim,N);
    
    B_of_sp = zeros(Tsim,N);%记录溢出的能量
    B_sp = zeros(Tsim,N);
    EH_of_sp = zeros(Tsim,N);%记录溢出的能量
    EH_sp = zeros(Tsim,N);
    %历史状态记录
    hist_Act = zeros(Tsim,N);
    hist_E = zeros(Tsim,N);
    hist_B = zeros(Tsim,N);
    hist_MAP = zeros(Tsim,M);
    actTime_sp = zeros(Tsim,1);
    
    Swait = waitbar(0,'仿真进度');   %设置进度条
    for j = 1: Tsim
        %--------------决策阶段------------------------  
%         action = act*ones(1,N);  %都采用一种行为，CMSA/CA或者TDMA
        tic;
        for nh =1:N
            stateInd = findSta( State,floor(E_buff(nh)),B_buff(nh),G(nh) );   %根据状态获取策略行为
            up = find( UPclass==UPnode(nh) );
            Policy = P{indE,up};  %获取节点对应的策略表
            action(nh) = Policy(stateInd);  %查表获取行为
            %判断是否要发送req
            if( G(nh)==0 )
                if(Act(action(nh))==0)
                   isRAP(nh) = 0;  %确定是否使用RAP
                else
                   isRAP(nh) = 1;
                end
            else
                if( Act(action(nh))==3)
                  isRAP(nh) = 0;
                  isMAP(nh) = 1;  %节点直接可以使用MAP阶段
                else
                  isRAP(nh) = 1;
               end
                
            end
        end
        actT = toc;
        disp(['act time is ' num2str(actT)]);
        actTime_sp(j) = actT;
        hist_Act(j,:) = action;
        %--------------------RAP阶段使用时隙CSMA/CA时隙分配方式,所有节点参与这个阶段------
        last_TX_time_RAP = last_TX_time-(j-1)*TB;
%         tic
        [ReTX_time_pre,Def_Time_Pre,CSMA_Sta_Pre,TDMA_CHN_Sta,PL_RAP,PS_RAP,Colli_RAP,ELE_RAP,Succ_TX_time_RAP,E_buff,B_buff] = slotCSMACA_unsat(Act(action),len_RAP,CSMA_Sta_Pre,Def_Time_Pre,RAP_CHN_Sta,ReTX_time_pre,CW,last_TX_time_RAP,E_buff,B_buff);
%         toc
        
        PL_RAP_sp(j,:) = PL_RAP;
        PS_RAP_sp(j,:) = PS_RAP;
        Colli_RAP_sp(j,:) = Colli_RAP;
        ELE_RAP_sp(j,:) = ELE_RAP;
        for n=1:N
            %更新最近一次成功发包的时间
            if( ~isempty(Succ_TX_time_RAP{n}) )
                %更新成功发包时间记录
                ind_TX_RAP = Succ_TX_time_RAP{n} + (j-1)*TB;  %racover the real index
                last_TX_time(n) =  ind_TX_RAP(end);
                Succ_TX_time(ind_TX_RAP,n) = 1;
            end  
        end

        %--------------MAP 阶段，使用TDMA方式分配时隙--------------;               
         start = (j-1)*TB + len_RAP + 1; 
         TDMA_sift = 0;   %偏移量  
         indMAP = find(isMAP==1);
         indPoll = getPollNode(indMAP,M);  %确定将被poll的节点
         hist_MAP(j,1:length(indPoll))=indPoll;
         for poll =1:length(indPoll)   %遍历所有高优先级节点的决策行为     
             ind_node_poll = indPoll(poll); %取下标
            %----------scheduled slots---------------
            CHNafter_leng = 0;
            CHNbefore_leng = start + TDMA_sift - last_TX_time(ind_node_poll);
            last_TX_time_MAP = last_TX_time(n) - CHNbefore_leng - TDMA_sift;
            [PL_td,PS_td,lastout(ind_node_poll),TDMA_CHN_Sta(ind_node_poll),Succ_TX_time_td,ELE_MAP,E_buff(ind_node_poll),B_buff(ind_node_poll)] = pktsendTDMA_unsat( CHNbefore_leng,CHNafter_leng,TDMA_CHN_Sta((ind_node_poll)),T_block,Pbg((ind_node_poll)),Pgb((ind_node_poll)),E_buff((ind_node_poll)),B_buff((ind_node_poll)));
            if(~isempty(Succ_TX_time_td))
                %recover the real index                        
                ind_TX_MAP = Succ_TX_time_td + start + TDMA_sift;
                last_TX_time(ind_node_poll) = ind_TX_MAP(end);
                Succ_TX_time(ind_TX_MAP,ind_node_poll) = 1;
            end
           %---------------------更新统计变量------------------------
            TDMA_sift = TDMA_sift + T_block; %根据每个节点分配到的时隙数增加偏移量                    
            ELE_MAP_sp(j,ind_node_poll) = ELE_MAP_sp(j,ind_node_poll) + ELE_MAP;  %消耗的能量增加 
            PL_MAP_sp(j,ind_node_poll) = PL_td;
            PS_MAP_sp(j,ind_node_poll) = PS_td;                                              
         end   
         
         %更新G的值
         G = isMAP;         
           %-------------更新普通节点的能量bufer------------------
        [E_overflow,B_overflow,e_flow,b_flow,E_buff,B_buff] = buff_update(TB,E_buff,B_buff);
        B_of_sp(j,:) = B_overflow;
        B_sp(j,:) = b_flow;  
        EH_of_sp(j,:) = E_overflow;
        EH_sp(j,:) = e_flow; 
        hist_E(j,:) = E_buff;
        hist_B(j,:) = B_buff;
        
        %--------------进度显示-------------------------------
         str = ['仿真完成', num2str(j*100/Tsim), '%'];     
         waitbar(j/Tsim,Swait,str);
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
                
        EH_total(up,indE) = mean( sum( EH_sp(:,indUP) ) );  %总采集到的能量
        EH_of_t(up,indE) = mean( sum( EH_of_sp(:,indUP) ) );
        B_total(up,indE) = mean( sum( B_sp(:,indUP) ) );  %总采集到的能量
        B_overflow_t(up,indE) = mean( sum( B_of_sp(:,indUP) ) );
        
        ELE_RAP_t(up,indE) = mean( sum( ELE_RAP_sp(:,indUP) ) );
        ELE_MAP_t(up,indE) = mean( sum( ELE_MAP_sp(:,indUP) ) );
        PS_RAP_total(up,indE) = mean( sum( PS_RAP_sp(:,indUP) ) );      %总的RAP阶段发送的超帧数，取所有节点的平均数   
        PS_MAP_total(up,indE) = mean( sum( PS_MAP_sp(:,indUP) ) );
        PL_RAP_total(up,indE) = mean( sum( PL_RAP_sp(:,indUP) ) );      %总的RAP阶段发送的超帧数，取所有节点的平均数   
        PL_MAP_total(up,indE) = mean( sum( PL_MAP_sp(:,indUP) ) );
      
        Colli_t(up,indE) = mean( sum( Colli_RAP_sp(:,indUP) ) );  %总冲突数，取所有节点的平均数                
        Interval_avg(up,indE) = mean( Intv(indUP) );  %平均成功发包间隔 ,去各节点的平均数
        Ulit_rate(up,indE) = mean( Slot_ulti(indUP) ); %平均信道利用率
%         Pktloss = PL_t./(PL_t+PS_t);
        Pktloss_rate(up,indE) = mean( sum( PL_RAP_sp(:,indUP)+PL_MAP_sp(:,indUP) )./sum( PS_RAP_sp(:,indUP)+PS_MAP_sp(:,indUP) ) );   %将属于同一优先级的节点的平均丢包率保存起来        
                              
    end
%       %-----------------统计整个WBAN的结果---------------------------   
        Act_time(indE) = mean(actTime_sp);
        EH_WBAN(indE) = sum( sum(EH_sp) )/N;
        B_WBAN(indE) = sum( sum(B_sp) )/N;
        ELE_of_WBAN(indE) = sum( sum(ELE_MAP_sp+ELE_RAP_sp) )/N;
        B_of_WBAN(indE) = sum( sum(B_of_sp) )/N;
        
        Interval_WBAN(indE) = mean(Intv);
        ELE_WBAN(indE) = sum( sum(ELE_RAP_sp+ELE_MAP_sp) )/N;
        PS_WBAN(indE) = sum( sum(PS_RAP_sp+PS_MAP_sp) )/N;
        Colli_WBAN(indE) = sum( sum(Colli_RAP_sp) )/N;
        Pktloss_WBAN(indE) = sum(sum( PL_RAP_sp+PL_MAP_sp ))/sum(sum( PS_RAP_sp+PS_MAP_sp ));
    disp(['indE NumUP lambdaE: ',num2str([indE N lambdaE])]) ;
end
disp('unsaturation VaringN simulation done!')
save('new_MDP_VarN_MDDMAC(UP0-6,NH4)(Em20-Bm20,B0.05-E0.05)(NL3-3-18).mat');