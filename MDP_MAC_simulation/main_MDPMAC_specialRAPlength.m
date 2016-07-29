%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         ����802.15.6����µĶ�̬MACʱ϶����
%         Author:Ljg
%         Date:2015/03/18
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
clc

%---------����MDPģ������-------------------------------------
% A: action space
% S��state space
% R: reward
% T: state transion probability
% P: optimal strategy
% load MDPresult(UP0,E0.05-B0.05,N2-12,Em20-Bm20).mat

global N Tslot Data_rate TB Pbg Pgb CW CWmin CWmax UP UPnode Pkt_len Emax Bmax lambdaE lambdaB E_TX E_CCA isRAP isMAP

%------------802.15.6��ص�ȫ�ֲ���---------
UP = 0:7;  %8�����ȼ�
CWmin = [16,16,8,8,4,4,2,1];
CWmax = [64,32,32,16,16,8,8,4];

%----------------------���ò���-----------------------------------------------------
Tsim = 50; %NO. of superframes simulated
Tslot = 10;  % slot length (ms)
Pkt_len = 512; %packet length, unit is bit
Data_rate = 51.2; % transmission rate (kilo bits per second)
Emax = 20;%
Bmax = 20;%
E_CCA = 0.025;   %�ŵ�������ĵ�����,���͡����ܡ���������10:5��3
E_TX = 1;       %�������ݰ���Ҫ������
lambdaB = 0.05;   %����ÿ�뵽����

TB_len = 60:20:200; %len_TDMA + len_RAP
% M = 0;   %MAP��ѯ�ʵ�ʱ϶����
% T_block = 10;  %MAP��ÿһ�����ʱ϶��
% len_MAP = M*T_block;  %MAP�ĳ���
% len_RAP = TB-len_MAP; %RAP�׶ι̶���100��ʱ϶

% E_rate = 0.02:0.01:0.08;%
% NLnode = 3:3:18;;%
NH = 4;
UPH = 6;
UPL = 0;
% N = 10;
%% ------------------------------------------------------------------------
for indE = 1:length(TB_len)%   �������ȼ������
        
%---------Varing TB-----------------
     lambdaE = 0.05;
    TB = TB_len(indE);
    M = 0;   %MAP��ѯ�ʵ�ʱ϶����
    T_block = 10;  %MAP��ÿһ�����ʱ϶��
    len_MAP = M*T_block;  %MAP�ĳ���
    len_RAP = TB-len_MAP; %RAP�׶ι̶���100��ʱ϶
    NL = 6;
    UPclass = [UPH,UPL];
    N_UP = [NH,NL];
%   -------------���ýڵ�����ȼ�----------------------------
    %------VarE---------
%     lambdaE = E_rate(indE);
%     UPclass = [0,2,4,6];%0,,6,7
%     N_UP = [3,3,3,1];  %ÿһ�����ȼ��ڵ�ĸ���
     %----VarNL---------
%      lambdaE = 0.05;
%     NL = NLnode(indE);
%      UPclass = [UPH,UPL];
%      N_UP = [NH,NL];
    UPnode = [];
    for up=1:length(UPclass)
       node = UPclass(up)*ones(1,N_UP(up)); 
       UPnode = [UPnode node];
    end
    N = length(UPnode);
    %��ʼ����������
    for n=1:N
        CW(n) = CWmin(find(UP==UPnode(n)));  %��ʼ��CWΪ�ڵ��Ӧ���ȼ���CWmin
    end

    %-----�ŵ�ģ��ʹ������Ʒ������ŵ�״̬��ģ�������ŵ�״̬ת�Ƹ���---------
    % Vc = unifrnd(0.1,0.5,1,N);
    % Sc = unifrnd(0.91,0.99,1,N);
    % Pbg = Sc.*Vc;  %using Markov Chain to model channel,
    % Pgb = Vc-Pbg;  %Pbg is the probability of channel changing from bad to good, Pgb is oppsite
    Pbg = zeros(1,N);
    Pgb = zeros(1,N);   %���Ϊ�����ŵ��������ŵ��㶨ΪGOOD����
    
    %------------------��ʼ����غ����ݻ�����----------------
    E_buff = (0)*ones(1,N); % ��ʼ�����ڵ�����״̬Ϊ0
    B_buff = zeros(1,N);
    
     %----------------�������-----------------------------
    RAP_CHN_Sta = ones(1,N); % initial channel assumed to be GOOD. temperal variable to record every INITIAL state in a superframe
    TDMA_CHN_Sta = ones(1,N);    % initial channel assumed to be GOOD
    last_TX_time = ones(1,N); 
    CSMA_Sta_Pre = zeros(1,N);   % initial CSMA state assumed to be all 0
    Def_Time_Pre = (-1)*ones(1,N); % initial deferred time -1
    ReTX_time_pre = zeros(1,N);  % ��ǽڵ��ش�����
    Succ_TX_time = zeros(Tsim*TB,N);   %��¼�ɹ������ʱ��
    lastout = zeros(1,N);        % last outcome of node i   
    
    %--------------һ��Ҫͳ�ƵĽ��-------------------------------
    PL_RAP_sp = zeros(Tsim,N);  %������
    PL_MAP_sp = zeros(Tsim,N);     
    Colli_RAP_sp = zeros(Tsim,N);
    PS_RAP_sp = zeros(Tsim,N);   %�ɹ�����İ���           
    PS_MAP_sp = zeros(Tsim,N);
    ELE_RAP_sp = zeros(Tsim,N);%��¼�ܺ�
    ELE_MAP_sp = zeros(Tsim,N);
    
    B_of_sp = zeros(Tsim,N);%��¼���������
    B_sp = zeros(Tsim,N);
    EH_of_sp = zeros(Tsim,N);%��¼���������
    EH_sp = zeros(Tsim,N);
    %��ʷ״̬��¼
    hist_Act = zeros(Tsim,N);
    hist_E = zeros(Tsim,N);
    hist_B = zeros(Tsim,N);
    actTime_sp = zeros(Tsim,1);
    
    Swait = waitbar(0,'�������');   %���ý�����
    for j = 1: Tsim        
        hist_E(j,:) = E_buff;
        hist_B(j,:) = B_buff;
        %--------------���߽׶�------------------------  
        tic
        act = 2;
        Act = act*ones(1,N);  %������һ����Ϊ��CMSA/CA����TDMA
          % ����ƽ��������Ϊ
