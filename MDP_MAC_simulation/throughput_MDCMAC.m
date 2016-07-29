function [Tb,Te,Tb_map] = throughput_MDCMAC(State,a,S,E,Delta,RAP)
% function to calculate consume of packet
% 2015/4/7修改，1、去掉取整操作，在浮点数基础上计算。
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
%----------先计算能效----------------------
Sb = State(1);
Se = State(2);
Eta = S/E;

% Tb_rap = S*RAP;
% Te_rap = E*RAP;  %能耗
%% 计算包传输量和能耗
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