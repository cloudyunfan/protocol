%% ����״̬ת�Ƹ��ʾ�������溯��
function [T,t] = ProbComput1(S,E,Ps)
% Input:
%     S:number of delivered Pkt in CSMACA 
%     E:number of comsumed energy in CSMACA    

% Output:
%     T: transsition probability
%     t: cpu time

%--------ȫ�ֱ���------------------------------------------
global Act State lambdaE lambdaB TB Emax Bmax Delta RAP


%-------------------����״̬ת�Ƹ��ʾ���-----------------------------
ind =0;
Twait = waitbar(0,'����״̬ת�Ƹ��ʾ������');
t = 0;
T = zeros(length(S),length(State),length(Act));
for a = 1:length(Act)
    for si=1:length(State)
        tic;
        for sj=1:length(State)
%             tic;
            %----- �����ܺ�------------------
             [Tb,Te,Tb_map] = throughput1(State{si},Act(a),S,E,Delta,Ps,RAP);
             %-----�������------------------
             T(si,sj,a) = transProb1( State{si},State{sj},a,Te,Tb,TB, Emax, lambdaE, lambdaB,Bmax,Ps,RAP);
%             t = t + toc;                         
        end 
        ind = ind + 1;
        str = ['����ת�ƾ�����������' num2str( ind*100/(length(Act)*length(State) ) ) '%'];
        waitbar( ind/(length(Act)*length(State)),Twait,str );
        t_temp = toc;
        t = t + t_temp; 
%         [si,a,t_temp]
    end
end
close(Twait);  

end %function end