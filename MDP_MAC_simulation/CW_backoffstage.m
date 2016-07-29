function CW = CW_backoffstage(CWmin,CWmax,R,K)
%计算各个退避阶段的竞争窗口
CW = zeros(R+1,K);
for r =1:R+1
   for k=1:K
      if(r==1)
         CW(r,k) = CWmin(k);   %0 backoff stage,初始化为最小窗口
      else
          if(mod(r-1,2)==0)
             CW(r,k) = min( 2*CW(r-1,k),CWmax(k) );   %偶数次重传，窗口翻倍
          else
              CW(r,k) = CW(r-1,k);   %奇数次重传窗口不变
          end
      end
   end    
end

end