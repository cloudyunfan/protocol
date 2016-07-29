function T = Cal_tau2(X)
%�����������tau�ķ����飬tau��DTMC-CSMACAģ���нڵ�ÿ��ʱ϶���Ͱ��ĸ���
% Input:
%     X = [tau;pai];
%     tau: �ŵ�������ʡ�a vector with dimention K*1; K is the number of priority
%     pai: ����Ϊ�յĸ��ʡ�a vector with dimention K*1; K is the number of priority
% Output:
%     T: ���õ�K�������飻
global CWmin CWmax R Ls RAP N
%------------δ֪��Ԥ����----------------------------------------
K = length(X);
tau = X(1:K);

%--------------------��֪�Ĳ���-----------------------------------
% CWmin = [16 16 8 8 4 4 2 1];
% CWmax = [64 32 32 16 16 8 4];
CW = CW_backoffstage(CWmin,CWmax,R,K);  %����ÿһ���ش��Ĵ��ڣ�CW��һ��(R+1,K)����
%--------------��ôӳ�ͻ���ʡ��ŵ����и���----------------------------
fk = zeros(K,1);   %�ŵ����и���
p = (1/(RAP-Ls))*ones(K,1);    %ʣ��ʱ϶�㹻���ڷ��Ͱ��ĸ��ʣ����Ǽ򵥼���Ϊ1
f = 1;
for k=1:K
    f = f*( (1-tau(k))^(N(k)) ); %�ŵ����и���
end
for k=1:K
    fk(k) = f/(1-tau(k)); %�˱�ʱ�ŵ����и���   
    Y(k) = ( fk(k)*tau(k) )/( 1-( 1-fk(k) )^(R+1) );
end
%--------------ͨ��DTMCģ�ͻ�ù����ŵ�������ʵ�K������------------

for k=1:K
    temp2 = 0;
    for i=1:R+1  %�൱��i=0:R
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