function his10=lire_histoire(histoire)
lgh_histoire=length(histoire);
his2=0;
for idx=1:lgh_histoire
    his2=his2+histoire(idx)*10^(lgh_histoire-idx);
end
his10=bin2dec(num2str(his2))+1;
end