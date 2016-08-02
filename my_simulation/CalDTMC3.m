function  CalDTMC3( ~ )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         Calculate the DTMC Model
%         Author:yf
%         Date:2015/12/22
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear all;
global P1_x E_th E_cca E_tx E_rx E_colli Ts Eth Etx M
E_th = 1000;
P1_x = 0.6;
Ts = 0.01;%sÿ��slot��ʱ�䳤��
Etx = 4;%nJ
Eth = Etx/E_th;
% P1_x = 0.9;
E_cca = E_th ;  %���������ĵ�����
E_tx = E_th; %�����ɹ����ĵ��������������ĵ�������
E_rx = E_th;%���ܰ����ĵ�����
E_colli = E_th;  %������ͻ���ĵ�����
N_all = 12; %2:2:18
% N_all = 2:2:18;
m1 = 1:10;
% UPH = 6;
% UPL = 0;    
class_UP = [6,4,2,0];%6,0  
% class_UP = [6,0];
Th_DTMC = zeros( length(class_UP), length(m1));
tau_DTMC = zeros( length(class_UP), length(m1));
PL_DTMC = zeros( length(class_UP), length(m1));
E_DTMC = zeros( length(class_UP), length(m1));
for indE = 1:length(m1) % �������ȼ������

%   -------------���ýڵ�����ȼ�----------------------------
    M = m1(indE);
    UPcount = length(class_UP); % count of UPs    
    NLnode = N_all/UPcount; 
%     NHnode = N_all(indE)-NLnode;
    N_UP = NLnode*ones(1,UPcount);  %ÿһ�����ȼ��ڵ�ĸ���
    [S,E,PL,~,tau]=solve_CSMACA_new(N_UP,class_UP);
    Th_DTMC(:,indE) = S;
    tau_DTMC(:,indE) = tau;
    PL_DTMC(:,indE) = PL;
    E_DTMC(:,indE) = E;
end %end for 

%   --------------plot comparision---------------------------
% load('VarN_MAC(UP0-2-4-6,NH1-1-8)(P1_x0.9)(N4-4-32)EkeyBC0addCnt.mat');
% load('VarN_MAC(UP0-2-4-6,NH1-1-8)(P1_x0.9)(N4-4-32)EkeyBC0addCnt.mat');
load('VarM_MAC(UP0-2-4-6)(M1-1-10)(N12)(E_th1000).mat');
Th_Real = PS_RAP_total*Pkt_len/(TB*Tsim*Ts);
tau_Real = (Count_total)/(TB*Tsim);
% PL_Real = PL_RAP_total/(TB*Tsim);
E_Real = ( Etx*(PS_RAP_total*(E_tx+E_rx)+Colli_t*E_colli) )/(TB*Tsim*Ts);
% E_Real = (PS_RAP_total*(E_tx+E_rx)+Colli_t*E_colli)/(TB*Tsim);
tau_Real = (PS_RAP_total+Colli_t)/(TB*Tsim);
% 
% figure(1);
% plot(Alpha,Th_Real(1,:),'^b','markerfacecolor','b');
% hold on;
% plot(Alpha,Th_Real(2,:),'or','markerfacecolor','r');
% hold on;
% plot(Alpha,Th_Real(3,:),'dg','markerfacecolor','g');
% hold on;
% plot(Alpha,Th_Real(4,:),'vk','markerfacecolor','k');
% hold on;
% plot(Alpha,Th_DTMC(1,:),'-b',Alpha,Th_DTMC(2,:),'-r',Alpha,Th_DTMC(3,:),'-g',Alpha,Th_DTMC(4,:),'-k');
% % axis([0.1,0.9,0,2600]);
% % plot(N_all,Th_Real(1,:),'-b',N_all,Th_Real(2,:),'-r',N_all,Th_DTMC(1,:),'-^b',N_all,Th_DTMC(2,:),'-or');
% % legend('UP6','UP0');
% legend('UP6,Real','UP4,Real','UP2,Real','UP0,Real','UP6,Anal','UP4,Anal','UP2,Anal','UP0,Anal');
% grid;
% title('Throughput of UPs in a slot with number of nodes=12');
% xlabel('Probability of energy arrival ');
% ylabel('Throughput(Bits/Sec)');
% % 
figure(2);
plot(m1,tau_Real(1,:),'^b','markerfacecolor','b');
hold on;
plot(m1,tau_Real(2,:),'or','markerfacecolor','r');
hold on;
plot(m1,tau_Real(3,:),'dg','markerfacecolor','g');
hold on;
plot(m1,tau_Real(4,:),'vk','markerfacecolor','k');
hold on;
plot(m1,tau_DTMC(1,:),'-b',m1,tau_DTMC(2,:),'-r',m1,tau_DTMC(3,:),'-g',m1,tau_DTMC(4,:),'-k');
% plot(N_all,tau_Real(1,:),'-b',N_all,tau_Real(2,:),'-r',N_all,tau_DTMC(1,:),'-^b',N_all,tau_DTMC(2,:),'-or');
%  axis([0.1,0.9,0,0.014]);
% legend('UP6','UP0');
legend('UP6,Real','UP4,Real','UP2,Real','UP0,Real','UP6,Anal','UP4,Anal','UP2,Anal','UP0,Anal');
grid;
title('Packet transmission probability of UPs in a slot'); %with number of nodes=12
xlabel('m(limited number of retry)');
ylabel('Tau(k)');

