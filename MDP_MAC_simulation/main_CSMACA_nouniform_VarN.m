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

global N Tslot Data_rate TB Pbg Pgb CW CWmin CWmax UP UPnode Pkt_len Emax E_TX E_CCA

%------------802.15.6相关的全局参数---------
UP = 0:7;  %8个优先级
CWmin = [16,16,8,8,4,4,2,1];
CWmax = [64,32,32,16,16,8,8,4];

%----------------------设置参数-----------------------------------------------------
Tsim = 200; %NO. of superframes simulated
Tslot = 10;  % slot length (ms)
Pkt_len = 512; %packet length, unit is bit
Data_rate = 51.2; % transmission rate (kilo bits per second)
Emax = 50;%
E_CCA = 0.025;   %信道检测消耗的能量,发送、接受、侦听比例10:5：3
E_TX = 1;       %发送数据包需要的能量
lambdaE = 0.1;   %能量每时隙到达数

TB = 200; %len_TDMA + len_RAP
act = 1;
N_hup = 4;   %固定的高优先级节点数
T_block = 16;  %MAP中每一个块的时隙数
len_RAP = TB; %RAP阶段固定de 时隙
UP_high = 0;
UP_low = 0;
% N = 10;
%--------------------------------------------------------------------------
indE = 0;
NumUP = 6;
for NumUP = 0:2:12%   多种优先级情况下
    indE = indE + 1;
%   -------------设置节点的优先级----------------------------
    UPclass= [UP_high,UP_low];%使用混合的优先级配置，WBAN中优先级种类     
    N_lup = NumUP;  %变化的普通优先级节点数
    UPnode = [ UPclass(1)*ones(1,N_hup) UPclass(2)*ones(1,N_lup) ]; %记录每个节点的优先级
    N = length(UPnode);    %WBAN中总的节点数
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
    E_buff = (0)*ones(1,N); % 初始化各节点能量状态为满Emax-1
    
     %----------------仿真变量-----------------------------
    RAP_CHN_Sta = ones(1,N); % initial channel assumed to be GOOD. temperal variable to record every INITIAL state in a superframe
    TDMA_CHN_Sta = ones(1,N);    % initial channel assumed to be GOOD
    last_TX_time = ones(1,N); 
    CSMA_Sta_Pre = zeros(1,N);   % initial CSMA state assumed to be all 0
    Def_Time_Pre = (-1)*ones(1,N); % initial deferred time -1
    ReTX_time_pre = zeros(1,N);  % 标记节点重传次数
    Succ_TX_time = zeros(Tsim*TB,N);   %记录成功传输的时刻
    lastout = zeros(1,N);        % last outcome of node i
    Colli_eff = ones(1,N);       %冲突影响因子，冲突影响竞争窗口的更新

    %--------------一需要统计的结果-------------------------------
    PL_RAP_sp = zeros(Tsim,N);  %丢包数    
    Colli_RAP_sp = zeros(Tsim,N);
    PS_RAP_sp = zeros(Tsim,N);   %成功传输的包数           
    ELE_RAP_sp = zeros(Tsim,N);%记录能耗
    ELE_of_sp = zeros(Tsim,N);%记录溢出的能量
    EH_sp = zeros(Tsim,N);
    hist_E = zeros(Tsim,N);
    
    Swait = waitbar(0,'仿真进度');   %设置进度条
    for j = 1: Tsim
        %--------------------RAP阶段使用时隙CSMA/CA时隙分配方式,所有节点参与这个阶段------
        last_TX_time_RAP = last_TX_time-(j-1)*TB;
%         tic
        [ReTX_time_pre,Def_Time_Pre,CSMA_Sta_Pre,TDMA_CHN_Sta,PL_RAP,PS_RAP,Colli_RAP,ELE_RAP,Succ_TX_time_RAP,E_overflow_RAP,EH_RAP,E_buff] = slotCSMACA_nouniform(len_RAP,CSMA_Sta_Pre,Def_Time_Pre,RAP_CHN_Sta,ReTX_time_pre,CW,last_TX_time_RAP,lambdaE,E_buff,Colli_eff);
