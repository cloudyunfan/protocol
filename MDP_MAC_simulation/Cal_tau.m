function T = Cal_tau(X)
%这是用于求解tau的方程组，tau是DTMC-CSMACA模型中节点每个时隙发送包的概率
% Input:
%     X = [tau;pai];
%     tau: 信道接入概率。a vector with dimention K*1; K is the number of priority
%     pai: 队列为空的概率。a vector with dimention K*1; K is the number of priority
% Output:
%     T: 所得的K个方程组；
global ICWmin ICWmax lambda NI
%------------未知数预处理----------------------------------------
K = length(X);
% if(mod(L,2)==0)
%     K = length(X)/2;
% else
%     disp('length of parameter illegal!');
% end
%提取tau和pai
tau = X(1:K);
% pai = X(K+1:end);

%--------------------已知的参数-----------------------------------
% lam_unit = 0.05; 
% lambda = lam_unit*(1:K);   %能量收集速率
% CWmin = [16 16 8 8 4 4 2 1];
% CWmax = [64 32 32 16 16 8 4];
R  = 5;  %最大重传次数
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
   p(k) = 1 - (1-tau(k))^(NI(k)-1)*temp; 
   q(k) = (1-tau(k))^(NI(k)-1)*temp;
end
%--------------通过DTMC子模型获得关于信道接入概率的K个方程------------
theta = zeros(K,1);
for k=1:K
   theta(k) = sum( (p(k).^(0:R)').*(CW(:,k)-1)/2 );
   A = 2*lambda(k)*q(k)*f(k)*(1-p(k));
   B = 2*lambda(k)*theta(k)*(1-p(k)) + 2*lambda(k)*q(k)*f(k)*p(k)*(1-p(k)^R) + lambda(k)*(1-p(k))*(CW(1,k)+1) + 2*q(k)*f(k)*(1-lambda(k))*(1-p(k));
   b(k) =  A/B;
end

%------------建立方程组-------------------------
for k=1:K
    T(k,:) = (1-p(k)^(R+1))*b(k)/(1-p(k)) - tau(k);
end

end