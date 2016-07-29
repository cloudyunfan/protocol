function [R,t] = rewardComput(E_rap_avg,E_map_avg,B_rap_avg,B_map_avg)
%-----------------------计算收益函数矩阵-------------------------------------------
% Input:
%     E_rap_avg:RAP 阶段平均能消耗掉的能量
%     E_map_avg:MAP 阶段平均能消耗掉的能量
%     B_rap_avg:RAP阶段平均能传输的包数
%     B_map_avg:MAP阶段平均能传输的包数
% Output:
%     R： reward matrix
%     t: cpu time
    global A S
    tic;
    for a = 1:length(A)
        for s=1:length(S)
            R(s,a) = reward(S{s},A(a),B_rap_avg,B_map_avg,E_rap_avg,E_map_avg);
        end
    end   
    t = toc;
end