%          %---�ȶ�״̬���й���--------------
%          t_now = (j-1)*TB;
%          for n=1:N
%              TX_time = find(Succ_TX_time==1);  %����ʱ��
%              if( ~isempty( TX_time ) )
%                 last_TX = TX_time(end);     %���һ�δ���ʱ��
%              else
%                  last_TX = 0;
%              end
%              intvSF = j - int32(last_TX/TB);
% %              intvSF
%          end
%         [Act,Reward] = subopt_MDPreslv(lambdaB,floor(B_buff),floor(E_buff),M,T_block,TB,UPnode,UPclass);
        
        isRAP = zeros(1,N); %���ڱ�־�ڵ��Ƿ�ʹ��RAP�׶Σ�������Ŀ��ʹ��RAP���������ݣ����������
        isMAP = zeros(1,N); %���ڱ�־�ڵ��Ƿ�ʹ��MAP�׶�
        indRAP = union( find(Act==2),find(Act==4));
        indMAP = union( find(Act==3),find(Act==4));
        isRAP(indRAP) = 1;
        isMAP(indMAP) = 1;
        hist_Act(j,:) = Act;
        actT = toc;
        disp(['act time is ' num2str(actT)]);
        actTime_sp(j) = actT;  %���¾�����Ҫ��ʱ��
        %--------------------RAP�׶�ʹ��ʱ϶CSMA/CAʱ϶���䷽ʽ,���нڵ��������׶�------
        last_TX_time_RAP = last_TX_time-(j-1)*TB;
        tic
        [ReTX_time_pre,Def_Time_Pre,CSMA_Sta_Pre,TDMA_CHN_Sta,PL_RAP,PS_RAP,Colli_RAP,ELE_RAP,Succ_TX_time_RAP,E_buff,B_buff] = slotCSMACA_MDCMAC(len_RAP,CSMA_Sta_Pre,Def_Time_Pre,RAP_CHN_Sta,ReTX_time_pre,CW,last_TX_time_RAP,E_buff,B_buff);       
        
        PL_RAP_sp(j,:) = PL_RAP;
        PS_RAP_sp(j,:) = PS_RAP;
        Colli_RAP_sp(j,:) = Colli_RAP;
        ELE_RAP_sp(j,:) = ELE_RAP_sp(j,:) + ELE_RAP;
        for n=1:N
            %�������һ�γɹ�������ʱ��
            if( ~isempty(Succ_TX_time_RAP{n}) )
                %���³ɹ�����ʱ���¼
                ind_TX_RAP = Succ_TX_time_RAP{n} + (j-1)*TB;  %racover the real index
                last_TX_time(n) =  ind_TX_RAP(end);
                Succ_TX_time(ind_TX_RAP,n) = 1;
            end  
        end
         t_rap = toc;
        %--------------MAP �׶Σ�ʹ��TDMA��ʽ����ʱ϶--------------;               
         start = (j-1)*TB + len_RAP + 1; 
         TDMA_sift = 0;   %ƫ����  
         tic;
         indMAP = find(isMAP==1);
         indPoll = getPollNode(indMAP,M);  %ȷ������poll�Ľڵ�
         for poll =1:length(indPoll)   %�������и����ȼ��ڵ�ľ�����Ϊ     
             ind_node_poll = indPoll(poll); %ȡ�±�
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
           %---------------------����ͳ�Ʊ���------------------------
            TDMA_sift = TDMA_sift + T_block; %����ÿ���ڵ���䵽��ʱ϶������ƫ����                    
            ELE_MAP_sp(j,ind_node_poll) = ELE_MAP_sp(j,ind_node_poll) + ELE_MAP;  %���ĵ��������� 
            PL_MAP_sp(j,ind_node_poll) = PL_td;
            PS_MAP_sp(j,ind_node_poll) = PS_td;                                              
         end   
         t_map = toc;
           %-------------������ͨ�ڵ������bufer------------------
        [E_overflow,B_overflow,e_flow,b_flow,E_buff,B_buff] = buff_update(TB,E_buff,B_buff);
        B_of_sp(j,:) = B_overflow;
        B_sp(j,:) = b_flow;  
        EH_of_sp(j,:) = E_overflow;
        EH_sp(j,:) = e_flow; 
        [actT t_rap t_map]
        %--------------������ʾ-------------------------------
         str = ['�������', num2str(j*100/Tsim), '%'];     
         waitbar(j/Tsim,Swait,str);
    end
    close(Swait);

    for n=1:N
        ind_Intv = find(Succ_TX_time(:,n)==1);
        Intv(n) = mean( diff(ind_Intv) );
        Slot_ulti(n) = length(ind_Intv)*100/length(Succ_TX_time(:,n));  %�ŵ�������
    end
    
    %-------------ͳ��ͨ�Ų�����Ҫ�Ľ��-------------------------------
    for up=1:length(UPclass)
        indUP = find(UPnode==UPclass(up));
                
        EH_total(up,indE) = mean( sum( EH_sp(:,indUP) ) );  %�ܲɼ���������
        EH_of_t(up,indE) = mean( sum( EH_of_sp(:,indUP) ) );
        B_total(up,indE) = mean( sum( B_sp(:,indUP) ) );  %�ܲɼ���������
        B_overflow_t(up,indE) = mean( sum( B_of_sp(:,indUP) ) );
        
        ELE_RAP_t(up,indE) = mean( sum( ELE_RAP_sp(:,indUP) ) );
        ELE_MAP_t(up,indE) = mean( sum( ELE_MAP_sp(:,indUP) ) );
        PS_RAP_total(up,indE) = mean( sum( PS_RAP_sp(:,indUP) ) );      %�ܵ�RAP�׶η��͵ĳ�֡����ȡ���нڵ��ƽ����   
        PS_MAP_total(up,indE) = mean( sum( PS_MAP_sp(:,indUP) ) );
        PL_RAP_total(up,indE) = mean( sum( PL_RAP_sp(:,indUP) ) );      %�ܵ�RAP�׶η��͵ĳ�֡����ȡ���нڵ��ƽ����   
        PL_MAP_total(up,indE) = mean( sum( PL_MAP_sp(:,indUP) ) );
      
        Colli_t(up,indE) = mean( sum( Colli_RAP_sp(:,indUP) ) );  %�ܳ�ͻ����ȡ���нڵ��ƽ����                
        Interval_avg(up,indE) = mean( Intv(indUP) );  %ƽ���ɹ�������� ,ȥ���ڵ��ƽ����
        Ulit_rate(up,indE) = mean( Slot_ulti(indUP) ); %ƽ���ŵ�������
%         Pktloss = PL_t./(PL_t+PS_t);
        Pktloss_rate(up,indE) = mean( sum( PL_RAP_sp(:,indUP)+PL_MAP_sp(:,indUP) )./sum( PS_RAP_sp(:,indUP)+PS_MAP_sp(:,indUP) ) );   %������ͬһ���ȼ��Ľڵ��ƽ�������ʱ�������        
                              
    end
%       %-----------------ͳ������WBAN�Ľ��---------------------------    
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
% disp('MDP based centralized MAC simulation done!')
% save('MDP_VarE_MDCMAC(UP0-2-4-6,N3-3-3-1)(Em20-Bm20,B0.05)(E0.02-0.01-0.08).mat');
% save('Edt2_MDP_VarN_MDCMAC(UP0-6,NH4)(Em20-Bm20,B0.05-E0.05)(NL3-3-18).mat');

%---------simulation for varing CSMA/CA periods length
disp('Varing CSMA/CA periods length simulation done!')