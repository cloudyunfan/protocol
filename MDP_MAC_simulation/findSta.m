function ind = findSta(S,b,e,g)
%я╟урв╢л╛╣доб╠Й
ind = zeros(1,length(b));
str = 'error';
for j =1: length(b)
    for i=1:length(S)
        if( (S{i}(1)==b(j)) && (S{i}(2)==e(j))&&S{i}(3)==g )        
            str = 'success';
            break;
        end    
    end
    ind(j) = i;
end
end %function end