function [S,E,PL,Ps,tau] = solve_CSMACA_new(Nclass,UPclass)
% Input:
%     UPclass:优先级种类
%     Nclass:每个优先级节点数
global  R Lp ICWmin ICWmax NI E_tx E_rx Ts Eth Etx M E_cca P1_x E_th%E_colli
UP = [0,1,2,3,4,5,6,7];
CWmin = [ 16 16 8 8 4 4 2 1];
CWmax = [ 64 32 32 16 16 8 8 4];
ind = find(Nclass~=0);
ICWmin = [];
ICWmax = [];
for up=1:length(ind)
    indUP = find( UP==UPclass(ind(up)) );
    ICWmin = [ICWmin CWmin(indUP)];
    ICWmax = [ICWmax CWmax(indUP)];
end

Lp = 114;
Lsift = 0.2;%0.6 %0.2
Ls = 1+3*Lsift; %;0.8*  %3* 
Lc = 1+Lsift; %;  %1*
Lidle = 1; %0.85; %1
% TB = 2000;
% Tsim = 2000;
R  = M;  %最大重传次数

NI = Nclass( find(Nclass~=0) );
K = length(ICWmin);

%%  求解信道接入概率tau
tau0 = 0.5*ones(K,1);
options = optimset('Display','off');%
[tau,~] = fsolve(@Cal_tau_new,tau0,options);%
Pcca = (P1_x/E_cca)*ones(K,1)-tau;
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
f = (199/200)*ones(K,1) ;    %((RAP-Ls)/(RAP-Ls))*ones(K,1)剩余时隙够用于发送包的概率
Ptr = 1;
%计算冲突能耗
E_colli = zeros(1,K);
for k=1:K
    Ptr = Ptr*( (1-tau(k))^(NI(k)) );
%      for i=2:NI(k)
%          E_colli(k) = E_colli(k)+ i*(E_tx)*nchoosek(NI(k),i)*tau(k)^i*(1-tau(k))^(NI(k)-i);
%      end;
     E_colli(k) = E_tx;
end
Pidle = Ptr;
Ptr = 1 - Ptr;
for k=1:K
    p(k) = Pidle/(1-tau(k))^(NI(k));
%     temp = 1;
%     for k1=1:K
%         if(k1~=k)
%            temp = temp*( 1-tau(k1)^(NI(k1)) );
%         end
%     end
    Ps(k) = tau(k)*f(k)*( (1-tau(k))^(NI(k)-1) )*p(k);%*temp
    Pc(k) = tau(k)-Ps(k);
    E1(k) =  Ps(k)*(E_tx)+( tau(k)-Ps(k) )*E_colli(k)+Pcca(k)*E_cca;
end
    PS = sum( Nclass( find( Nclass~=0 ) ).*Ps );
for k=1:K
    S(k) = ( Ps(k)*Lp )/(Ts*( (1-Ptr)*Lidle + Ptr*PS*Ls+(1-PS)*Ptr*Lc ));
    PL(k) = (Pc(k)^(R+1));%/( (1-Ptr)*Lidle + Ptr*PS*Ls+(1-PS)*Ptr*Lc );
    E(k) = (E1(k)*Etx)/(Ts*( (1-Ptr)*Lidle + Ptr*PS*Ls+(1-PS)*Ptr*Lc ));%
end
   

end
% save('para_CSMACA_VaringN(theory)(UP3,N2-2-12).mat','S1','E1','P_colli');
% save('para_CSMACA(theory)(UP0-2-4-6,N3-3-3-1).mat','S','E','Ps','Ptr','ta
% u');