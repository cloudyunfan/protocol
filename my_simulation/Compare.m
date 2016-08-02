
clc;
clear all;
load('tau_DTMC25.mat');
load('tau_Real25.mat');
tau_D25 = tau_DTMC;
tau_R25 = tau_Real;
load('tau_DTMC50.mat');
load('tau_Real50.mat');
tau_D50 = tau_DTMC;
tau_R50 = tau_Real;
load('tau_DTMC100.mat');
load('tau_Real100.mat');
tau_D100 = tau_DTMC;
tau_R100 = tau_Real;
load('tau_DTMC1000.mat');
load('tau_Real1000.mat');
tau_D1000 = tau_DTMC;
tau_R1000 = tau_Real;
N_all = 4:4:32; %2:2:18

figure(1);
 plot(N_all,tau_R1000(1,:),'^b','markerfacecolor','b');
hold on;
plot(N_all,tau_R1000(2,:),'or','markerfacecolor','r');
hold on;
plot(N_all,tau_R1000(3,:),'dg','markerfacecolor','g');
hold on;
plot(N_all,tau_R1000(4,:),'vk','markerfacecolor','k');
hold on;
plot(N_all,tau_D1000(1,:),'-b',N_all,tau_D1000(2,:),'-r',N_all,tau_D1000(3,:),'-g',N_all,tau_D1000(4,:),'-k');

% plot(N_all,tau_Real(1,:),'-b',N_all,tau_Real(2,:),'-r',N_all,tau_DTMC(1,:),'-^b',N_all,tau_DTMC(2,:),'-or');
axis([4,33,0.00005,0.0004]);
% legend('UP6','UP0');
legend('UP6,Real,N=1000','UP4,Real,N=1000','UP2,Real,N=1000','UP0,Real,N=1000','UP6,Anal,N=1000','UP4,Anal,N=1000','UP2,Anal,N=1000','UP0,Anal,N=1000');
grid;
title('Packet transmission probability of UPs in a slot');
xlabel('n(Number of nodes in WBAN)');
ylabel('Tau(k)');

figure(2);
plot(N_all,tau_R25(1,:),'^b','markerfacecolor','b');
hold on;
plot(N_all,tau_R25(2,:),'or','markerfacecolor','r');
hold on;
% plot(N_all,tau_R25(3,:),'dg','markerfacecolor','g');
% hold on;
% plot(N_all,tau_R25(4,:),'vk','markerfacecolor','k');
hold on;
plot(N_all,tau_D25(1,:),'-b',N_all,tau_D25(2,:),'-r');
hold on;
plot(N_all,tau_R50(1,:),'^b');
hold on;
plot(N_all,tau_R50(2,:),'or');
hold on;
% plot(N_all,tau_R50(3,:),'dg');
% hold on;
% plot(N_all,tau_R50(4,:),'vk');
% hold on;
plot(N_all,tau_D50(1,:),'--b',N_all,tau_D50(2,:),'--r');
axis([4,33,0.004,0.018]);
legend('UP6,Real,N=25','UP4,Real,N=25','UP6,Anal,N=25','UP4,Anal,N=25','UP6,Real,N=50','UP4,Real,N=50','UP6,Anal,N=50','UP4,Anal,N=50');
grid;
title('Packet transmission probability comparison of UPs in a slot');
xlabel('n(Number of nodes in WBAN)');
ylabel('Tau(k)')
