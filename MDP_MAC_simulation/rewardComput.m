function [R,t] = rewardComput(E_rap_avg,E_map_avg,B_rap_avg,B_map_avg)
%-----------------------�������溯������-------------------------------------------
% Input:
%     E_rap_avg:RAP �׶�ƽ�������ĵ�������
%     E_map_avg:MAP �׶�ƽ�������ĵ�������
%     B_rap_avg:RAP�׶�ƽ���ܴ���İ���
%     B_map_avg:MAP�׶�ƽ���ܴ���İ���
% Output:
%     R�� reward matrix
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