% figure(3);
% plot(N_all,PL_Real(1,:),'^b','markerfacecolor','b');
% hold on;
% plot(N_all,PL_Real(2,:),'or','markerfacecolor','r');
% hold on;
% plot(N_all,PL_Real(3,:),'dg','markerfacecolor','g');
% hold on;
% plot(N_all,PL_Real(4,:),'vk','markerfacecolor','k');
% hold on;
% plot(N_all,PL_DTMC(1,:),'-b',N_all,PL_DTMC(2,:),'-r',N_all,PL_DTMC(3,:),'-g',N_all,PL_DTMC(4,:),'-k');
% % axis([4,28,0,50]);
% % plot(N_all,Th_Real(1,:),'-b',N_all,Th_Real(2,:),'-r',N_all,Th_DTMC(1,:),'-^b',N_all,Th_DTMC(2,:),'-or');
% % legend('UP6','UP0');
% legend('UP6,Real','UP4,Real','UP2,Real','UP0,Real','UP6,Anal','UP4,Anal','UP2,Anal','UP0,Anal');
% grid;
% title('packet loss of UPs in a slot');
% xlabel('Number of nodes in WBAN');
% ylabel('average lost packet in a slot');

% figure(4);
% plot(Alpha,E_Real(1,:),'^b','markerfacecolor','b');
% hold on;
% plot(Alpha,E_Real(2,:),'or','markerfacecolor','r');
% hold on;
% plot(Alpha,E_Real(3,:),'dg','markerfacecolor','g');
% hold on;
% plot(Alpha,E_Real(4,:),'vk','markerfacecolor','k');
% hold on;
% plot(Alpha,E_DTMC(1,:),'-b',Alpha,E_DTMC(2,:),'-r',Alpha,E_DTMC(3,:),'-g',Alpha,E_DTMC(4,:),'-k');
% axis([0.1,0.9,0,150]);
% % plot(N_all,Th_Real(1,:),'-b',N_all,Th_Real(2,:),'-r',N_all,Th_DTMC(1,:),'-^b',N_all,Th_DTMC(2,:),'-or');
% % legend('UP6','UP0');
% legend('UP6,Real','UP4,Real','UP2,Real','UP0,Real','UP6,Anal','UP4,Anal','UP2,Anal','UP0,Anal');
% grid;
% title('Average energy consumption of UPs in a slot with number of nodes=12');
% xlabel('Probability of energy arrival');
% ylabel('Energy consumption(nJoule/Sec)');

end
 