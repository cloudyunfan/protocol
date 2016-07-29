function [E_overflow,B_overflow,e_flow,b_flow,E_nodebuf,B_nodebuf] = buff_update(timeIntv,E_nodebuf,B_nodebuf)
%----------update energy buffer and packet buffer using poisson
%distribution------------------------------------             
% Input:
%     timeIntv: time interval for updating
%     E_nodebuf: energy buff
%     B_nodebuf:packet buff
%     Num_node: number of nodes
% Output:
%     E_overflow: energy overflow because E_nodebuf is full
%     B_overflow: Packets overflow because E_nodebuf is full    
%     e_flow:energy flow
%     b_flow: packet flow
%     E_nodebuf : energy buff
%     B_nodebuf: packet buff
%% global variabal
global Emax Bmax lambdaE lambdaB
Num_node = length(E_nodebuf);
%% energy and data flow
e_flow = poissrnd(lambdaE*timeIntv,1,Num_node);         %һ����֡�е�������������Ӳ��ɷֲ�
b_flow = poissrnd(lambdaB*timeIntv,1,Num_node);         %һ����֡�е�������ݰ������Ӳ��ɷֲ�            

%% comput overflow
for n=1:Num_node
  %ͳ�ư��������������
 E_overflow(n) = max( 0,E_nodebuf(n)+e_flow(n)-(Emax-1) );
 B_overflow(n) = max( 0,B_nodebuf(n)+b_flow(n)-(Bmax-1) );  
 %���ĵ�غͻ�����ֵ
 E_nodebuf(n) =  min( E_nodebuf(n) + e_flow(n),(Emax-1) );   
 B_nodebuf(n) =  min( B_nodebuf(n) + b_flow(n),(Bmax-1) );  
end
end %end function