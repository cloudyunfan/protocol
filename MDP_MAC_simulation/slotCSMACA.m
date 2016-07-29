function [ ReTX_time,lock_backoff,CSMA_sta,tdma_CHN_sta,pl_t,ps_t,PL_colli,Succ_time_avg,ELE_ex] = slotCSMACA(cap_length,CSMA_sta,def_time_pre,last_CHN_sta, action,ReTX_time_pre)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1.the deferred backoff time is feedbacked; those nodes without deference def_backoff is set to 0;
% 2.CSMA state is also feedbacked just with 0 or 1, i.e., deferred backoff
% and CCA(���CSMAͣ���ڵ�״ֻ̬��0��1),0��ʾ���ͳɹ��ˣ�1��ʾ��CCAʱ�ŵ�æ��ͣ����CCA״̬
% 3.action is 0 or 1, stand for node choosing CSMA/CA to transsmit packet or not
% 4. last_TX_time record the last time a node send a packet successfullly
% 5.the initial channel state of TDMA part of each node is output
% 6.pkt loss and success and times of collisions are output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parameters initialization 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
global N Pbg Pgb CW CWmin CWmax UP UPnode M E_buff B_buff

%-----------����---------------------------------------------------------
E_CCA = 0.015;   %�ŵ�������ĵ�����
E_TX = 1;       %�������ݰ���Ҫ������
Backoff_time = zeros(1,N); % temporal variable to record backoff time
ReTX_time = ReTX_time_pre;  %����ش�����
CHN = 0; % channel state flag
ELE = zeros(1,N); %nodes' energy flag
ELE_ex = zeros(1,N); % ��¼����֡���ĵ�������
PKT = zeros(1,N); %nodes' packet buffer flag
lock_backoff = -1*ones(1,N); % deferred backoff should be output,defoult -1
last_TX_time = ones(1,N); % the last TX time of a node
Succ_TX_time = zeros(cap_length,N);  %��¼�ڵ�ÿ�γɹ�������ʱ��
% tdma_CHN_sta = zeros(1,N);           % the channel state after CAP should be output
no_use = zeros(1,N);
% inst_tx_time = 0; % time to see if there is a collision; the value equals to last_TX_time
pl_t=zeros(1,N);
ps_t=zeros(1,N);
% tdc=0;
PL_colli=zeros(1,N); % pkt loss caused by collisions
% tdc_simul=0; % collisions of the same time

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialization is over, protocol is started.
% to check every time point during CAP period there are four states for
% nodes. When instant time exceed CAP length, protocol stops.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
slot = 1;
while (slot <=cap_length) 
    for n=1:N
        if ( (action(n)==0||action(n)==2) && (ELE(n)==0&&PKT(n)==0) )  %���ڵ�ѡ��RAP�׶δ�������,�����㹻��ź�����
            switch CSMA_sta(n)
                case 0 % 0 state for backoff
                    % initialize the backoff period of each node with initial state
                    % set to 0
                    if def_time_pre(n) == -1 %��һ��֡�е�backoff time û��ʹ��CSMA/CA�������ݻ��ߴ��������
                        Backoff_time(n) = randint(1,1,[1,CW(n)]);
                    else % nodes with defer ��һ��֡�е�backoff time��ʣ��
                        Backoff_time(n) = def_time_pre(n);
                        def_time_pre(n) = -1;
                    end           
                    CSMA_sta(n) = 1; % �����˱�״̬

                case 1 % now start to check the backoff            
                    if(Backoff_time(n) == 0) %�˱ܵ�0�����뷢��״̬
                          ELE_ex(n) = ELE_ex(n) + min(E_CCA,E_buff(n));  %���ĵ������ۻ�����
                          E_buff(n) = E_buff(n) - E_CCA;   %����ŵ�״̬��Ҫ����
                          if(E_buff(n)<0)
                              E_buff(n) = 0;
                              ELE(n) = 1;
                          end
                          if(CHN==1) % channel busy
                                %׼������ʱ����ŵ�æµ�������һ���ش���
                                PL_colli(n) = PL_colli(n) + 1;         %��ͻ������1
                                ReTX_time(n) = ReTX_time(n) + 1;                       
                                if(ReTX_time(n) >= M)           %�ﵽ����ش�������������ǰ��
                                    pl_t(n) = pl_t(n) + 1;                %����������1
                                    ReTX_time(n) = 0;        %�ش�������0
                                    CW(n) = CWmin(find(UP==UPnode(n)));  %�޸ľ�������Ϊ�ڵ��Ӧ���ȼ���CWmin 
                                    CSMA_sta(n) = 0;
                                else
                                    %�޸ľ�����
                                    if (ReTX_time(n) > 0 && mod(ReTX_time(n),2) == 0)
                                        CW(n) = min(2*CW(n),CWmax(find(UP==UPnode(n))));
                                    end
                                    CSMA_sta(n) = 0;        %�ص���ʼ״̬���ش�
                                end
                         else % now it can be TX
                                CHNb_leng = floor( slot ) - floor ( last_TX_time(n) ); % last TX time is the time when a node finish last packet TX    ʱ϶��Ϊ����ʱ����������ʱ϶��״̬Ϊ׼������ȫ��С��
                                CHN=1;  %�����ŵ�Ϊæµ
                                [ PL_cap,PS_cap,last_CHN_sta(n), no_use(n)] = pktsend( CHNb_leng,0,last_CHN_sta(n),1,Pbg(n),Pgb(n)); % TX one packet, the channel state when the pkt is finished is recorded and used 
                                %������ͳɹ����ڵ�ǰʱ϶�����
                                if(PS_cap>0)
                                    Succ_TX_time(slot,n) = 1;
                                end
                                %----------------�޸�buffer------------------                               
                                B_buff(n) = B_buff(n) - PS_cap;  %�������ݻ���������
                                if(B_buff(n)<0)
                                  B_buff(n) = 0;
                                  PKT(n) = 1;
                                end
                                E_buff(n) = E_buff(n) - E_TX;   %���ٵ����������������跢һ��������E_TX����λ���������۷��ͳɹ���񶼽�����
                                ELE_ex(n) = ELE_ex(n) + min(E_TX,E_buff(n));  %���ĵ������ۻ����� 
                                if(E_buff(n)<0)
                                  E_buff(n) = 0;
                                  ELE(n) = 1;
                                end
                                %------------------------------------------
                                pl_t(n) = pl_t(n) + PL_cap;  %��pktsend�׶ζ�����Ҳ�����
                                ps_t(n) = ps_t(n) + PS_cap;
                                CSMA_sta(n)=2; % when the TX is finished, update the channel condition
                          end
                    else %�����˱�
                         ELE_ex(n) = ELE_ex(n) + min(E_CCA,E_buff(n));  %���ĵ������ۻ�����
                         E_buff(n) = E_buff(n) - E_CCA;   %����ŵ�״̬��Ҫ0.1��λ������                          
                         if(E_buff(n)<0)
                              E_buff(n) = 0;
                              ELE(n) = 1;
                         end
                         if(CHN==0) % �ŵ����в�ִ���˱�ʱ���1
                            Backoff_time(n) = Backoff_time(n) - 1;  %�˱�ʱ���1                    
                         end
                         if(slot == cap_length)
                           %�����ǰʱ϶�����һ��ʱ϶�����޷���ɷ��Ͱ�������,�˱�ʱ�������ȵ���һ��֡������
                           lock_backoff(n) = Backoff_time(n);
                           CSMA_sta(n) = 0;  %���س�ʼ״̬
                         end
                    end      
  
                case 2 % finishing TX, update channel
                    CHN = 0;
                    last_TX_time(n) = slot;   %��ǰʱ϶�ɹ�������һ����
                    CW(n) = CWmin(find(UP==UPnode(n)));  %�޸ľ�������Ϊ�ڵ��Ӧ���ȼ���CWmin 
                    CSMA_sta(n) = 0; % TX is succeed, restart the algorithm       
            end
        end
    end
    slot = slot + 1;  %��һ��ʱ϶
end
% include data collision to calculate the actual pkt loss
% ��ͻ���ش��������ӳ٣���ֱ�ӵ��¶������������ǲ��ѳ�ͻ�����ӵ�������
% pl_t = pl_t+PL_colli;
% ps_t = ps_t-PL_colli;

%------------��ÿ���ڵ���������γɹ�������ƽ�����-------------------------------
Succ_time_avg = zeros(1,N);
for n=1:N
    ind = find(Succ_TX_time(:,n)==1);
    if(length(ind) > 1)
        Succ_time_avg(n) = mean( diff(ind) );
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the CSMA/CA and the TX is over
% calculate the channel state after CAP, i.e., the begining of TDMA, for
% each node
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for n=1:N
    for g=1:(floor (cap_length) - floor (last_TX_time(n)))
        if last_CHN_sta(n) == 1
            last_CHN_sta(n) = randsrc(1,1,[0 1;Pgb(n) 1-Pgb(n)]); %%%%%% channel model
        else
            last_CHN_sta(n) = randsrc(1,1,[0 1;1-Pbg(n) Pbg(n)]); %%%%%% using Markov chain
        end
    end
    tdma_CHN_sta(n)=last_CHN_sta(n);
end
    
end % function end

