clear all;
clc

lambdaB=0.05;
M=7;
Tblock=10;
TB=200;
N_UP = [3,3,3,1];  %每一种优先级节点的个数
UPclass = [0,2,4,6];%0,,6,7
UPnode = [];
for up=1:length(UPclass)
   node = UPclass(up)*ones(1,N_UP(up)); 
   UPnode = [UPnode node];
end
N = sum(N_UP);
for e=19
B=19*ones(1,N);
E=e*ones(1,N);
tic
[A,R] = subopt_MDPreslv(lambdaB,B,E,M,Tblock,TB,UPnode,UPclass);
toc
Act(e+1,:) = A;
end