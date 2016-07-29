function [R,t] = rewardComput1(S,E,UP,Ps)
%-----------------------计算收益函数矩阵-------------------------------------------
% Input:
%     S:number of delivered Pkt in CSMACA 
%     E:number of comsumed energy in CSMACA 
%     UP: user priority of WBAN node
% Output:
%     R： reward matrix
%     t: cpu time
   global Act State lambdaB TB Delta RAP block
    %%
    Treward = waitbar(0,'Reward comput');
    ind = 0;
    tic;
    for a = 1:length(Act)
        for s=1:length(State)
            %------------计算高优先级节点的包传输量和能耗-----------------
            [Tb,Te,Tb_map] = throughput1(State{s},a,S,E,Delta,Ps,RAP);
            %-------------计算额外惩罚项----------
            Extra = 0;
            if(a==3||a==4) %使用MAP的行为
%                 Sb = State{s}(1);
%                 Se = State{s}(2);
               Extra = 1 - min(1,Tb_map/block); 
            end
            [f_pos,f_neg]= UPfactor(UP);
            R(s,a) = (Tb*f_pos)/(lambdaB*TB) - f_neg*(Extra);%+Te/(lambdaE*TB)
            %-----------用于显示进度的-------------------------
            ind = ind + 1;
            str = ['reward comput: ',num2str( 100*ind/(length(Act)*length(State)) ) ];
            waitbar(ind/(length(Act)*length(State)),Treward,str);
        end
    end 
    
  % --将（Sb==0||Se==0）时，节点选择行为a==3的收益为所有收益的平均值----
%     R_special = max( max( R(:,1:3) ) );
%     for s=1:length(S)
%         if(S{s}(1)==0||S{s}(2)==0)
%             R(s,4) = R_special;
%         end
%     end
    
    t = toc;
    close(Treward);
end
