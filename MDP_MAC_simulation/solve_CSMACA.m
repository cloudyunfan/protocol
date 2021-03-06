function [S,E,Ptr,Ps,tau] = solve_CSMACA(Nclass,UPclass)
% Input:
%     UPclass:优先级种类
%     Nclass:每个优先级节点数
global  R  RAP Ls ICWmin ICWmax NI lambda
UP = [0,1,2,3,4,5,6,7];
CWmin = [ 16 16 8 8 4 4 2 1];
CWmax = [ 64 32 32 16 16 8 8 4];
ind = find(Nclass~=0);
ICWmin = [];
ICWmax = [];
for up=1:length(ind)
    indUP = find(UP==UPclass(ind(up)));
    ICWmin = [ICWmin CWmin(indUP)];
    ICWmax = [ICWmax CWmax(indUP)];
end

Ls = 1;
RAP = 100;
R  = 5;  %最大重传次数
E_cca = 0.025;  %不发包消耗的能量
E_tx = 1; %发包成功消耗的能量
E_colli = 1;  %发包冲突消耗的能量
NI = Nclass(find(Nclass~=0));
K = length(ICWmin);
lambda = ones(K,1);
%%  求解信道接入概率tau
tau0 = 0.5*ones(K,1);
options = optimset('Display','off');%
[tau,fval] = fsolve(@Cal_tau,tau0,options);%
% disp('信道接入概率为：')
% disp(num2str(tau));
%% 计算吞吐量和能耗 1
% K = length(CWmin);
% fk = zeros(K,1);   %信道空闲概率
% p = (1/(RAP-Ls))*ones(K,1);    %剩余时隙足够用于发送包的概率，我们简单假设为1
% f = 1;
% for k=1:K
%     f = f*(1-tau(k))^(N(k)); %信道空闲概率
% end
% for k=1:K
%     fk(k) = f/(1-tau(k)); %退避时信道空闲概率   
%     Y(k) = ( fk(k)*tau(k) )/( 1-( 1-fk(k) )^(R+1) );
%     S(k) = tau(k)*fk(k)*(1-p(k));
% end
% end
%% 计算吞吐量和能耗 2
p = zeros(K,1) ;    %(1/(RAP-Ls))*ones(K,1)剩余时隙不够用于发送包的概率
Ptr = 1;
for k=1:K
    Ptr = Ptr*( (1-tau(k))^(NI(k)) );
end
Pidle = Ptr;
Ptr = 1 - Ptr;
for k=1:K
    f(k) = Pidle/(1-tau(k))^(NI(k));
    temp = 1;
    for k1=1:K
        if(k1~=k)
           temp = temp*( 1-tau(k1)^(NI(k1)) );
        end
        Ps(k) = tau(k)*f(k)*(1-p(k))*( (1-tau(k))^(NI(k)-1) )*temp/Ptr;
    end
    S(k) = ( Ps(k)*Ptr*Ls )/(1/Ptr - 1 + Ptr);
    E(k) = (E_cca+tau(k)*E_tx)/(1/Ptr - 1 + Ptr);
end

end
% save('para_CSMACA_VaringN(theory)(UP3,N2-2-12).mat','S1','E1','P_colli');
% save('para_CSMACA(theory)(UP0-2-4-6,N3-3-3-1).mat','S','E','Ps','Ptr','ta
% u');