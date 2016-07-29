function [E_overflow,e_flow,E_nodebuf] = E_update(timeIntv,E_nodebuf,Num_node,Emax,lambdaE)
%----------update energy buffer and packet buffer using poisson
%distribution------------------------------------             
% Input:
%     timeIntv: time interval for updating
%     E_nodebuf: energy buff
%     Num_node: number of nodes
%     Emax: maximun of energy buffer
%     lambdaE: energy harvesting speed
% Output:
%     E_overflow: energy overflow because E_nodebuf is full
%     e_flow:energy flow
%     E_nodebuf : energy buff
%% energy flow
e_flow = poissrnd(lambdaE*timeIntv,1,Num_node);         %一个超帧中到达的能量数服从泊松分布

%% comput overflow
for n=1:Num_node
  %统计包和能力的溢出量
 E_overflow(n) = max( 0,E_nodebuf(n)+e_flow(n)-(Emax-1) );
 %更改电池和缓存区值
 E_nodebuf(n) =  min( E_nodebuf(n) + e_flow(n),(Emax-1) );    
end
end %end function