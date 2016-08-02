%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         基于802.15.6框架下的动态MAC时隙分配，随机选择节点个数
%         Author:Ljg
%         Date:2015/03/18
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
clc

%yf energy threshold,energy for transmission and CCA
global E_th
global N Tslot Data_rate TB Pbg Pgb CW CWmin CWmax UP UPnode Pkt_len   E_TX E_CCA Tsim %isMAP lambdaE Emax Bmax isRAP
%------------802.15.6相关的全局参数---------
UP = 0:7;  %8个优先级
CWmin = [16,16,8,8,4,4,2,1];
CWmax = [64,32,32,16,16,8,8,4];

%----------------------设置参数-----------------------------------------------------
Tsim = 2000; %NO. of superframes simulated
Tslot = 10;  % slot length (ms)
Pkt_len = 512; %packet length, unit is bit
Data_rate = 51.2; % transmission rate (kilo bits per second)
% yf initialize energy
E_th = 1000;
E_CCA = E_th;   %信道检测消耗的能量,发送、接受、侦听比例1:1:1%*******************************%
E_TX = E_th;       %发送数据包需要的能量


TB = 2000; %len_TDMA + len_RAP
act = 2;
%yf omit the MAP
M = 0;   %MAP中询问的时隙块数 M = 7;
T_block = 10;  %MAP中每一个块的时隙数
len_MAP = M*T_block;  %MAP的长度%*******************************%
len_RAP = TB-len_MAP; %RAP阶段固定有100个时隙%*******************************%
UPH = 6;
UPN = 0;
NL = 2:2:18; %3:3:18
%% ------------------------------------------------------------------------
for indE = 1:length(NL)%   多种优先级情况下
%     lambdaE = E_rate(indE);   
    NLnode = NL(indE)/2;
%   -------------设置节点的优先级----------------------------
    UPclass = [UPH,UPN];%0,,6,7
    NH = NL(indE)-NLnode;
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
    Pbg = zeros(1,N);
    Pgb = zeros(1,N);   %如此为理想信道条件，信道恒定为GOOD不变
    
    %------------------初始化电池----------------
    E_buff = (E_th)*ones(1,N); % 初始化各节点能量状态为0 yf改为够传的能量
    
     %----------------仿真变量-----------------------------
    RAP_CHN_Sta = ones(1,N); % initial channel assumed to be GOOD. temperal variable to record every INITIAL state in a superframe
    last_TX_time = ones(1,N); 
    CSMA_Sta_Pre = zeros(1,N);   % initial CSMA state assumed to be all 0 (0:initialization;1:backoff counter;2:sending packets)
    Def_Time_Pre = (-1)*ones(1,N); % initial deferred time -1
    ReTX_time_pre = zeros(1,N);  % 标记节点重传次数
    Succ_TX_time = zeros(Tsim*TB,N);   %记录成功传输的时刻
    Req = zeros(1,N); %是否在发送请求数据包，初始化为0，不发送请求数据包
    

    %--------------一需要统计的结果-------------------------------
    PL_RAP_sp = zeros(Tsim,N);  %丢包数
    Colli_RAP_sp = zeros(Tsim,N);
    PS_RAP_sp = zeros(Tsim,N);   %成功传输的包数           
    ELE_RAP_sp = zeros(Tsim,N);%记录能耗
    Count_sp = zeros(Tsim,N);  %传输数
    %*******************************%
    %能量状态可以不考虑
    %*******************************%
%     B_of_sp = zeros(Tsim,N);%记录溢出的能量
%     B_sp = zeros(Tsim,N);
%     EH_of_sp = zeros(Tsim,N);%记录溢出的能量
    EH_sp = zeros(Tsim,N);
%     %历史状态记录
% %     hist_Act = zeros(Tsim,N);
%yf     hist_E = zeros(Tsim,N);
%     hist_B = zeros(Tsim,N);
%     actTime_sp = zeros(Tsim,1); %*******************************%
    
    Swait = waitbar(0,'仿真进度');   %设置进度条
    last_TX_time_RAP = ones(1,N);
    
    for j = 1: Tsim
        %--------------------RAP阶段使用时隙CSMA/CA时隙分配方式,所有节点参与这个阶段------
        last_TX_time_RAP_ini = ones(1,N);
%         tic
        %yf Act(action),ignore the act ,always RAP %TDMA_CHN_Sta,
        [ReTX_time_pre,Def_Time_Pre,CSMA_Sta_Pre,PL_RAP,PS_RAP,Colli_RAP,ELE_RAP,Succ_TX_time_RAP,E_buff,E_flow,Count] = slotCSMACA_unsat_new00(len_RAP,CSMA_Sta_Pre,Def_Time_Pre,RAP_CHN_Sta,ReTX_time_pre,CW,last_TX_time_RAP_ini,E_buff);%ELE_RAP,（倒数第四）,E_buff,E_flow（最后两个）等一下改 CW可以全局传过去
