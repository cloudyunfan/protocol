function [R,t] = rewardComput1(S,E,UP,Ps)
%-----------------------�������溯������-------------------------------------------
% Input:
%     S:number of delivered Pkt in CSMACA 
%     E:number of comsumed energy in CSMACA 
%     UP: user priority of WBAN node
% Output:
%     R�� reward matrix
%     t: cpu time
   global Act State lambdaB TB Delta RAP block
    %%
    Treward = waitbar(0,'Reward comput');
    ind = 0;
    tic;
    for a = 1:length(Act)
        for s=1:length(State)
            %------------��������ȼ��ڵ�İ����������ܺ�-----------------
            [Tb,Te,Tb_map] = throughput1(State{s},a,S,E,Delta,Ps,RAP);
            %-------------�������ͷ���----------
            Extra = 0;
            if(a==3||a==4) %ʹ��MAP����Ϊ
%                 Sb = State{s}(1);
%                 Se = State{s}(2);
               Extra = 1 - min(1,Tb_map/block); 
            end
            [f_pos,f_neg]= UPfactor(UP);
            R(s,a) = (Tb*f_pos)/(lambdaB*TB) - f_neg*(Extra);%+Te/(lambdaE*TB)
            %-----------������ʾ���ȵ�-------------------------
            ind = ind + 1;
            str = ['reward comput: ',num2str( 100*ind/(length(Act)*length(State)) ) ];
            waitbar(ind/(length(Act)*length(State)),Treward,str);
        end
    end 
    
  % --����Sb==0||Se==0��ʱ���ڵ�ѡ����Ϊa==3������Ϊ���������ƽ��ֵ----
%     R_special = max( max( R(:,1:3) ) );
%     for s=1:length(S)
%         if(S{s}(1)==0||S{s}(2)==0)
%             R(s,4) = R_special;
%         end
%     end
    
    t = toc;
    close(Treward);
end
