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
    %ͳ����ѡ����Ϊa�ܹ����͵İ�����
    T_map =  T_avg_map*( (a==2) + (a==1));
    T_rap =  T_avg_rap*( (a==2) + (a==0));
    
    %ʵ�����ܷ��͵İ�������״̬�����Ͱ���Ҫ�������й�
     T_rap_final = min( T_rap,min(Sb,floor(Se/E_rap_pkt)) );    
     %���ǵ�a==2ʱ��ͬʱʹ��RAP��MAP����ʹ��RAP������İ���RAP�д���
    Sb1 = Sb - T_rap_final;
    Se1 = Se - T_rap_final*E_rap_pkt;
    T_map_final = min( T_map,min(Sb1,floor(Se1/E_map_pkt)) );
    
    T = T_rap_final + T_map_final;
    E = T_rap_final*E_rap_pkt + T_map_final*E_map_pkt; %����ÿ���׶η��͵İ������������ĵ�����
else 
    T = 0;
    E = 0;
end

end