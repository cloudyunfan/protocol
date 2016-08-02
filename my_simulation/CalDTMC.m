function  CalDTMC( ~ )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         Calculate the DTMC Model
%         Author:yf
%         Date:2015/12/22
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear all;
global P1_x E_th E_cca E_tx E_rx Ts Eth Etx M
M =4;
Pkt = 114;%bits
% Tslt = 376;%us
Ts = 376*10^(-6);%s每个slot的时间长度
P1_x = 0.6;
N_all = 4:4:32; %2:2:18
N_each = 1:1:8;
Etx = 4;%nJ
E_th = 50;
Eth = Etx/E_th;
E_cca = E_th/10 ;  %CCA 消耗的能量
E_tx = E_th; %发包成功消耗的能量（发包消耗的能量）
E_rx = E_th;%接受包消耗的能量
% E_colli = E_th;  %发包冲突消耗的能量
% N_all = 2:2:18;
% UPH = 6;
% UPL = 0;    
class_UP = [6,4,2,0]; 
% class_UP = [6,0];
Th_DTMC = zeros( length(class_UP), length(N_all));
tau_DTMC = zeros( length(class_UP), length(N_all));
PL_DTMC = zeros( length(class_UP), length(N_all));
E_DTMC = zeros( length(class_UP), length(N_all));
load('VarN_MAC(UP0-2-4-6,NH1-1-8)(P1_x0.6)(N4-4-32)(E_th50)(E_cca5).mat.mat');
tau_Real = (Count_total)/(TB*Tsim);
Pcca_Real = (P1_x/E_cca)*ones(length(class_UP),length(N_all)) - tau_Real;
E_Real = ELE_RAP_t*Etx/(1000*Tsim*TB*Ts);
for indE = 1:length(N_all) % 多种优先级情况下

%   -------------设置节点的优先级----------------------------

    UPcount = length(class_UP); % count of UPs    
    NLnode = N_all(indE)/UPcount; 
%     NHnode = N_all(indE)-NLnode;
    N_UP = NLnode*ones(1,UPcount);  %每一种优先级节点的个数
    [S,E,PL,~,tau]=solve_CSMACA_new(N_UP,class_UP);
    Th_DTMC(:,indE) = S;
    tau_DTMC(:,indE) = tau;
    PL_DTMC(:,indE) = PL;
    E_DTMC(:,indE) = E/1000;
    E_colli = zeros(1,UPcount);
% for k=1:UPcount
%     for i=2:NLnode
%         E_colli(k) = E_colli(k)+ i*(E_tx)*nchoosek(NLnode,i)*tau_Real(k)^i*(1-tau_Real(k))^(N_all(k)-i);
%     end;
%     E_Real(k,indE) = ( Etx*(PS_RAP_total(k,indE)*(E_tx)+Colli_t(k,indE)*E_colli(k)+Pcca_Real(k,indE)*E_cca ) )/(1000*TB*Tsim*Ts);
% end
end %end for 

%   --------------plot comparision---------------------------
% load('VarN_MAC(UP0-2-4-6,NH1-1-8)(P1_x0.9)(N4-4-32)EkeyBC0addCnt.mat');
% load('VarN_MAC(UP0-2-4-6,NH1-1-8)(P1_x0.9)(N4-4-32)EkeyBC0addCnt.mat');

Th_Real = PS_RAP_total*Pkt/(TB*Tsim*Ts);



% save('tau_DTMC100.mat','tau_DTMC');
% save('tau_Real100.mat','tau_Real');

