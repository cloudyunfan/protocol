function T = Cal_tau(X)
%�����������tau�ķ����飬tau��DTMC-CSMACAģ���нڵ�ÿ��ʱ϶���Ͱ��ĸ���
% Input:
%     X = [tau;pai];
%     tau: �ŵ�������ʡ�a vector with dimention K*1; K is the number of priority
%     pai: ����Ϊ�յĸ��ʡ�a vector with dimention K*1; K is the number of priority
% Output:
%     T: ���õ�K�������飻
global ICWmin ICWmax lambda NI
%------------δ֪��Ԥ����----------------------------------------
K = length(X);
% if(mod(L,2)==0)
%     K = length(X)/2;
% else
%     disp('length of parameter illegal!');
% end
%��ȡtau��pai
tau = X(1:K);
% pai = X(K+1:end);

%--------------------��֪�Ĳ���-----------------------------------
% lam_unit = 0.05; 
% lambda = lam_unit*(1:K);   %�����ռ�����
% CWmin = [16 16 8 8 4 4 2 1];
% CWmax = [64 32 32 16 16 8 4];
R  = 5;  %����ش�����
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
   p(k) = 1 - (1-tau(k))^(NI(k)-1)*temp; 
   q(k) = (1-tau(k))^(NI(k)-1)*temp;
end
%--------------ͨ��DTMC��ģ�ͻ�ù����ŵ�������ʵ�K������------------
theta = zeros(K,1);
for k=1:K
   theta(k) = sum( (p(k).^(0:R)').*(CW(:,k)-1)/2 );
   A = 2*lambda(k)*q(k)*f(k)*(1-p(k));
   B = 2*lambda(k)*theta(k)*(1-p(k)) + 2*lambda(k)*q(k)*f(k)*p(k)*(1-p(k)^R) + lambda(k)*(1-p(k))*(CW(1,k)+1) + 2*q(k)*f(k)*(1-lambda(k))*(1-p(k));
   b(k) =  A/B;
end

%------------����������-------------------------
for k=1:K
    T(k,:) = (1-p(k)^(R+1))*b(k)/(1-p(k)) - tau(k);
end

end