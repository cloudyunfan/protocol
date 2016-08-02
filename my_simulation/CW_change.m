function CWend = CW_change(R,k)
%��������˱ܽ׶εľ�������
% R: ReTX times
% k: UP
global CWmin CWmax
CW = zeros(1,R+1);
for r =1:R+1
      if(r==1)
         CW(r) = CWmin(k);   %0 backoff stage,��ʼ��Ϊ��С����
      else
          if(mod(r-1,2)==0)
             CW(r) = min( 2*CW(r-1),CWmax(k) );   %ż�����ش������ڷ���
          else
              CW(r) = CW(r-1);   %�������ش����ڲ���
          end
      end
end
CWend = CW(end);
end