function R = reward(S,a,TX_rap_avg,TX_map_avg,B_rap_avg,B_map_avg)
% to calculate reward for transmission from state Si to Sj with action a 
% Input:
%     S: state
%     a: action
%     TX_rap_avg: RAP�׶�ƽ������һ������Ҫ������
%     TX_map_avg: MAP�׶�ƽ������һ������Ҫ������
%     B_rap_avg:RAP�׶�ƽ���ܴ���İ���
%     B_map_avg:MAP�׶�ƽ���ܴ���İ���
% Output:
%     R: reward
global Emax Bmax lambdaB lambdaE TB ;

%% -----------��ȡ���ݺ�����״̬-------------------
Sb = S(1);
Se = S(2);
[Tb,Te] = throughput1(Sb,Se,a,B_rap_avg,B_map_avg,TX_rap_avg,TX_map_avg);
gammaB = Sb/(Bmax-1);%���ݰ��ۿ�����
gammaE = Se/(Emax-1);%�����ۿ�����

%% ---------�ɴ���İ����������Ľ���-------------------
R1 = Tb/(lambdaB*TB);   
% R1 = R1*gammaB;%

%% -----------���ó���ʱ϶��Դ�����Ľ���-----------------
S_map = B_map_avg;
S_rap = B_rap_avg;
S_t = S_map + S_rap;
switch a
    case 0
        R2 = S_map/S_t;   %��һ���Ľ���
    case 1
        R2 = S_rap/S_t;
    case 2
        R2 = 0;
    case 3
        R2 = 1;
end
%���ݽڵ�buffer���������������������ۿ����ӣ�buffer��������������Խ���ۿ�����ԽС
R2 = R2*( 1 - min(gammaB,gammaE) );

%% ----------�����ĵ����������ĳͷ�---------------------
D1 = Te/(lambdaE*TB);
% D1 = D1*( 1-gammaE );%

%% -------------���˷�ʱ϶��Դ�����ĳͷ�-----------
switch a
    case 0
       D2 = max( S_rap - min(Sb,Se/TX_rap_avg),0 )/(S_rap+S_map);  
    case 1
       D2 = max( S_map - min(Sb,Se/TX_map_avg),0 )/(S_rap+S_map);    
    case 2
       D2 = max( S_rap - min(Sb,Se/TX_rap_avg),0 );
       [b,e] = throughput1(Sb,Se,0,B_rap_avg,B_map_avg,TX_rap_avg,TX_map_avg);  %��ȥRAP�׶ε�����
       D2 = D2 + max( S_map - min(Sb-b,(Se-e)/TX_map_avg),0 );
       D2 = D2/(S_rap+S_map);
    case 3
       D2 = 0;
end

%% ------------ѡ��ͬ����Ϊ���Ե����޵õ��Ķ�������--------
%----���ݰ�����---
eta1 = S_rap;   %S_rap С����Ϊ��һ����
eta2 = S_map; %S_rap < S_map
%----��������-----
% niu1 = B_map_avg*TX_map_avg;   %map�׶κ���С����Ϊ��һ������
% niu2 = B_rap_avg*TX_rap_avg;
B_eff_rap = min(Sb,Se/TX_rap_avg);
B_eff_map = min(Sb,Se/TX_map_avg);
switch a
    case 0         
        R3 = (B_eff_rap-eta1)/eta1;  
    case 1        
        R3 = (B_eff_map-eta2)/eta2;  
    case 2
        R3 = (B_eff_map - eta2)/eta2 + (B_eff_rap-eta1)/eta1;
    case 3
        R3 = 0;
end
%% ----------------����������---------------------------
R = R1 ;% + R3 - D2 - D1 + R2

end %end function