%         toc
        
        PL_RAP_sp(j,:) = PL_RAP_sp(j,:) + PL_RAP;
        PS_RAP_sp(j,:) = PS_RAP_sp(j,:) + PS_RAP;
        Colli_RAP_sp(j,:) = Colli_RAP_sp(j,:) + Colli_RAP;
        %----更新冲突影响因子---------------
        Colli_eff = ( 1 - Colli_RAP./sum(Colli_RAP) ).*E_buff/Emax;
        ELE_RAP_sp(j,:) = ELE_RAP_sp(j,:) + ELE_RAP;  %消耗的能量增加
        ELE_of_sp(j,:) = ELE_of_sp(j,:) + E_overflow_RAP;
        EH_sp(j,:) = EH_sp(j,:) + EH_RAP;
        for n=1:N
            %更新最近一次成功发包的时间
            if( ~isempty(Succ_TX_time_RAP{n}) )
                %更新成功发包时间记录
                ind_TX_RAP = Succ_TX_time_RAP{n} + (j-1)*TB;  %racover the real index
                last_TX_time(n) =  ind_TX_RAP(end);
                Succ_TX_time(ind_TX_RAP,n) = 1;
            end  
        end         
        %--------------进度显示-------------------------------
         str = ['仿真完成', num2str(j*100/Tsim), '%'];     
         waitbar(j/Tsim,Swait,str);
    end
    close(Swait);

    %-----------------------------
    PL_t = sum(PL_RAP_sp);
    PS_t = sum(PS_RAP_sp);
    %-----------------------------     
    for n=1:N
        ind_Intv = find(Succ_TX_time(:,n)==1);
        Intv(n) = mean( diff(ind_Intv) );
        Slot_ulti(n) = length(ind_Intv)*100/length(Succ_TX_time(:,n));  %信道利用率
    end
    
    %-------------统计通信参数需要的结果-------------------------------
    for up=1:length(UPclass)
        indUP = find(UPnode==UPclass(up));
        
        Sk(up,indE) = mean( mean( PS_RAP_sp(:,indUP) )/len_RAP );   %吞吐量：单位时隙能发的包数
        Ek(up,indE) =  mean( mean( EH_sp(:,indUP) )/len_RAP );  %能耗，单位时隙的能耗
        
        ELE_RAP_t(up,indE) = mean( sum( ELE_RAP_sp(:,indUP) ) );
        EH_total(up,indE) = mean( sum( EH_sp(:,indUP) ) );  %总采集到的能量
        ELE_overflow_t(up,indE) = mean( sum( ELE_of_sp(:,indUP) ) );

        PS(up,indE) = mean( PS_t(:,indUP) );      %总的RAP阶段发送的超帧数，取所有节点的平均数   
        Colli_t(up,indE) = mean( sum( Colli_RAP_sp(:,indUP) ) );  %总冲突数，取所有节点的平均数         
       
        Interval_avg(up,indE) = mean( Intv(indUP) );  %平均成功发包间隔 ,去各节点的平均数
        Ulit_rate(up,indE) = mean( Slot_ulti(indUP) ); %平均信道利用率
        Pktloss = PL_t./(PL_t+PS_t);
        Pktloss_rate(up,indE) = mean( Pktloss(indUP) );   %将属于同一优先级的节点的平均丢包率保存起来                      
    end
    disp(['indE NumUP lambdaE: ',num2str([indE NumUP lambdaE])]) ;
end
disp('unsaturation VaringN simulation done!')

save('adaptiveCW1_CSMACA_VaringN(UPH0-UPL0,NH4-E0.05)(NL0-2-12).mat');
%% ----------------------
% save('staticpara_CSMACA_VaringE(UPH3-UPL0,NH1-NL6)(E0.04-0.02-0.24).mat',
% 'Sk','Ek');