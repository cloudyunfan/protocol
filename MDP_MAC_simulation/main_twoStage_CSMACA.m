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

global N Tslot Data_rate TB Pbg Pgb CW CWmin CWmax UP UPnode Pkt_len Emax E_TX E_CCA

%------------802.15.6��ص�ȫ�ֲ���---------
UP = 0:7;  %8�����ȼ�
CWmin = [16,16,8,8,4,4,2,1];
CWmax = [64,32,32,16,16,8,8,4];

%----------------------���ò���-----------------------------------------------------
Tsim = 200; %NO. of superframes simulated
Tslot = 10;  % slot length (ms)
Pkt_len = 512; %packet length, unit is bit
Data_rate = 51.2; % transmission rate (kilo bits per second)
Emax = 50;%
E_CCA = 0.025;   %�ŵ�������ĵ�����,���͡����ܡ���������10:5��3
E_TX = 1;       %�������ݰ���Ҫ������
lambdaE = 0.05;   %����ÿʱ϶������

TB = 200; %len_TDMA + len_RAP
act = 1;
N_hup = 4;   %�̶��ĸ����ȼ��ڵ���
T_block = 16;  %MAP��ÿһ�����ʱ϶��
len_RAP = TB; %RAP�׶ι̶�de ʱ϶
UP_high = 0;
UP_low = 0;
% N = 10;
%--------------------------------------------------------------------------
indE = 0;
NumUP = 6;
for NumUP = 0:2:12%   �������ȼ������
    indE = indE + 1;
%   -------------���ýڵ�����ȼ�----------------------------
    UPclass= [UP_high,UP_low];%ʹ�û�ϵ����ȼ����ã�WBAN�����ȼ�����     
    N_lup = NumUP;  %�仯����ͨ���ȼ��ڵ���
    UPnode = [ UPclass(1)*ones(1,N_hup) UPclass(2)*ones(1,N_lup) ]; %��¼ÿ���ڵ�����ȼ�
    N = length(UPnode);    %WBAN���ܵĽڵ���
    %��ʼ����������
    for n=1:N
        CW(n) = CWmin(find(UP==UPnode(n)));  %��ʼ��CWΪ�ڵ��Ӧ���ȼ���CWmin
    end

    %-----�ŵ�ģ��ʹ�������Ʒ������ŵ�״̬��ģ�������ŵ�״̬ת�Ƹ���---------
    % Vc = unifrnd(0.1,0.5,1,N);
    % Sc = unifrnd(0.91,0.99,1,N);
    % Pbg = Sc.*Vc;  %using Markov Chain to model channel,
    % Pgb = Vc-Pbg;  %Pbg is the probability of channel changing from bad to good, Pgb is oppsite
    Pbg = zeros(1,N);
    Pgb = zeros(1,N);   %���Ϊ�����ŵ��������ŵ��㶨ΪGOOD����
    
    %------------------��ʼ����غ����ݻ�����----------------
    E_buff = (0)*ones(1,N); % ��ʼ�����ڵ�����״̬Ϊ��Emax-1
    
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
    Colli_RAP_sp = zeros(Tsim,N);
    PS_RAP_sp = zeros(Tsim,N);   %�ɹ�����İ���           
    ELE_RAP_sp = zeros(Tsim,N);%��¼�ܺ�
    ELE_of_sp = zeros(Tsim,N);%��¼���������
    EH_sp = zeros(Tsim,N);
    hist_E = zeros(Tsim,N);
    
    Swait = waitbar(0,'�������');   %���ý�����
    for j = 1: Tsim
        %--------------------RAP�׶�ʹ��ʱ϶CSMA/CAʱ϶���䷽ʽ,���нڵ��������׶�------
        last_TX_time_RAP = last_TX_time-(j-1)*TB;
