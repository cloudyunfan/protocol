function [T ,E] = throughput_new(Sb,Se,a,B_rap_avg,B_map_avg,E_rap_avg,E_map_avg)
% function to calculate consume of packet
% Intput:
%     Sb: buffer state
%     Se: energy state
%     a:action
%     E_rap_avg:RAP �׶�ƽ�������ĵ�������
%     E_map_avg:MAP �׶�ƽ�������ĵ�������
%     B_rap_avg:RAP�׶�ƽ���ܴ���İ���
%     B_map_avg:MAP�׶�ƽ���ܴ���İ���
% Ouput:
%     T: packet transmitted
%     E: energy consumed
%global variable
global E_TX

if( Sb>=1&&(Se/E_TX)>=1 )
    %ͳ����ѡ����Ϊa�ܹ����͵İ�����
    T_map =  B_map_avg*( (a==2) + (a==1));
    T_rap =  B_rap_avg*( (a==2) + (a==0));
    E_map =  E_map_avg*( (a==2) + (a==1));
    E_rap =  E_rap_avg*( (a==2) + (a==0));
    
    %ʵ�����ܷ��͵İ�������״̬�����Ͱ���Ҫ�������й�
     T_rap_final = min( T_rap,Sb );  
     E_rap_final = min( E_rap,Se );
     
     %���ǵ�a==2ʱ��ͬʱʹ��RAP��MAP����ʹ��RAP���������RAP��ʹ��
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