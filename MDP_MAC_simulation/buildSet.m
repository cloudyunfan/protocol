function d = buildSet(M,j)

d = cell(1,M-j+2);
for m=1:length(d)
   d{m}=j:j+m-2;
end
end