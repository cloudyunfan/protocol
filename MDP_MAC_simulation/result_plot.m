function new_para = result_plot(para)
global UP
for up =1:length(UP)
    ind = find(para(up,:)~=0);
    new_para(up,:) = para(up,ind);
end