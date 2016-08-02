function CWend = CW_change(R,k)
%计算各个退避阶段的竞争窗口
% R: ReTX times
% k: UP
global CWmin CWmax
CW = zeros(1,R+1);
for r =1:R+1
      if(r==1)
         CW(r) = CWmin(k);   %0 backoff stage,初始化为最小窗口
      else
          if(mod(r-1,2)==0)
             CW(r) = min( 2*CW(r-1),CWmax(k) );   %偶数次重传，窗口翻倍
          else
              CW(r) = CW(r-1);   %奇数次重传窗口不变
          end
      end
end
CWend = CW(end);
end