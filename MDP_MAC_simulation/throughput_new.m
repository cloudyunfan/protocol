function [T ,E] = throughput_new(Sb,Se,a,B_rap_avg,B_map_avg,E_rap_avg,E_map_avg)
% function to calculate consume of packet
% Intput:
%     Sb: buffer state
%     Se: energy state
%     a:action
%     E_rap_avg:RAP 阶段平均能消耗掉的能量
%     E_map_avg:MAP 阶段平均能消耗掉的能量
%     B_rap_avg:RAP阶段平均能传输的包数
%     B_map_avg:MAP阶段平均能传输的包数
% Ouput:
%     T: packet transmitted
%     E: energy consumed
%global variable
global E_TX

if( Sb>=1&&(Se/E_TX)>=1 )
    %统计上选择行为a能够发送的包数量
    T_map =  B_map_avg*( (a==2) + (a==1));
    T_rap =  B_rap_avg*( (a==2) + (a==0));
    E_map =  E_map_avg*( (a==2) + (a==1));
    E_rap =  E_rap_avg*( (a==2) + (a==0));
    
    %实际上能发送的包数量和状态、发送包需要的能量有关
     T_rap_final = min( T_rap,Sb );  
     E_rap_final = min( E_rap,Se );
     
     %考虑当a==2时，同时使用RAP和MAP，先使用RAP，多余的在RAP中使用
    Sb1 = Sb - T_rap_final;
    Se1 = Se - E_rap_final;
    T_map_final = min( T_map,Sb1 );
    E_map_final = min( E_map,Se1 );
    
    T = T_rap_final + T_map_final;
    E = E_rap_final + E_map_final;
else 
    T = 0;
    E = 0;
end %end if

end %end function