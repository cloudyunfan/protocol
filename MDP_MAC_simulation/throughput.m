function [T ,E] = throughput(Sb,Se,a)
% function to calculate consume of packet
% intput:
%     Sb: buffer state
%     Se: energy state
%     a:action
% ouput:
%     T: packet consumation
global T_avg_rap T_avg_map E_rap_pkt E_map_pkt

if(Sb>0)
    %统计上选择行为a能够发送的包数量
    T_map =  T_avg_map*( (a==2) + (a==1));
    T_rap =  T_avg_rap*( (a==2) + (a==0));
    
    %实际上能发送的包数量和状态、发送包需要的能量有关
     T_rap_final = min( T_rap,min(Sb,floor(Se/E_rap_pkt)) );    
     %考虑当a==2时，同时使用RAP和MAP，先使用RAP，多余的包在RAP中传输
    Sb1 = Sb - T_rap_final;
    Se1 = Se - T_rap_final*E_rap_pkt;
    T_map_final = min( T_map,min(Sb1,floor(Se1/E_map_pkt)) );
    
    T = T_rap_final + T_map_final;
    E = T_rap_final*E_rap_pkt + T_map_final*E_map_pkt; %根据每个阶段发送的包数量计算消耗的能量
else 
    T = 0;
    E = 0;
end

end