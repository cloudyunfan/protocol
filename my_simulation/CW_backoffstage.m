function CW = CW_backoffstage(CWmin,CWmax,R,K)
%��������˱ܽ׶εľ�������
CW = zeros(R+1,K);
for r =1:R+1
   for k=1:K
      if(r==1)
         CW(r,k) = CWmin(k);   %0 backoff stage,��ʼ��Ϊ��С����
      else
          if(mod(r-1,2)==0)
             CW(r,k) = min( 2*CW(r-1,k),CWmax(k) );   %ż�����ش������ڷ���
          else
              CW(r,k) = CW(r-1,k);   %�������ش����ڲ���
          end
      end
   end    
end

end