%         toc
        
        PL_RAP_sp(j,:) = PL_RAP;
        PS_RAP_sp(j,:) = PS_RAP;
        Colli_RAP_sp(j,:) = Colli_RAP;
        ELE_RAP_sp(j,:) = ELE_RAP;
        Count_sp(j,:) = Count;
        for n=1:N
            %更新最近一次成功发包的时间
            if( ~isempty(Succ_TX_time_RAP{n}) )
                %更新成功发包时间记录
                ind_TX_RAP = Succ_TX_time_RAP{n} + (j-1)*TB;  %racover the real index
                last_TX_time(n) =  ind_TX_RAP(end);
                Succ_TX_time(ind_TX_RAP,n) = 1;
                last_TX_time_RAP(n) = last_TX_time(n)-(j-1)*TB;
            end  
        end
        
        %**************************************************************%
        %   不在超帧更新能量，改在每个超帧的时隙更新能量
        %   yf
        %**************************************************************%
           %-------------更新普通节点的能量buffer------------------
%         [E_overflow,B_overflow,E_flow,b_flow,E_buff,B_buff] = buff_update(TB,E_buff,B_buff);
%         B_of_sp(j,:) = B_overflow;
%         B_sp(j,:) = b_flow;  
%         EH_of_sp(j,:) = E_overflow;
        EH_sp(j,:) = E_flow;  %yf 一会儿更改，将e_flow和E_buff放到slotCSMACA_unsat_new 长度从Tsim变成了rap_length
% yf        hist_E(j,:) = E_buff;
%         hist_B(j,:) = B_buff;
        
        %--------------进度显示-------------------------------
         str = ['仿真完成', num2str(j*100/Tsim), '%'];     
         waitbar(j/Tsim,Swait,str);
    end
    close(Swait);

        %--------------yf求信道利用率-------------------------------

    for n=1:N
        ind_Intv = find(Succ_TX_time(:,n)==1);
        Intv(n) = mean( diff(ind_Intv) );
        Slot_ulti(n) = length(ind_Intv)*100/length(Succ_TX_time(:,n));  %信道利用率
    end
    
    %-------------统计通信参数需要的结果-------------------------------
    
    for up=1:length(UPclass)
        indUP = find(UPnode==UPclass(up));
        EH_total(up,indE) = mean( sum( EH_sp(:,indUP) ) );  %总采集到的能量
%         EH_of_t(up,indE) = mean( sum( EH_of_sp(:,indUP) ) );
        
        ELE_RAP_t(up,indE) = mean( sum( ELE_RAP_sp(:,indUP) ) );
        PS_RAP_total(up,indE) = mean( sum( PS_RAP_sp(:,indUP) ) );      %总的RAP阶段发送的超帧数，取所有节点的平均数   
        PL_RAP_total(up,indE) = mean( sum( PL_RAP_sp(:,indUP) ) );      %总的RAP阶段发送的超帧数，取所有节点的平均数   
        Count_total(up,indE) = mean( sum( Count_sp(:,indUP) ) ); 
        
        Colli_t(up,indE) = mean( sum( Colli_RAP_sp(:,indUP) ) );  %总冲突数，取所有节点的平均数                
        Interval_avg(up,indE) = mean( Intv(indUP) );  %平均成功发包间隔 ,去各节点的平均数
        Ulit_rate(up,indE) = mean( Slot_ulti(indUP) ); %平均信道利用率
%         Pktloss = PL_t./(PL_t+PS_t);
        Pktloss_rate(up,indE) = mean( sum( PL_RAP_sp(:,indUP) )./sum( PS_RAP_sp(:,indUP) ) ) ;   %将属于同一优先级的节点的平均丢包率保存起来        
                                                           
    end
%       %-----------------统计整个WBAN的结果---------------------------   

%         Act_time(indE) = mean(actTime_sp);
        EH_WBAN(indE) = sum( sum(EH_sp) )/N;
        %yf
        ELE_of_WBAN(indE) = sum( sum(ELE_RAP_sp) )/N;
        Interval_WBAN(indE) = mean(Intv);
        %yf
        ELE_WBAN(indE) = sum( sum(ELE_RAP_sp) )/N;
        %yf
        PS_WBAN(indE) = sum( sum(PS_RAP_sp) )/N;       
        Colli_WBAN(indE) = sum( sum(Colli_RAP_sp) )/N;
        Pktloss_WBAN(indE) = sum(sum( PL_RAP_sp ))/sum(sum( PS_RAP_sp ));
        
      disp(['indE NumUP: ',num2str([indE N])]) 
end
disp('unsaturation VaringN simulation done!')
save('VarN_MAC(UP0-6,NH1-1-9)(P1_x0.9)(NL1-1-9)(E_th1000).mat');