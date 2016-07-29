function T = Cal_tau2(X)
%这是用于求解tau的方程组，tau是DTMC-CSMACA模型中节点每个时隙发送包的概率
% Input:
%     X = [tau;pai];
%     tau: 信道接入概率。a vector with dimention K*1; K is the number of priority
%     pai: 队列为空的概率。a vector with dimention K*1; K is the number of priority
% Output:
%     T: 所得的K个方程组；
global CWmin CWmax R Ls RAP N
%------------未知数预处理----------------------------------------
K = length(X);
tau = X(1:K);

%--------------------已知的参数-----------------------------------
% CWmin = [16 16 8 8 4 4 2 1];
% CWmax = [64 32 32 16 16 8 4];
CW = CW_backoffstage(CWmin,CWmax,R,K);  %生成每一次重传的窗口，CW是一个(R+1,K)矩阵
%--------------获得从冲突概率、信道空闲概率----------------------------
fk = zeros(K,1);   %信道空闲概率
p = (1/(RAP-Ls))*ones(K,1);    %剩余时隙足够用于发送包的概率，我们简单假设为1
f = 1;
for k=1:K
    f = f*( (1-tau(k))^(N(k)) ); %信道空闲概率
end
for k=1:K
    fk(k) = f/(1-tau(k)); %退避时信道空闲概率   
    Y(k) = ( fk(k)*tau(k) )/( 1-( 1-fk(k) )^(R+1) );
end
%--------------通过DTMC模型获得关于信道接入概率的K个方程------------

for k=1:K
    temp2 = 0;
    for i=1:R+1  %相当于i=0:R
        temp3 = 0;
        for j=1:CW(i,k)
           gk = fk(k)*( 1-p(k)*( 1-fk(k)^(j) )/( 1-fk(k) ) );
           temp3 = temp3 + (CW(i,k)-j+1)/gk; 
        end
        temp2 = temp2 + ( (1-fk(k))^(i) )*( 1+(1/CW(i,k))*temp3 );
    end
    T(k,:) = Y(k)*temp2 - 1;
end

end