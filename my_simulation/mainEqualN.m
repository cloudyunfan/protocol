%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         ����802.15.6����µĶ�̬MACʱ϶���䣬���ѡ��ڵ����
%         Author:Ljg
%         Date:2015/03/18
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
clc

%yf energy threshold,energy for transmission and CCA
global E_th
global N Tslot Data_rate TB Pbg Pgb CW CWmin CWmax UP UPnode Pkt_len E_TX E_CCA Tsim %isMAP lambdaE Emax Bmax isRAP
%yf probability of arrive one unit energy in each slot
global P1_x
%------------802.15.6��ص�ȫ�ֲ���---------
UP = 0:7;  %8�����ȼ�
CWmin = [16,16,8,8,4,4,2,1];
CWmax = [64,32,32,16,16,8,8,4];

%----------------------���ò���-----------------------------------------------------
Tsim = 200; %NO. of superframes simulated
Tslot = 376*10^(-6);  % slot length (ms)
Pkt_len = 512; %packet length, unit is bit
Data_rate = 51.2; % transmission rate (kilo bits per second)
% yf initialize energy
E_th = 50;
E_CCA = E_th/10;   %�ŵ�������ĵ�����,���͡����ܡ���������1:1:1%*******************************%
E_TX = E_th;       %�������ݰ���Ҫ������
P1_x = 0.6;

TB = 2000; %len_TDMA + len_RAP
act = 2;
%yf omit the MAP
M = 0;   %MAP��ѯ�ʵ�ʱ϶���� M = 7;
T_block = 10;  %MAP��ÿһ�����ʱ϶��
len_MAP = M*T_block;  %MAP�ĳ���%*******************************%
len_RAP = TB-len_MAP; %RAP�׶ι̶���100��ʱ϶%*******************************%
% UPH = 6;
% UPN = 0; 
%0,,6,7
UPclass = [6,4,2,0];
NL = 4:4:32; %3:3:18
%% ------------------------------------------------------------------------
for indE = 1:length(NL)%   �������ȼ������
%     lambdaE = E_rate(indE);   
    NLnode = NL(indE)/length(UPclass);
%   -------------���ýڵ�����ȼ�----------------------------
%     UPclass = [UPH,UPN];
%     NH = NL(indE)-NLnode;
    N_UP = NLnode*ones( 1,length(UPclass) );  %ÿһ�����ȼ��ڵ�ĸ���
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
    Pbg = zeros(1,N);
    Pgb = zeros(1,N);   %���Ϊ�����ŵ��������ŵ��㶨ΪGOOD����
    
    %------------------��ʼ�����----------------
    E_buff = (E_th)*ones(1,N); % ��ʼ�����ڵ�����״̬Ϊ0 yf��Ϊ����������
    
     %----------------�������-----------------------------
    RAP_CHN_Sta = ones(1,N); % initial channel assumed to be GOOD. temperal variable to record every INITIAL state in a superframe
    last_TX_time = ones(1,N); 
    CSMA_Sta_Pre = zeros(1,N);   % initial CSMA state assumed to be all 0 (0:initialization;1:backoff counter;2:sending packets)
    Def_Time_Pre = (-1)*ones(1,N); % initial deferred time -1
    ReTX_time_pre = zeros(1,N);  % ��ǽڵ��ش�����
    Succ_TX_time = zeros(Tsim*TB,N);   %��¼�ɹ������ʱ��
    Req = zeros(1,N); %�Ƿ��ڷ����������ݰ�����ʼ��Ϊ0���������������ݰ�
    

    %--------------һ��Ҫͳ�ƵĽ��-------------------------------
    PL_RAP_sp = zeros(Tsim,N);  %������
    Colli_RAP_sp = zeros(Tsim,N);
    PS_RAP_sp = zeros(Tsim,N);   %�ɹ�����İ���           
    ELE_RAP_sp = zeros(Tsim,N);%��¼�ܺ�
    ELE_RAP_tx = zeros(Tsim,N);%��¼�����ܺ�
    Count_sp = zeros(Tsim,N);  %������
    %*******************************%
    %����״̬���Բ�����
    %*******************************%
%     B_of_sp = zeros(Tsim,N);%��¼���������
%     B_sp = zeros(Tsim,N);
%     EH_of_sp = zeros(Tsim,N);%��¼���������
    EH_sp = zeros(Tsim,N);
%     %��ʷ״̬��¼
% %     hist_Act = zeros(Tsim,N);
%yf     hist_E = zeros(Tsim,N);
%     hist_B = zeros(Tsim,N);
%     actTime_sp = zeros(Tsim,1); %*******************************%
    
    Swait = waitbar(0,'�������');   %���ý�����
    last_TX_time_RAP = ones(1,N);
    
    for j = 1: Tsim
        %--------------------RAP�׶�ʹ��ʱ϶CSMA/CAʱ϶���䷽ʽ,���нڵ��������׶�------
        last_TX_time_RAP_ini = ones(1,N);
