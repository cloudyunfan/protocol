function [ pl,ps,outcome,CHN_sta_f,Succ_TX_ind,E_ex] = pktsendTDMA_sat( CHNbefore_leng,CHNafter_leng,CHN_sta_ini,slotNO,Pu,Pd)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Input:
%   1.CHNbefore_leng : the former slots length.
%   2.CHNafter_leng : the latter slots length.
%   3.slotNO : NO. of allocated slots of the node.
%   4.CHN_sta_ini : temperal variable to record every INITIAL state in a superframe
%   5.Pu : the  transition probability from the bad state to the good state.(up:0->1)
%   6.Pd : the  transition probability from the good state to the bad  state.(down:1->0)
%Output:
%   1.CHN_sta_f : the  INITIAL state  after the pktsend.
%   2.ps : the NO. of successful packets
%   3.pl : the NO. of lossed packets.
%   4.outcome :  last slot state of current node
%   5.CHN_sta_f : the last state after the superframe.
%   6.E_ex: energy exhost totaly
%   7.Succ_TX_ind�� record the time when node send pkt successfully after thie superframe

%*******��pktsend�������Ƕ෵��һ��ƽ���ɹ��������Interval_avg***********
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global  E_TX 
%--------------------initialize parameter--------------------------------
ps = 0;
pl = 0;
E_ex = 0;
Succ_TX_ind = [];
CHN_sta = CHN_sta_ini; % CHN_sta is a temperal variable updating every loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% channel state is updating
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the channel state before current transmission��ʹ������Ʒ��������㵱ǰ�ŵ�״̬

for c = 1:CHNbefore_leng 
        if CHN_sta == 1
            CHN_sta = randsrc(1,1,[0 1;Pd 1-Pd]); %%%%%% channel model
        else
            CHN_sta = randsrc(1,1,[0 1;1-Pu Pu]); %%%%%% using Markov chain
        end
end
% transmitting  slotNO packets
for d = 1:slotNO  % each node i transmit slotNO slots
        if CHN_sta == 1
            CHN_sta = randsrc(1,1,[0 1;Pd 1-Pd]); %%%%%% channel model
        else
            CHN_sta = randsrc(1,1,[0 1;1-Pu Pu]); %%%%%% using Markov chain
        end
        if ( CHN_sta==0 )
            pl = pl+1; %%%%% calculate the NO. of lossed packets
        else            
            ps = ps+1; %%%%% calculate the NO. of successful packets              
            E_ex = E_ex + E_TX;     %��¼���ĵ������ܺ�                
            Succ_TX_ind = [Succ_TX_ind d];  %�Գɹ�������ʱ϶���б�� 
        end
end
% outcome of last slot of current node,��¼���Ͱ�ʱ���ŵ�״̬��0�����ã�1���ã�
outcome = CHN_sta;
% update the channel state after transmission
for e = 1:CHNafter_leng 
        if CHN_sta == 1
            CHN_sta = randsrc(1,1,[0 1;Pd 1-Pd]); %%%%%% channel model
        else
            CHN_sta = randsrc(1,1,[0 1;1-Pu Pu]); %%%%%% using Markov chain
        end
end
% the final channel state of current node
CHN_sta_f = CHN_sta;
end
