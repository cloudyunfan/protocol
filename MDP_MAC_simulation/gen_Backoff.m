function [backoff_counter Prob] = gen_Backoff(CW,E_buff,Emax)
%�������ɷֶξ��ȷֲ���backoff counter
% Input:
%     CW: ��������
%     E_buff�� �����������е�ʣ��������
%     Emax�� ����������������
% Output��
%     backoff_counter: ���ɵ��˱ܼ���
N = length(E_buff);
%-----�ָ�����κ�ÿһ�εĸ��ʺ�------
pL = 0.5; %�Ͷθ��ʺ�
pH = 1- pL;  %�߶θ��ʺ�
eta = E_buff/(Emax-1);
%% ����ֶξ��ȷֲ��ĸ��ʷֲ�����
Split = floor(CW - (CW-1).*(1-eta));
Prob = zeros(N,CW);
for n=1:length(E_buff)
    if(Split(n)==CW)  %�ָ���ȡ�����ֵ
        Prob(n,CW) = pH; %�߶�ֻ��һ��ֵ
        Prob(n,1:CW-1) = PL/(CW-1); 
    else
        if(Split(n)==1)  %�ָ���ȡ����Сֵ
            Prob(n,1) = pL;%�Ͷ�ֻ��һ��ֵ
            Prob(n,2:CW) = pH/(CW-1);
        else
            Prob(n,1:Split(n)) = pL/(Split(n));
            Prob(n,Split(n)+1:CW) = pH/(CW-Split(n));
        end
    end
end
%% ���ݸ��ʷֲ���������һ���˱ܼ���
backoff_counter = zeros(N,1);
for n=1:N
    %-------�������һ������------
    Preci = 10000;  %���ɸ��ʵľ���
    t = randint(1,1,[1,Preci])/Preci;
    Prob_temp = 0;
    flag = 1;
    for w=1:CW
        if(Prob_temp<t && flag)
            Prob_temp = Prob_temp + Prob(n,w);  %�ۻ����ʺ���
        else
            if(flag)
                backoff_counter(n) = w-1;  
                flag = 0;
            end
        end
    end
end
end