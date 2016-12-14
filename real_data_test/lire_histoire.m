function his10=lire_histoire(histoire)
lgh_histoire=length(histoire);
his2=0;
for idx=1:lgh_histoire
    his2=his2+histoire(lgh_histoire-idx+1)*2^(idx-1);
end
his10=his2+1;
end