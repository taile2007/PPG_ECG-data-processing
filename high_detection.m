function output=high_detection(input,n)

high =zeros(length(input)-2*n,1);
% tao mang zero 
for i=1:length(input)-2*n
    window_max= max(input(i:i+2*n));% tim max trong tung ham 
    window_max_position= find(input(i:i+2*n)==window_max);  % tim ra 1 mang cac vi tri cua phan tu lon nhat trong mang
    if length(window_max_position)==1   % neu trong doan xet do chi co 1 diem max
        if  input(i+n)==window_max    %neu phan tu 
            high_index=i+n;  % luu vi tri vi tri cua phan tu max
        else
            high_index=0;   % neu khong co phan tu nao 
        end
    else
        if input(i+n)==window_max % phan tu thu i+n cua mang dau vao co gia tri bang phan tu max
            high_index=i+min(window_max_position)-1; % 
        else
            high_index=0;
        end
    end
    high(i) = high_index;
end
high(high==0)=[];
high(input(high)==0)=[];
high=unique(high);
output=high;
