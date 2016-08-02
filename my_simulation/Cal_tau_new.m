function T = Cal_tau_new(X)
%�����������tau�ķ����飬tau��DTMC-CSMACAģ���нڵ�ÿ��ʱ϶���Ͱ��ĸ���
% Input:
%     X = [tau;pai];
%     tau: �ŵ�������ʡ�a vector with dimention K*1; K is the number of priority
% Output:
%     T: ���õ�K�������飻
global ICWmin ICWmax NI P1_x E_tx E_cca
%------------δ֪��Ԥ����----------------------------------------
K = length(X);
tau = X(1:K);

%--------------------��֪�Ĳ���-----------------------------------
R  = 4;  %����ش�����
CW = CW_backoffstage(ICWmin,ICWmax,R,K);  %����ÿһ���ش��Ĵ��ڣ�CW��һ��(R+1,K)����
%--------------��ôӳ�ͻ���ʡ��ŵ����и���----------------------------
p = zeros(K,1);   %��ͻ����
q = zeros(K,1);   %�ŵ����и���
f = ones(K,1);    %ʣ��ʱ϶�㹻���ڷ��Ͱ��ĸ��ʣ����Ǽ򵥼���Ϊ1
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
%--------------ͨ��DTMC��ģ�ͻ�ù����ŵ�������ʵ�K������------------
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

%------------����������-------------------------
for k=1:K
    T(k,:) = tmp(k) - tau(k);
end

end