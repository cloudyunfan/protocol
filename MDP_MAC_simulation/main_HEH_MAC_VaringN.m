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
    %-----�ŵ�ģ��ʹ�������Ʒ������ŵ�״̬��ģ�������ŵ�״̬ת�Ƹ���---------
    % Vc = unifrnd(0.1,0.5,1,N);
    % Sc = unifrnd(0.91,0.99,1,N);
    % Pbg = Sc.*Vc;  %using Markov Chain to model channel,
    % Pgb = Vc-Pbg;  %Pbg is the probability of channel changing from bad to good, Pgb is oppsite
    Pbg = zeros(1,N);
    Pgb = zeros(1,N);   %���Ϊ�����ŵ��������ŵ��㶨ΪGOOD����
    
    %------------------��ʼ����غ����ݻ�����----------------
    E_buff = (0)*ones(1,N); % ��ʼ�����ڵ�����״̬Ϊ0
    B_buff = zeros(1,N);
    
    T1 = zeros(1,NH);
    T2 = zeros(1,NH);
    %--------------һ��Ҫͳ�ƵĽ��-------------------------------  
    PS_H = zeros(1,NH);   %�ɹ�����İ���           
    ELE_H = zeros(1,NH);%��¼�ܺ�
    Colli_L = zeros(1,NL);
    PS_L = zeros(1,NL);   %�ɹ�����İ���           
    ELE_L = zeros(1,NL);%��¼�ܺ�
    
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
        
        for n_cur=1:NH
            n_pre = n_cur - 1;
            if(n_pre==0)
                n_pre = NH;  %circle
            end
           T1(n_cur) = T2(n_pre) + max( ceil( max( (block*E_TX-E_buff(n_cur)),0 )/lambdaE ),ceil( max( (block-B_buff(n_cur)),0 )/lambdaB ) );
           T2(n_cur) = T1(n_cur) + block;
           if( T1(n_cur)> T)  
               disp('done!cause T1 out');
               flag=1;
           end
           %--------------------------------------------------------
           %�Ƿ�PC polling
           L_idle = T1(n_cur)-T2(n_pre);
           if(L_idle>=Tpcmin ) 
              [PS_PC,Colli_PC,ELE_PC,E_buff(indL),B_buff(indL)] = PC_poll(L_idle,E_buff(indL),B_buff(indL),indL); 
               ELE_L = ELE_L + ELE_PC;
                PS_L = PS_L + PS_PC;
                Colli_L = Colli_L + Colli_PC;    
           end
           %����һ�����и����ȼ��ڵ��buffer           
           [E_overflow,B_overflow,e_flow,b_flow,E_buff(indH),B_buff(indH)] = buff_update_HEHMAC(L_idle,E_buff(indH),B_buff(indH),lambdaE,lambdaB,Emax,Bmax);
            B_of(indH) = B_of(indH) + B_overflow;
            B(indH) = B(indH) + b_flow;  
            EH_of(indH) = EH_of(indH) + E_overflow;
            EH(indH) = EH(indH) + e_flow; 
            
            t = T1(n_cur);%Ų��ʱ���±�
            if( T2(n_cur)> T)  
                disp('done!cause T2 out');
               flag = 1;
           end
%             hist_E(j,:) = E_buff;
%             hist_B(j,:) = B_buff;
            %------------------------------------
           %ID_polling
           if(E_buff(n_cur)>=block*E_TX&&B_buff(n_cur)>=block)
              Succ_TX_time(T1(n_cur):T2(n_cur),n_cur) = 1;
               PS_H(n_cur) = PS_H(n_cur) + block;
               ELE_H(n_cur) = ELE_H(n_cur) + block*E_TX;
               B_buff(n_cur) = B_buff(n_cur) - block;
               E_buff(n_cur) = E_buff(n_cur) - block*E_TX;
               %���������ڵ��buffer
               for n1 = 1:N
                  if(n1~=n_cur) 
                        [E_overflow,B_overflow,e_flow,b_flow,E_buff(n1),B_buff(n1)] = buff_update_HEHMAC(block,E_buff(n1),B_buff(n1),lambdaE,lambdaB,Emax,Bmax);
                        B_of(n1) = B_of(n1) + B_overflow;
                        B(n1) = B(n1) + b_flow;  
                        EH_of(n1) = EH_of(n1) + E_overflow;
                        EH(n1) = EH(n1) + e_flow; 
                  end
               end
           else
               %PC polling
               len_PC = block;
               [PS_PC,Colli_PC,ELE_PC,E_buff(indL),B_buff(indL)] = PC_poll(len_PC,E_buff(indL),B_buff(indL),indL); 
               ELE_L = ELE_L + ELE_PC;
                PS_L = PS_L + PS_PC;
                Colli_L = Colli_L + Colli_PC; 
                %�������и����ȼ��ڵ��buffer
                [E_overflow,B_overflow,e_flow,b_flow,E_buff(indH),B_buff(indH)] = buff_update_HEHMAC(len_PC,E_buff(indH),B_buff(indH),lambdaE,lambdaB,Emax,Bmax);
                B_of(indH) = B_of(indH) + B_overflow;
                B(indH) = B(indH) + b_flow;  
                EH_of(indH) = EH_of(indH) + E_overflow;
                EH(indH) = EH(indH) + e_flow; 
           end
            t = T2(n_cur);%Ų��ʱ���±�
            if(flag==1)
                break;
            end
        end  
         if(flag==1)
                break;
        end
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
disp('unsaturation VaringE simulation done!')
save('HEHMAC_VarE(UP0-6,NH4-NL6)(Em20-Bm20,B0.05)(E0.02-0.01-0.08).mat');