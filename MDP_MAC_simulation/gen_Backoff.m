function [backoff_counter Prob] = gen_Backoff(CW,E_buff,Emax)
%用于生成分段均匀分布的backoff counter
% Input:
%     CW: 竞争窗口
%     E_buff： 能量缓存区中的剩余能量数
%     Emax： 能量缓存区的容量
% Output：
%     backoff_counter: 生成的退避计数
N = length(E_buff);
%-----分割成两段后每一段的概率和------
pL = 0.5; %低段概率和
pH = 1- pL;  %高段概率和
eta = E_buff/(Emax-1);
%% 计算分段均匀分布的概率分布函数
Split = floor(CW - (CW-1).*(1-eta));
Prob = zeros(N,CW);
for n=1:length(E_buff)
    if(Split(n)==CW)  %分割线取到最大值
        Prob(n,CW) = pH; %高段只有一个值
        Prob(n,1:CW-1) = PL/(CW-1); 
    else
        if(Split(n)==1)  %分割线取到最小值
            Prob(n,1) = pL;%低段只有一个值
            Prob(n,2:CW) = pH/(CW-1);
        else
            Prob(n,1:Split(n)) = pL/(Split(n));
            Prob(n,Split(n)+1:CW) = pH/(CW-Split(n));
        end
    end
end
%% 根据概率分布函数生成一个退避计数
backoff_counter = zeros(N,1);
for n=1:N
    %-------随机生成一个概率------
    Preci = 10000;  %生成概率的精度
    t = randint(1,1,[1,Preci])/Preci;
    Prob_temp = 0;
    flag = 1;
    for w=1:CW
        if(Prob_temp<t && flag)
            Prob_temp = Prob_temp + Prob(n,w);  %累积概率函数
        else
            if(flag)
                backoff_counter(n) = w-1;  
                flag = 0;
            end
        end
    end
end
end