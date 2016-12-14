function y=obj_gatest(data,x)
his_lgh=length(data);
accur=zeros(1,his_lgh-3);
for idx=4:his_lgh

    [accur_mic]=simulation_ga_simple(x,data(idx-3:idx-1),data(idx));
    accur(idx-3)=accur_mic;
end
y=-sum(accur)/(his_lgh-3);
end