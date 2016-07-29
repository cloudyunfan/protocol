function [PS,Colli,ELE,E_buff,B_buff] = PC_poll(len_PC,E_buff,B_buff,indNL)
global E_TX E_CCA t Succ_TX_time B_of EH_of B EH Emax Bmax lambdaE lambdaB
%% parameters
%AIMD parameters
delta_add = 0.01;
delta_md = 0.5;
N = length(indNL);
Colli = zeros(1,N);
PS = zeros(1,N);
ELE = zeros(1,N);
% is_TX = zeros(len_PC,N);
%% simu
Pc = 0.5;
isPC = zeros(1,N);
Tx = zeros(1,N);
t_start = t;
while( t <= t_start+len_PC)
    for n=1:N
        if(E_buff(n)>=E_CCA)  %receive PC Pkt
           isPC(n) = 1;
           E_buff(n) = E_buff(n) - E_CCA;
           ELE(n) = ELE(n) + E_CCA;
        else
            isPC(n) = 0;
        end
       p(n) = rand(); 
       if(p(n)<Pc&&E_buff(n)>=E_TX&&B_buff(n)>=1&&isPC(n)==1)
          Tx(n) = 1; 
          E_buff(n) = E_buff(n) - E_TX;
          ELE(n) = ELE(n) + E_TX;
       else
           Tx(n) = 0;
       end
    end
    %check if collision
    indC = find(Tx==1);
    if(length(indC)>1)
        %dcreases Pc
        Pc = Pc*delta_md;
        Colli(indC) = Colli(indC) + 1;
    else
        if(isempty(indC))
            %increases Pc
            Pc = min( Pc + delta_add,1);
        else
%             is_TX(t,n) = 1;
            PS(indC) = PS(indC) + 1;
            Succ_TX_time(t,indNL(indC)) = 1;
        end
    end
    
    %---buffer update
     [E_overflow,B_overflow,e_flow,b_flow,E_buff,B_buff] = buff_update_HEHMAC(1,E_buff,B_buff,lambdaE,lambdaB,Emax,Bmax);
    B_of(indNL) = B_of(indNL) + B_overflow;
    B(indNL) = B(indNL) + b_flow;  
    EH_of(indNL) = EH_of(indNL) + E_overflow;
    EH(indNL) = EH(indNL) + e_flow;
    t = t + 1;
end
% Succ_TX_time = cell(1,N);
% for n=1:N
%     indTX = find(is_TX(:,n)==1);
%     if(~isempty(indTX))
%         Succ_TX_time{1,n} = indTX;
%     end
%     
% end

end