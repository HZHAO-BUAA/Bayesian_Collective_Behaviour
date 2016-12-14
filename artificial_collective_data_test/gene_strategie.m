function [his_mac_gen,his_mic_gen,his_prop_gen]=gene_strategie(ab,lgh_his)
%artificial data generator
size_gen=300;
num_agent=31;
%ab=0.5;
%lgh_his=3;
strategie=zeros(2^lgh_his,num_agent);
choix=zeros(1,num_agent);
his_mic_gen=zeros(1,size_gen+lgh_his);
his_prop_gen=zeros(num_agent,size_gen+lgh_his);
his_mac_gen=zeros(1,size_gen+lgh_his);

for idy=1:2^lgh_his

for idx=1:num_agent
    strategie(idy,idx)=betarnd(ab,ab);
end
end

for idx=1:lgh_his %随机生成前三个历史
    his_mic_gen(idx)=round(rand(1,1)*num_agent);
    agt_idx=randperm(num_agent);
    count_agt=1;
    while count_agt<=num_agent
        if count_agt<=his_mic_gen(idx)
            if  his_mic_gen(idx)>num_agent/2%系多数派
                his_prop_gen(agt_idx(count_agt),idx)=0;
            else
                his_prop_gen(agt_idx(count_agt),idx)=1;
            end
        else
            if  his_mic_gen(idx)>num_agent/2%系多数派
                his_prop_gen(agt_idx(count_agt),idx)=1;
            else
                his_prop_gen(agt_idx(count_agt),idx)=0;
            end
        end
        count_agt=count_agt+1;
    end
    if  his_mic_gen(idx)>num_agent/2
        his_mac_gen(idx)=1;
    else
        his_mac_gen(idx)=0;
    end
end



for idx=1:size_gen
    for idg=1:num_agent
        choix(idg)=binornd(1,strategie(lire_histoire(his_prop_gen(idg,idx:idx+lgh_his-1)),idg));
    end
        his_mic_gen(idx+lgh_his)=sum(choix);
    if  his_mic_gen(idx+lgh_his)>num_agent/2
        his_mac_gen(idx+lgh_his)=1;
    else
        his_mac_gen(idx+lgh_his)=0;
    end
    for idg=1:num_agent
        if choix(idg)~=his_mac_gen(idx+lgh_his) %minority side
            his_prop_gen(idg,idx+lgh_his)=1;
        else
            his_prop_gen(idg,idx+lgh_his)=0;%majority side
        end
    end
end
