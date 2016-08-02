function [ Th_Real ] = CalTh_Real( ~ )
% 计算CSMACA实际上的吞吐量的值, 
% a fraction of time of the channel used to successfully 
% transmit the packet, multiplied with packet size
%   此处显示详细说明
global Pkt_len TB Tsim NL % 512 packet length, unit is bit
load('VarN_MAC(UP0-6,NH1-1-9)(P1_x0.9)(NL1-1-9)EkeyBC0sift0.mat');
% load('VarN_MAC(UP0-6,NH1-1-9)(P1_x0.9)(NL1-1-9).mat');
Th_Real = PS_RAP_total*Pkt_len/(TB*Tsim);
% [inUP,inN] = size(Th_Real);
% for i = 1:inUP
% plot(Th_Real(i,:),'-r');
% hold on;
% end;
plot(NL,Th_Real(1,:),'-o',NL,Th_Real(2,:),'-^',NL,Th_Real(3,:),'-*',NL,Th_Real(4,:),'-v');
legend('UP6','UP0');
grid;
end

