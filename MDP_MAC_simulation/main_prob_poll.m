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

global E_TX E_CCA t Succ_TX_time Emax Bmax lambdaE lambdaB B_of EH_of B EH%CWmin CWmax UP UPnode 
%% ����MDP���
%------------802.15.6��ص�ȫ�ֲ���---------
UP = 0:7;  %8�����ȼ�
CWmin = [16,16,8,8,4,4,2,1];
CWmax = [64,32,32,16,16,8,8,4];

%----------------------���ò���---------------
Tslot = 10;  % slot length (ms)
Pkt_len = 512; %packet length, unit is bit
Data_rate = 51.2; % transmission rate (kilo bits per second)
Emax = 20;%
Bmax = 20;%
%
lambdaB = 0.05;
block = 1;
E_CCA = 0.025;   %�ŵ�������ĵ�����,���͡����ܡ���������10:5��3
E_TX = 1;       %�������ݰ���Ҫ������
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
for indE = 1:length(E_rate)%   �������ȼ������
%     NL = NLnode(indE);
%     lambdaE = 0.05;
    NL = 6;
    lambdaE = E_rate(indE);
    
    UPclass = [UPH,UPL];%0,,6,7    
    N_UP = [NH,NL];  %ÿһ�����ȼ��ڵ�ĸ���
    UPnode = [];
    for up=1:length(UPclass)
       node = UPclass(up)*ones(1,N_UP(up)); 
       UPnode = [UPnode node];
    end
    indL = find( UPnode==UPclass(find(UPclass==UPL)) );
    indH = find( UPnode==UPclass(find(UPclass==UPH)) );
    N = length(UPnode);
    T_intv = max(1/lambdaE,1/lambdaB);
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
    
    %--------------һ��Ҫͳ�ƵĽ��-------------------------------  
    Colli = zeros(1,N);
    PS = zeros(1,N);   %�ɹ�����İ���           
    ELE = zeros(1,N);%��¼�ܺ�
    
    B_of = zeros(1,N);%��¼���������
    B = zeros(1,N);
    EH_of = zeros(1,N);%��¼���������
    EH = zeros(1,N);
    last_TX_time = ones(1,N); 
    %��ʷ״̬��¼
    hist_E = zeros(Tsim,N);
    hist_B = zeros(Tsim,N);
    
    Swait = waitbar(0,'�������');   %���ý�����
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
       
        %--------------������ʾ-------------------------------
         str = ['�������', num2str(t*100/T), '%'];     
         waitbar(t/T,Swait,str);
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
                
        EH_t(up,indE) = mean( EH(:,indUP) );  %�ܲɼ���������
        EH_of_t(up,indE) = mean( EH_of(:,indUP) );
        B_t(up,indE) = mean( B(:,indUP) );  %�ܲɼ���������
        B_of_t(up,indE) = mean( B_of(:,indUP) );
       Interval_avg(up,indE) = mean( Intv(indUP) );  %ƽ���ɹ�������� ,ȥ���ڵ��ƽ����
                
%         Ulit_rate(up,indE) = mean( Slot_ulti(indUP) ); %ƽ���ŵ�������
%         Pktloss = PL_t./(PL_t+PS_t);
%         Pktloss_rate(up,indE) = mean( sum( PL_RAP_sp(:,indUP)+PL_MAP_sp(:,indUP) )./sum( PS_RAP_sp(:,indUP)+PS_MAP_sp(:,indUP) ) );   %������ͬһ���ȼ��Ľڵ��ƽ�������ʱ�������        
                              
    end
        ELE_L_t(indE) = mean( ELE_L);
        ELE_H_t(indE) = mean( ELE_H );
        PS_L_t(indE) = mean( PS_L );      %�ܵ�RAP�׶η��͵ĳ�֡����ȡ���нڵ��ƽ����   
        PS_H_t(indE) = mean( PS_H );       
      
        Colli_t(indE) = mean(Colli_L);  %�ܳ�ͻ����ȡ���нڵ��ƽ����                        %     
    disp(['indE NumUP lambdaE: ',num2str([indE N lambdaE])]) ;
end
disp('unsaturation VaringN-E simulation done!')
save('ProbPoll_VarE(UP0-6,NH4-NL6)(Em20-Bm20,B0.05)(E0.02-0.01-0.08).mat');