% E_Real = ELE_RAP_tx_total/(TB*Tsim);
%  tau_Real = (PS_RAP_total+Colli_t)/(TB*Tsim); %前面有
% figure(1);
% plot(N_all,Th_Real(1,:),'^b','markerfacecolor','b');
% hold on;
% plot(N_all,Th_Real(2,:),'or','markerfacecolor','r');
% hold on;
% plot(N_all,Th_Real(3,:),'dg','markerfacecolor','g');
% hold on;
% plot(N_all,Th_Real(4,:),'vk','markerfacecolor','k');
% hold on;
% plot(N_all,Th_DTMC(1,:),'-b',N_all,Th_DTMC(2,:),'-r',N_all,Th_DTMC(3,:),'-g',N_all,Th_DTMC(4,:),'-k');
% axis([4,33,500,3000]);
% % plot(N_all,Th_Real(1,:),'-b',N_all,Th_Real(2,:),'-r',N_all,Th_DTMC(1,:),'-^b',N_all,Th_DTMC(2,:),'-or');
% % legend('UP6','UP0');
% legend('UP6,Sim','UP4,Sim','UP2,Sim','UP0,Sim','UP6,Anal','UP4,Anal','UP2,Anal','UP0,Anal');
% grid;
% % title('Throughput of UPs');
% xlabel('n(Number of nodes in WBAN)');
% ylabel('Throughput(Bits/Second)');
% % % 
figure(2);
plot(N_all,tau_Real(1,:),'^b','markerfacecolor','b');
hold on;
plot(N_all,tau_Real(2,:),'or','markerfacecolor','r');
hold on;
plot(N_all,tau_Real(3,:),'dg','markerfacecolor','g');
hold on;
plot(N_all,tau_Real(4,:),'vk','markerfacecolor','k');
hold on;
plot(N_all,tau_DTMC(1,:),'-b',N_all,tau_DTMC(2,:),'-r',N_all,tau_DTMC(3,:),'-g',N_all,tau_DTMC(4,:),'-k');
% plot(N_all,tau_Real(1,:),'-b',N_all,tau_Real(2,:),'-r',N_all,tau_DTMC(1,:),'-^b',N_all,tau_DTMC(2,:),'-or');
% axis([4,33,0.6*10^(-4),2.6*10^(-4)]);
%  axis([4,33,2*10^(-3),1*10^(-2)]);
% legend('UP6','UP0');
% legend('UP6,Sim,N=1000','UP4,Sim,N=1000','UP2,Sim,N=1000','UP0,Sim,N=1000','UP6,Anal,N=1000','UP4,Anal,N=1000','UP2,Anal,N=1000','UP0,Anal,N=1000');
legend('UP6,Sim','UP4,Sim','UP2,Sim','UP0,Sim','UP6,Anal','UP4,Anal','UP2,Anal','UP0,Anal');
grid;
% title('Packet transmission probability of UPs in a slot');
xlabel('n(Number of nodes in WBAN)');
ylabel('Tau(k)');

% figure(3);
% plot(N_all,E_Real(1,:),'^b','markerfacecolor','b');
% hold on;
% plot(N_all,E_Real(2,:),'or','markerfacecolor','r');
% hold on;
% plot(N_all,E_Real(3,:),'dg','markerfacecolor','g');
% hold on;
% plot(N_all,E_Real(4,:),'vk','markerfacecolor','k');
% hold on;
% % plot(N_all,E_DTMC(1,:),'-b',N_all,E_DTMC(2,:),'-r',N_all,E_DTMC(3,:),'-g',N_all,E_DTMC(4,:),'-k');
% % axis([4,33,0.8,5.1]);
% % plot(N_all,Th_Real(1,:),'-b',N_all,Th_Real(2,:),'-r',N_all,Th_DTMC(1,:),'-^b',N_all,Th_DTMC(2,:),'-or');
% % legend('UP6','UP0');
% legend('UP6,Real','UP4,Real','UP2,Real','UP0,Real','UP6,Anal','UP4,Anal','UP2,Anal','UP0,Anal');
% grid;
% title('Average power consumption of UPs');
% xlabel('n(Number of nodes in WBAN)');
% ylabel('power consumption (uJoule/Second)');
% for ii = 1:8
%     E_DTMC_total(:,ii) = E_DTMC(:,ii)*ii/10;
%     E_Real_total(:,ii) = E_Real(:,ii)*ii/10;
% end;
% figure(4);
% plot(N_all,E_Real_total(1,:)*10^(-3),'^b','markerfacecolor','b');
% hold on;
% plot(N_all,E_Real_total(2,:)*10^(-3),'or','markerfacecolor','r');
% hold on;
% plot(N_all,E_Real_total(3,:)*10^(-3),'dg','markerfacecolor','g');
% hold on;
% plot(N_all,E_Real_total(4,:)*10^(-3),'vk','markerfacecolor','k');
% hold on;
% plot(N_all,E_DTMC_total(1,:)*10^(-3),'-b',N_all,E_DTMC_total(2,:)*10^(-3),'-r',N_all,E_DTMC_total(3,:)*10^(-3),'-g',N_all,E_DTMC_total(4,:)*10^(-3),'-k');
% % axis([4,32,0,4.8]);
% % plot(N_all,Th_Real(1,:),'-b',N_all,Th_Real(2,:),'-r',N_all,Th_DTMC(1,:),'-^b',N_all,Th_DTMC(2,:),'-or');
% % legend('UP6','UP0');
% legend('UP6,Sim','UP4,Sim','UP2,Sim','UP0,Sim','UP6,Anal','UP4,Anal','UP2,Anal','UP0,Anal');
% grid;
% % title('Average power consumption of UPs');
% xlabel('n(Number of nodes in WBAN)');
% ylabel('power consumption (mJoule/Second)');

end
 