%         tic
        [ReTX_time_pre,Def_Time_Pre,CSMA_Sta_Pre,TDMA_CHN_Sta,PL_RAP,PS_RAP,Colli_RAP,ELE_RAP,Succ_TX_time_RAP,E_overflow_RAP,EH_RAP,E_buff] = slotCSMACA_nouniform(len_RAP,CSMA_Sta_Pre,Def_Time_Pre,RAP_CHN_Sta,ReTX_time_pre,CW,last_TX_time_RAP,lambdaE,E_buff);
%         toc
        
        PL_RAP_sp(j,:) = PL_RAP_sp(j,:) + PL_RAP;
        PS_RAP_sp(j,:) = PS_RAP_sp(j,:) + PS_RAP;
        Colli_RAP_sp(j,:) = Colli_RAP_sp(j,:) + Colli_RAP;
        ELE_RAP_sp(j,:) = ELE_RAP_sp(j,:) + ELE_RAP;  %���ĵ���������
        ELE_of_sp(j,:) = ELE_of_sp(j,:) + E_overflow_RAP;
        EH_sp(j,:) = EH_sp(j,:) + EH_RAP;
        for n=1:N
            %�������һ�γɹ�������ʱ��
            if( ~isempty(Succ_TX_time_RAP{n}) )
                %���³ɹ�����ʱ���¼
                ind_TX_RAP = Succ_TX_time_RAP{n} + (j-1)*TB;  %racover the real index
                last_TX_time(n) =  ind_TX_RAP(end);
                Succ_TX_time(ind_TX_RAP,n) = 1;
            end  
        end         
        %--------------������ʾ-------------------------------
         str = ['�������', num2str(j*100/Tsim), '%'];     
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
        Slot_ulti(n) = length(ind_Intv)*100/length(Succ_TX_time(:,n));  %�ŵ�������
    end
    
    %-------------ͳ��ͨ�Ų�����Ҫ�Ľ��-------------------------------
    for up=1:length(UPclass)
        indUP = find(UPnode==UPclass(up));
        
        Sk(up,indE) = mean( mean( PS_RAP_sp(:,indUP) )/len_RAP );   %����������λʱ϶�ܷ��İ���
        Ek(up,indE) =  mean( mean( EH_sp(:,indUP) )/len_RAP );  %�ܺģ���λʱ϶���ܺ�
        
        ELE_RAP_t(up,indE) = mean( sum( ELE_RAP_sp(:,indUP) ) );
        EH_total(up,indE) = mean( sum( EH_sp(:,indUP) ) );  %�ܲɼ���������
        ELE_overflow_t(up,indE) = mean( sum( ELE_of_sp(:,indUP) ) );

        PS(up,indE) = mean( PS_t(:,indUP) );      %�ܵ�RAP�׶η��͵ĳ�֡����ȡ���нڵ��ƽ����   
        Colli_t(up,indE) = mean( sum( Colli_RAP_sp(:,indUP) ) );  %�ܳ�ͻ����ȡ���нڵ��ƽ����         
       
        Interval_avg(up,indE) = mean( Intv(indUP) );  %ƽ���ɹ�������� ,ȥ���ڵ��ƽ����
        Ulit_rate(up,indE) = mean( Slot_ulti(indUP) ); %ƽ���ŵ�������
        Pktloss = PL_t./(PL_t+PS_t);
        Pktloss_rate(up,indE) = mean( Pktloss(indUP) );   %������ͬһ���ȼ��Ľڵ��ƽ�������ʱ�������                      
    end
    disp(['indE NumUP lambdaE: ',num2str([indE NumUP lambdaE])]) ;
end
disp('unsaturation VaringN simulation done!')

save('twoStage_CSMACA_VaringN(UPH0-UPL0,NH4-E0.05)(NL0-2-12).mat');
%% ----------------------
% save('staticpara_CSMACA_VaringE(UPH3-UPL0,NH1-NL6)(E0.04-0.02-0.24).mat',
% 'Sk','Ek');