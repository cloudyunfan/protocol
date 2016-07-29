function [Tb,Te,Tb_map] = throughput_MDCMAC(State,a,S,E,Delta,RAP)
% function to calculate consume of packet
% 2015/4/7�޸ģ�1��ȥ��ȡ���������ڸ����������ϼ��㡣
% intput:
%     State: node state{b,e}
%     a:action
%     S:number of delivered Pkt in CSMACA 
%     E:number of comsumed energy in CSMACA 
%     block: number of slot in MAP

% ouput:
%     Tb: packet consumation
%     Te: enrgy consumed
%----const varriable------
E_tx = 1;
%----------�ȼ�����Ч----------------------
Sb = State(1);
Se = State(2);
Eta = S/E;

% Tb_rap = S*RAP;
% Te_rap = E*RAP;  %�ܺ�
%% ��������������ܺ�
switch a
    case 1
        Tb_rap = 0;        
        Tb_map = 0;
    case 2
        Tb_rap = min(Sb,min(E*RAP,Se)*Eta);
        Tb_map = 0;

    case 3
        Tb_rap = 0;
        Tb_map = min(Delta,min(Sb,Se/E_tx));

    case 4
        Tb_rap = min(Sb,min(E*RAP,Se)*Eta); 
        Tb_map = min(Delta,min(Sb-Tb_rap,(Se-Tb_rap/Eta)/E_tx));            
        
end    
    Te_map = Tb_map*E_tx;
    Te_rap = Tb_rap/Eta;
    Tb = Tb_rap + Tb_map;
    Te = Te_rap + Te_map;           
end