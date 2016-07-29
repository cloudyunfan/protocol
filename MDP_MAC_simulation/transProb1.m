function prob = transProb1( State_pre,State_aft,a,Te,Tb,TB, Emax, lambdaE, lambdaB, Bmax,Ps,RAP)
%  we take use of the function to calculate transition matrix
% Input:
%     State_pre: state before transission
%     State_aft: state after transission
%     Te: energy comsumed
%     Tb: PKt deliveried
% % Output:
%     prob:  probability of transition from State_pre to State_aft with action a
% global TB Emax lambdaE lambdaB Bmax
Sbi = State_pre(1);
Sei = State_pre(2);
Gi = State_pre(3);
Sbj = State_aft(1);
Sej = State_aft(2);
Gj = State_aft(3);
%----energy Prob----
    e = Sej - Sei + Te;
    e = ceil(e);
    if(e>=0)
        if(Sej<(Emax-1))
           prob_E = exp(-lambdaE*TB)*(lambdaE*TB)^(e)/factorial(e);
        else
           ke=0:e-1;
           tempE = exp(-lambdaE*TB)*(lambdaE*TB).^(ke)./factorial(ke); 
           prob_E = 1-sum(tempE);
        end
    else 
        prob_E = 0;
    end
 %-----Pkt Prob-----------
    b = Sbj - Sbi + Tb;
    b = ceil(b);
    if(b>=0)
        if(Sbj<(Bmax-1))
           prob_B = exp(-lambdaB*TB)*(lambdaB*TB)^(b)/factorial(b);
        else
           kb=0:b-1;
           tempB = exp(-lambdaB*TB)*(lambdaB*TB).^(kb)./factorial(kb); 
           prob_B = 1-sum(tempB);
        end
    else 
        prob_B = 0;
    end
    
 %---G prob---------
 P_req = 1 - (1-Ps)^(RAP);
 if(a==1||a==2)
     if(Gi==0)
        if(Gj==0)
            prob_G = 1;
        else
            prob_G = 0;
        end
     else
        if(Gj==0)
            prob_G = P_req;
        else
            prob_G = 1-P_req;
        end
     end
 else
     if(Gi==0)
        if(Gj==0)
            prob_G = 1-P_req;
        else
            prob_G = P_req;
        end
     else
        if(Gj==0)
            prob_G = 0;
        else
            prob_G = 1;
        end
     end
 end
  %-----total Prob----
  prob =  prob_E*prob_B*prob_G;

end