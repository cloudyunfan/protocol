%% 计算状态转移概率矩阵和收益函数
function [T,R,t] = ProbComput(E_rap_avg,E_map_avg,B_rap_avg,B_map_avg)
% Input:
%     E_rap_avg:RAP 阶段平均能消耗掉的能量
%     E_map_avg:MAP 阶段平均能消耗掉的能量
%     B_rap_avg:RAP阶段平均能传输的包数
%     B_map_avg:MAP阶段平均能传输的包数
% Output:
%     T: transsition probability
%     R： reward matrix
%     t: cpu time

%--------全局变量------------------------------------------
global A S


%-------------------计算状态转移概率矩阵-----------------------------
ind =0;
% Twait = waitbar(0,'计算状态转移概率矩阵进度');
t = 0;
T = zeros(length(S),length(S),length(A));
for a = 1:length(A)
    for si=1:length(S)
        tic;
        for sj=1:length(S)
%             tic;
            prob = transProb(S{si},S{sj},A(a),E_rap_avg,E_map_avg,B_rap_avg,B_map_avg);  % transmission probability  , prob_B, prob_E, b, e]
%             T_B(si,sj,a) = prob_B;
%             T_E(si,sj,a) = prob_E;
            T(si,sj,a) =  prob;
%             B(si,sj,a) = b;
%             E(si,sj,a) = e;
%             t = t + toc;              
            ind = ind +1;
%             str = ['概率转移矩阵计算已完成' num2str( int32( ind*100/(length(A)*length(S)*length(S)) ) ) '%'];
%             waitbar( int32( ind/(length(A)*length(S)*length(S)) ),Twait,str );

        end 
        t_temp = toc;
         t = t + t_temp; 
         [si,a,t_temp]
    end
end
% close(Twait);  

end %function end

%----------------保存得到的概率转移矩阵和收益函数矩阵--------------------------------
% save('ProbMatr_3_3','T','S','A','R');












