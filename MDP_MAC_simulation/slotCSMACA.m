function [ ReTX_time,lock_backoff,CSMA_sta,tdma_CHN_sta,pl_t,ps_t,PL_colli,Succ_time_avg,ELE_ex] = slotCSMACA(cap_length,CSMA_sta,def_time_pre,last_CHN_sta, action,ReTX_time_pre)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1.the deferred backoff time is feedbacked; those nodes without deference def_backoff is set to 0;
% 2.CSMA state is also feedbacked just with 0 or 1, i.e., deferred backoff
% and CCA(最后CSMA停留在的状态只有0和1),0表示发送成功了，1表示在CCA时信道忙，停留在CCA状态
% 3.action is 0 or 1, stand for node choosing CSMA/CA to transsmit packet or not
% 4. last_TX_time record the last time a node send a packet successfullly
% 5.the initial channel state of TDMA part of each node is output
% 6.pkt loss and success and times of collisions are output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parameters initialization 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
global N Pbg Pgb CW CWmin CWmax UP UPnode M E_buff B_buff

%-----------参数---------------------------------------------------------
E_CCA = 0.015;   %信道检测消耗的能量
E_TX = 1;       %发送数据包需要的能量
Backoff_time = zeros(1,N); % temporal variable to record backoff time
ReTX_time = ReTX_time_pre;  %标记重传次数
CHN = 0; % channel state flag
ELE = zeros(1,N); %nodes' energy flag
ELE_ex = zeros(1,N); % 记录本超帧消耗的总能量
PKT = zeros(1,N); %nodes' packet buffer flag
lock_backoff = -1*ones(1,N); % deferred backoff should be output,defoult -1
last_TX_time = ones(1,N); % the last TX time of a node
Succ_TX_time = zeros(cap_length,N);  %记录节点每次成功发包的时间
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
        if ( (action(n)==0||action(n)==2) && (ELE(n)==0&&PKT(n)==0) )  %当节点选择RAP阶段传输数据,且有足够电磁和数据
            switch CSMA_sta(n)
                case 0 % 0 state for backoff
                    % initialize the backoff period of each node with initial state
                    % set to 0
                    if def_time_pre(n) == -1 %上一超帧中的backoff time 没有使用CSMA/CA传输数据或者传输完成了
                        Backoff_time(n) = randint(1,1,[1,CW(n)]);
                    else % nodes with defer 上一超帧中的backoff time有剩余
                        Backoff_time(n) = def_time_pre(n);
                        def_time_pre(n) = -1;
                    end           
                    CSMA_sta(n) = 1; % 进如退避状态

                case 1 % now start to check the backoff            
                    if(Backoff_time(n) == 0) %退避到0，进入发送状态
                          ELE_ex(n) = ELE_ex(n) + min(E_CCA,E_buff(n));  %消耗的能量累积记下
                          E_buff(n) = E_buff(n) - E_CCA;   %检测信道状态需要能量
                          if(E_buff(n)<0)
                              E_buff(n) = 0;
                              ELE(n) = 1;
                          end
                          if(CHN==1) % channel busy
                                %准备传输时如果信道忙碌则进入下一次重传。
                                PL_colli(n) = PL_colli(n) + 1;         %冲突次数加1
                                ReTX_time(n) = ReTX_time(n) + 1;                       
                                if(ReTX_time(n) >= M)           %达到最大重传次数，丢弃当前包
                                    pl_t(n) = pl_t(n) + 1;                %丢包次数加1
                                    ReTX_time(n) = 0;        %重传次数归0
                                    CW(n) = CWmin(find(UP==UPnode(n)));  %修改竞争窗口为节点对应优先级的CWmin 
                                    CSMA_sta(n) = 0;
                                else
                                    %修改竞争窗
                                    if (ReTX_time(n) > 0 && mod(ReTX_time(n),2) == 0)
                                        CW(n) = min(2*CW(n),CWmax(find(UP==UPnode(n))));
                                    end
                                    CSMA_sta(n) = 0;        %回到初始状态，重传
                                end
                         else % now it can be TX
                                CHNb_leng = floor( slot ) - floor ( last_TX_time(n) ); % last TX time is the time when a node finish last packet TX    时隙不为整数时，以其所在时隙的状态为准，即完全舍小数
                                CHN=1;  %设置信道为忙碌
                                [ PL_cap,PS_cap,last_CHN_sta(n), no_use(n)] = pktsend( CHNb_leng,0,last_CHN_sta(n),1,Pbg(n),Pgb(n)); % TX one packet, the channel state when the pkt is finished is recorded and used 
                                %如果发送成功则在当前时隙做标记
                                if(PS_cap>0)
                                    Succ_TX_time(slot,n) = 1;
                                end
                                %----------------修改buffer------------------                               
                                B_buff(n) = B_buff(n) - PS_cap;  %减少数据缓存区包数
                                if(B_buff(n)<0)
                                  B_buff(n) = 0;
                                  PKT(n) = 1;
                                end
                                E_buff(n) = E_buff(n) - E_TX;   %减少电容中能量数，假设发一个包消耗E_TX个单位能量，无论发送成功与否都将消耗
                                ELE_ex(n) = ELE_ex(n) + min(E_TX,E_buff(n));  %消耗的能量累积记下 
                                if(E_buff(n)<0)
                                  E_buff(n) = 0;
                                  ELE(n) = 1;
                                end
                                %------------------------------------------
                                pl_t(n) = pl_t(n) + PL_cap;  %在pktsend阶段丢包了也算进来
                                ps_t(n) = ps_t(n) + PS_cap;
                                CSMA_sta(n)=2; % when the TX is finished, update the channel condition
                          end
                    else %继续退避
                         ELE_ex(n) = ELE_ex(n) + min(E_CCA,E_buff(n));  %消耗的能量累积记下
                         E_buff(n) = E_buff(n) - E_CCA;   %检测信道状态需要0.1单位的能量                          
                         if(E_buff(n)<0)
                              E_buff(n) = 0;
                              ELE(n) = 1;
                         end
                         if(CHN==0) % 信道空闲才执行退避时间减1
                            Backoff_time(n) = Backoff_time(n) - 1;  %退避时间减1                    
                         end
                         if(slot == cap_length)
                           %如果当前时隙是最后一个时隙，则无法完成发送包的任务,退避时间锁定等到下一超帧再启动
                           lock_backoff(n) = Backoff_time(n);
                           CSMA_sta(n) = 0;  %返回初始状态
                         end
                    end      
  
                case 2 % finishing TX, update channel
                    CHN = 0;
                    last_TX_time(n) = slot;   %当前时隙成功发送了一个包
                    CW(n) = CWmin(find(UP==UPnode(n)));  %修改竞争窗口为节点对应优先级的CWmin 
                    CSMA_sta(n) = 0; % TX is succeed, restart the algorithm       
            end
        end
    end
    slot = slot + 1;  %下一个时隙
end
% include data collision to calculate the actual pkt loss
% 冲突会重传，增加延迟，不直接导致丢包，所以我们不把冲突次数加到丢包中
% pl_t = pl_t+PL_colli;
% ps_t = ps_t-PL_colli;

%------------求每个节点的相邻两次成功发包的平均间隔-------------------------------
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

