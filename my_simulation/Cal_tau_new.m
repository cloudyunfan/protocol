function T = Cal_tau_new(X)
%这是用于求解tau的方程组，tau是DTMC-CSMACA模型中节点每个时隙发送包的概率
% Input:
%     X = [tau;pai];
%     tau: 信道接入概率。a vector with dimention K*1; K is the number of priority
% Output:
%     T: 所得的K个方程组；
global ICWmin ICWmax NI P1_x E_tx E_cca
%------------未知数预处理----------------------------------------
K = length(X);
tau = X(1:K);

%--------------------已知的参数-----------------------------------
R  = 4;  %最大重传次数
CW = CW_backoffstage(ICWmin,ICWmax,R,K);  %生成每一次重传的窗口，CW是一个(R+1,K)矩阵
%--------------获得从冲突概率、信道空闲概率----------------------------
p = zeros(K,1);   %冲突概率
q = zeros(K,1);   %信道空闲概率
f = ones(K,1);    %剩余时隙足够用于发送包的概率，我们简单假设为1
for k=1:K
    temp = 1;
    for k1=1:K
        if(k1~=k)
            temp = temp*( (1-tau(k1))^NI(k1) );
        end
    end
   p(k) = 1 - (1-tau(k))^(NI(k)-1)*temp; %*tau(k)
   q(k) = (1-tau(k))^(NI(k)-1)*temp;
end
%--------------通过DTMC子模型获得关于信道接入概率的K个方程------------
theta = zeros(K,1);
alpha = zeros(K,1);
tmp = zeros(K,1);
for k=1:K
   theta(k) = sum( (p(k).^(0:R)').*(CW(:,k)-1)/2 );
   alpha(k) = sum( (p(k).^(0:R)') );
   A = q(k)*f(k)*P1_x*alpha(k);
   B = E_tx*q(k)*f(k)*alpha(k)+E_cca*alpha(k)+E_cca*theta(k) ;
   tmp(k) =  A/B;
end

%------------建立方程组-------------------------
for k=1:K
    T(k,:) = tmp(k) - tau(k);
end

end