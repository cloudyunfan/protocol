function [e_flow,E_nodebuf] = buff_update_new(E_nodebuf)
%----------update energy buffer and packet buffer using bernoulli distribution------------------------------------             
% Input:
%     P1_x: probability of arrive one unit energy in each slot
%     e_flow:last energy flow 
%     E_nodebuf: energy buff
% Output:
%     e_flow:energy flo
%     E_nodebuf: energy buff

%% global variabal
global P1_x
Num_node = length(E_nodebuf);
%% energy and data flow
e_flow = randsrc(1,Num_node,[1 0;P1_x 1-P1_x]);         %һ����֡�е�������������Ӳ�Ŭ���ֲ�

%% comput overflow
for n=1:Num_node
 %���ĵ�غͻ�����ֵ
 E_nodebuf(n) =  E_nodebuf(n) + e_flow(n);   
end
end %end function