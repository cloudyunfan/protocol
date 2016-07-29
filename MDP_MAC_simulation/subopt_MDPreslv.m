function [A,R] = subopt_MDPreslv(lambdaB,B,E,M,Tblock,TB,UPnode,UPclass)
% Input:
%     lambdaB:���ݰ�������
%     B: ���нڵ������״̬
%     E�����нڵ������״̬
%     M��MAP�׶ε�ʱ϶����
%     Tblock��ÿһ��ʱ϶�鳤��
%     TB����֡����
%     UPclass:���ȼ�����
% Output��
%     act��������ŵľ�����Ϊ
%     UPnode:���нڵ�����ȼ�
%Note:  ����һЩ�޸ģ�Date��2015-05-12��
% �޸�֮ǰ��
%     1.�ȴӽڵ�[1,M]��ѡȡ�ڵ������Ϊa4�Ľڵ㣬��ʾΪ����drm;
%     2.�ٴӽڵ�[j+1,M]��ѡȡ�ڵ������Ϊa3�Ľڵ㣬��ʾΪ����dm,j=|dm|;
%     3.�ٴӽڵ�[i+1,N]��ѡȡ�ڵ������Ϊa2�Ľڵ㣬��ʾΪ����dr,��dr����Ϊ��,
%         i=|drm|+|dm|+1��ʣ��Ϊ��ѡ�еĽڵ���Ϊa1�Ľڵ㡣
% �޸�֮��
%     1.�ȴӽڵ�[1,M]��ѡȡ�ڵ������Ϊa3�Ľڵ㣬��ʾΪ����dm;
%     2.�ٴӽڵ�[1,j]��ѡȡ�ڵ������Ϊa4�Ľڵ㣬��ʾΪ����drm,j=|dm|;
%     3.�ٴӽڵ�[j+1,N]��ѡȡ�ڵ������Ϊa2�Ľڵ㣬��ʾΪ����dr,��dr����Ϊ�ա�
%       ʣ��Ϊ��ѡ�еĽڵ���Ϊa1�Ľڵ㡣
%% -------------������ݴ�������ָ��(TRI)----------------------------
E_tx = 1;  %
RAP = TB - M*Tblock;
N = length(E);
act = ones(1,N);  %Ĭ��Ϊ1,���нڵ��ʼ��Ϊa1�ڵ�
q = zeros(1,N);
R = 0;
for n=1:N
    q(n) = UPfactor(UPnode(n))*min(B(n),E(n)/E_tx);
end
%-----�Դ�������ָ������--------------
[q_sort,d]=sort(q,'descend');
loop = 1;
%% ����d���㲻ͬ�ڵ���ϵ����溯��
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
            %--------��ô�ʱ�ڵ����Ϊ-------------
            if(~isempty(drm(mrm)))
               act( d( drm{mrm} ) ) = 4; 
            end
            if(~isempty(dm(mm)))
               act( d( dm{mm} ) ) = 3; 
            end  
            if(~isempty(dr(mr)))
               act( d( dr{mr} ) ) = 2; 
            end  
           %------����RAP��MAP��ÿһ�����ȼ��Ľڵ���--------
           indRAP = union(d( drm{mrm} ), d( dr{mr} ));
           indMAP = union(d( drm{mrm} ), d( dm{mm} ));
%            Nk = ones(1,length(UPclass));
           for up=1:length(UPclass)
%                Nk(up) = max( length( find( UPnode(indRAP)==UPclass(up) ) ),1 );%����ȡ1
               Nk(up) = length( find( UPnode(indRAP)==UPclass(up) ) );
           end
           S_rap = zeros(1,length(UPclass));
           E_rap = zeros(1,length(UPclass));
           if(sum(Nk)>0)
               [S_t,E_t,Ptr,Ps,tau] = solve_CSMACA(Nk,UPclass);  %��ⱥ��������CSMA/CA���������ܺ�            
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