%         tic
        %yf Act(action),ignore the act ,always RAP %TDMA_CHN_Sta,
        [ReTX_time_pre,Def_Time_Pre,CSMA_Sta_Pre,PL_RAP,PS_RAP,Colli_RAP,ELE_RAP,Succ_TX_time_RAP,E_buff,Count,ELE_tx] = slotCSMACA_unsat_new00(len_RAP,CSMA_Sta_Pre,Def_Time_Pre,RAP_CHN_Sta,ReTX_time_pre,CW,last_TX_time_RAP_ini,E_buff);%ELE_RAP,���������ģ�,E_buff,E_flow�������������һ�¸� CW����ȫ�ִ���ȥ
%         toc
        
        PL_RAP_sp(j,:) = PL_RAP;
        PS_RAP_sp(j,:) = PS_RAP;
        Colli_RAP_sp(j,:) = Colli_RAP;
        ELE_RAP_sp(j,:) = ELE_RAP;
        ELE_RAP_tx(j,:) = ELE_tx;
        Count_sp(j,:) = Count;
        for n=1:N
            %�������һ�γɹ�������ʱ��
            if( ~isempty(Succ_TX_time_RAP{n}) )
                %���³ɹ�����ʱ���¼
                ind_TX_RAP = Succ_TX_time_RAP{n} + (j-1)*TB;  %racover the real index
                last_TX_time(n) =  ind_TX_RAP(end);
                Succ_TX_time(ind_TX_RAP,n) = 1;
                last_TX_time_RAP(n) = last_TX_time(n)-(j-1)*TB;
            end  
        end
        
        %**************************************************************%
        %   ���ڳ�֡��������������ÿ����֡��ʱ϶��������
        %   yf
        %**************************************************************%
           %-------------������ͨ�ڵ������buffer------------------
%         [E_overflow,B_overflow,E_flow,b_flow,E_buff,B_buff] = buff_update(TB,E_buff,B_buff);
%         B_of_sp(j,:) = B_overflow;
%         B_sp(j,:) = b_flow;  
%         EH_of_sp(j,:) = E_overflow;
%        EH_sp(j,:) = E_flow;  %yf һ������ģ���e_flow��E_buff�ŵ�slotCSMACA_unsat_new ���ȴ�Tsim�����rap_length
% yf        hist_E(j,:) = E_buff;
%         hist_B(j,:) = B_buff;
        
        %--------------������ʾ-------------------------------
         str = ['�������', num2str(j*100/Tsim), '%'];     
         waitbar(j/Tsim,Swait,str);
    end
    close(Swait);

        %--------------yf���ŵ�������-------------------------------

    for n=1:N
        ind_Intv = find(Succ_TX_time(:,n)==1);
        Intv(n) = mean( diff(ind_Intv) );
        Slot_ulti(n) = length(ind_Intv)*100/length(Succ_TX_time(:,n));  %�ŵ�������
    end
    
    %-------------ͳ��ͨ�Ų�����Ҫ�Ľ��-------------------------------
    
    for up=1:length(UPclass)
        indUP = find(UPnode==UPclass(up));
        EH_total(up,indE) = mean( sum( EH_sp(:,indUP) ) );  %�ܲɼ���������
%         EH_of_t(up,indE) = mean( sum( EH_of_sp(:,indUP) ) );
        
        ELE_RAP_t(up,indE) = mean( sum( ELE_RAP_sp(:,indUP) ) );
        ELE_RAP_tx_total(up,indE) = mean( sum( ELE_RAP_tx(:,indUP) ) );
        PS_RAP_total(up,indE) = mean( sum( PS_RAP_sp(:,indUP) ) );      %�ܵ�RAP�׶η��͵ĳ�֡����ȡ���нڵ��ƽ����   
        PL_RAP_total(up,indE) = mean( sum( PL_RAP_sp(:,indUP) ) );      %�ܵ�RAP�׶η��͵ĳ�֡����ȡ���нڵ��ƽ����   
        Count_total(up,indE) = mean( sum( Count_sp(:,indUP) ) ); 
        
        Colli_t(up,indE) = mean( sum( Colli_RAP_sp(:,indUP) ) );  %�ܳ�ͻ����ȡ���нڵ��ƽ����                
        Interval_avg(up,indE) = mean( Intv(indUP) );  %ƽ���ɹ�������� ,ȥ���ڵ��ƽ����
        Ulit_rate(up,indE) = mean( Slot_ulti(indUP) ); %ƽ���ŵ�������
%         Pktloss = PL_t./(PL_t+PS_t);
        Pktloss_rate(up,indE) = mean( sum( PL_RAP_sp(:,indUP) )./sum( PS_RAP_sp(:,indUP) ) ) ;   %������ͬһ���ȼ��Ľڵ��ƽ�������ʱ�������        
                                                           
    end
%       %-----------------ͳ������WBAN�Ľ��---------------------------   

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
save('VarN_MAC(UP0-2-4-6,NH1-1-8)(P1_x0.6)(N4-4-32)(E_th50)(E_cca5).mat');