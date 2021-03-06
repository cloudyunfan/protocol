function [A,R] = subopt_MDPreslv(lambdaB,B,E,M,Tblock,TB,UPnode,UPclass)
% Input:
%     lambdaB:数据包到达率
%     B: 所有节点的数据状态
%     E：所有节点的能量状态
%     M：MAP阶段的时隙块数
%     Tblock：每一个时隙块长度
%     TB：超帧长度
%     UPclass:优先级种类
% Output：
%     act：输出最优的决策行为
%     UPnode:所有节点的优先级
%Note:  作了一些修改（Date：2015-05-12）
% 修改之前：
%     1.先从节点[1,M]中选取节点组合作为a4的节点，表示为集合drm;
%     2.再从节点[j+1,M]中选取节点组合作为a3的节点，表示为集合dm,j=|dm|;
%     3.再从节点[i+1,N]中选取节点组合作为a2的节点，表示为集合dr,且dr不会为空,
%         i=|drm|+|dm|+1。剩余为被选中的节点作为a1的节点。
% 修改之后：
%     1.先从节点[1,M]中选取节点组合作为a3的节点，表示为集合dm;
%     2.再从节点[1,j]中选取节点组合作为a4的节点，表示为集合drm,j=|dm|;
%     3.再从节点[j+1,N]中选取节点组合作为a2的节点，表示为集合dr,且dr不会为空。
%       剩余为被选中的节点作为a1的节点。
%% -------------求解数据传输需求指标(TRI)----------------------------
E_tx = 1;  %
RAP = TB - M*Tblock;
N = length(E);
act = ones(1,N);  %默认为1,所有节点初始化为a1节点
q = zeros(1,N);
R = 0;
for n=1:N
    q(n) = UPfactor(UPnode(n))*min(B(n),E(n)/E_tx);
end
%-----对传输需求指标排序--------------
[q_sort,d]=sort(q,'descend');
loop = 1;
%% 根据d计算不同节点组合的收益函数
dm = buildSet(min(N,M),1);
for mm=1:length(dm)
    j = length( dm{mm} ) + 1;
%     dm = buildSet(min(N,M),j);
       drm = buildSet(j,1);
    for mrm = 1:length(drm)
%         i = length( dm{mm} ) + length( drm{mrm} ) + 1;
%         dr = buildSet(N,i);
        dr = buildSet(N,j);
        for mr=2:length(dr)
            %--------获得此时节点的行为-------------
            if(~isempty(drm(mrm)))
               act( d( drm{mrm} ) ) = 4; 
            end
            if(~isempty(dm(mm)))
               act( d( dm{mm} ) ) = 3; 
            end  
            if(~isempty(dr(mr)))
               act( d( dr{mr} ) ) = 2; 
            end  
           %------计算RAP、MAP中每一种优先级的节点数--------
           indRAP = union(d( drm{mrm} ), d( dr{mr} ));
           indMAP = union(d( drm{mrm} ), d( dm{mm} ));
%            Nk = ones(1,length(UPclass));
           for up=1:length(UPclass)
%                Nk(up) = max( length( find( UPnode(indRAP)==UPclass(up) ) ),1 );%最少取1
               Nk(up) = length( find( UPnode(indRAP)==UPclass(up) ) );
           end
           S_rap = zeros(1,length(UPclass));
           E_rap = zeros(1,length(UPclass));
           if(sum(Nk)>0)
               [S_t,E_t,Ptr,Ps,tau] = solve_CSMACA(Nk,UPclass);  %求解饱和条件下CSMA/CA吞吐量和能耗            
               ind_temp = find(Nk~=0);
               S_rap(ind_temp) = S_t;
               E_rap(ind_temp) = E_t;
           end
           Ps = Ps*Ptr;
           Delta = M*Tblock/max( length(indMAP),1);
           R_temp = 0;          
           for n=1:N
               State = [B(n),E(n)];
               k = find( UPclass==UPnode(n) );
               [Tb,Te,Tb_map] = throughput_MDCMAC(State,act(n),S_rap(k),E_rap(k),Delta,RAP);
               R_temp = R_temp + UPfactor(UPnode(n))*(Tb)/(lambdaB*TB);
           end
           if(R_temp>=R)
               R = R_temp;
               A = act;
           end
           loop = loop+1; 
%            disp(num2str(loop));
        end
    end
end
end