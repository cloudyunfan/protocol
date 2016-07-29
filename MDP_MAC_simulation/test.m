
clc

% N = 5;
% t = zeros(1,N);
% s = ones(1,N);
% ind = 0;
% RAP = 20;
% isFinish = 1;
% while( isFinish )
%     num = 0;
%     for n=1:N
%         if( (s(n)+n)<=RAP )
%             s(n)=s(n)+n;
%             t(n)=t(n)+1;
%         else
%             num = num + 1;
%         end
%     end
%     if(num<N)
%         [s;t]
%     else
%         isFinish = 0;
%     end
% end
Bmax = 30;
Emax = 30;
P_2D = zeros(Bmax,Emax);
policy = P{2,1};
for b=0:Bmax-1
    for e=0:Emax-1
        ind = findSta(S,b,e);
        P_2D(b+1,e+1) = policy(ind);
    end    
end
surf (P_2D, 'DisplayName', 'P_2D'); 


%% -----不同行为所占比例
%  L(:,1) = L0(1,2:end)';
%  L(:,2) = L1(1,2:end)';
%  L(:,3) = L2(1,2:end)';
%  L(:,4) = L3(1,2:end)';
%  W(:,1) = L0(2,2:end)';
%  W(:,2) = L1(2,2:end)';
% W(:,3) = L2(2,2:end)';
%  W(:,4) = L3(2,2:end)';
% plot(2*(2:7),L*100,'d-');
% hold on;plot(2*(2:7),W*100,'s--');
% xlabel('Node number(N)');
% ylabel('Ratio(%)');