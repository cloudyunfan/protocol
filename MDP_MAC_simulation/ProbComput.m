%% ����״̬ת�Ƹ��ʾ�������溯��
function [T,R,t] = ProbComput(E_rap_avg,E_map_avg,B_rap_avg,B_map_avg)
% Input:
%     E_rap_avg:RAP �׶�ƽ�������ĵ�������
%     E_map_avg:MAP �׶�ƽ�������ĵ�������
%     B_rap_avg:RAP�׶�ƽ���ܴ���İ���
%     B_map_avg:MAP�׶�ƽ���ܴ���İ���
% Output:
%     T: transsition probability
%     R�� reward matrix
%     t: cpu time

%--------ȫ�ֱ���------------------------------------------
global A S


%-------------------����״̬ת�Ƹ��ʾ���-----------------------------
ind =0;
% Twait = waitbar(0,'����״̬ת�Ƹ��ʾ������');
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
%             str = ['����ת�ƾ�����������' num2str( int32( ind*100/(length(A)*length(S)*length(S)) ) ) '%'];
%             waitbar( int32( ind/(length(A)*length(S)*length(S)) ),Twait,str );

        end 
        t_temp = toc;
         t = t + t_temp; 
         [si,a,t_temp]
    end
end
% close(Twait);  

end %function end

%----------------����õ��ĸ���ת�ƾ�������溯������--------------------------------
% save('ProbMatr_3_3','T','S','A','R');












