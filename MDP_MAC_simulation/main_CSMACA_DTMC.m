clear all
clc
%%
global  R  RAP Ls CWmin CWmax N lambda
CWmin = [16 8 4 2];
CWmax = [64 32 16 8];
% CWmin = [ 16 16 8 8 4 4 2 1];
% CWmax = [ 64 32 32 16 16 8 8 4];
Ls = 1;
RAP = 100;
R  = 5;  %����ش�����
E_cca = 0.025;  %���������ĵ�����
E_tx = 1; %�����ɹ����ĵ�����
E_colli = 1;  %������ͻ���ĵ�����
N = [3;3;3;1];
lambda = [1;1;1;1];
%%  ����ŵ��������tau
% tau0 = 0.05*ones(8,1);
tau0 = [0.5;0.5;0.5;0.5];
options = optimset('Display','iter');
[tau,fval] = fsolve(@Cal_tau,tau0,options);
disp('�ŵ��������Ϊ��')
disp(num2str(tau));
%% �������������ܺ� 1
% K = length(CWmin);
% fk = zeros(K,1);   %�ŵ����и���
% p = (1/(RAP-Ls))*ones(K,1);    %ʣ��ʱ϶�㹻���ڷ��Ͱ��ĸ��ʣ����Ǽ򵥼���Ϊ1
% f = 1;
% for k=1:K
%     f = f*(1-tau(k))^(N(k)); %�ŵ����и���
% end
% for k=1:K
%     fk(k) = f/(1-tau(k)); %�˱�ʱ�ŵ����и���   
%     Y(k) = ( fk(k)*tau(k) )/( 1-( 1-fk(k) )^(R+1) );
%     S(k) = tau(k)*fk(k)*(1-p(k));
% end
% end
%% �������������ܺ� 2
K = length(CWmin);
p = (1/(RAP-Ls))*ones(K,1);    %ʣ��ʱ϶�㹻���ڷ��Ͱ��ĸ���
Ptr = 1;
for k=1:K
    Ptr = Ptr*( (1-tau(k))^(N(k)) );
end
Ptr = 1 - Ptr;
for k=1:K
    temp = 1;
    for k1=1:K
        if(k1~=k)
           temp = temp*( 1-tau(k1)^(N(k1)) );
        end
        Ps(k) = tau(k)*(1-p(k))*( (1-tau(k))^(N(k)-1) )*temp/Ptr;
    end
    S(k) = ( Ps(k)*Ptr*Ls )/(1/Ptr - 1 + Ptr);
    E(k) = (E_cca+tau(k)*E_tx)/(1/Ptr - 1 + Ptr);
end
% save('para_CSMACA_VaringN(theory)(UP3,N2-2-12).mat','S1','E1','P_colli');
% save('para_CSMACA(theory)(UP0-2-4-6,N3-3-3-1).mat','S','E','Ps','Ptr','tau');