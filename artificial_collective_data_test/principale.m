clear all
%load('artificial_test_full.mat')
accur_stable=zeros(20,1);
plotx=zeros(20,1);
%idx_idab=[0.01,0.05,0.1,0.15,0.2,0.5,1,1.5,2,5,100];
idx_idab=[100];
[~,num_idab]=size(idx_idab);
res_emsemble=zeros(num_idab,300);
for idab=1:num_idab;
ab=idx_idab(idab);
plotx(idab)=ab;
lgh_histoire=3;
res_gen=zeros(1,300+lgh_histoire);
num_agent=31;
num_agent_demi=num_agent./2;
num_testfois=1;
choix_mic_predicte=zeros(num_testfois,300);%存储预测情况
choix_mac_predicte=zeros(num_testfois,300);%存储预测情况


for idtt=1:num_testfois
    idtt
if rem(idtt,20)==1 
[his_mac_gen,his_mic_gen]=gene_strategie(ab,lgh_histoire); %生成所需数据
end
[~,jour]=size(his_mac_gen);%交易天数


num_histoire=2^lgh_histoire;%历史记录数量
accur=zeros(1,num_testfois);%存储试验精度
choix_actuel=zeros(jour,1); %根据真实数据推断的选择,存储每日选1（买入）的agent数量
choix_prop_actuel=zeros(num_agent,jour);%agent的自历史
res_actuel=zeros(jour,1); %真实数据每日涨跌情况
strategie_pr=zeros(2,num_agent,num_histoire);%存储每个agent用以确定策略的beta先验分布
strategie=zeros(1,num_agent,num_histoire);%存储每个agent用以操作（选1）的概率，二项分布参数
multi=zeros(2,num_agent); %存储用于分配choix_actuel到agent的多项分布row 1，及命中情况row 2
choix_agent=zeros(1,num_agent); %存储每个agent的选择情况

for idx=1:jour%计算每日选择情况
    choix_actuel(idx)=his_mic_gen(idx);
end
for idx=1:jour%计算每日涨跌情况
    res_actuel(idx)=his_mac_gen(idx);
end
for idx=1:lgh_histoire %初始化前三个自历史
    agt_idx=randperm(num_agent);
    count_agt=1;
    while count_agt<=num_agent
        if count_agt<=choix_actuel(idx)
            if  choix_actuel(idx)>num_agent/2%系多数派
                choix_prop_actuel(agt_idx(count_agt),idx)=0;
            else
                choix_prop_actuel(agt_idx(count_agt),idx)=1;
            end
        else
            if  choix_actuel(idx)>num_agent/2%系多数派
                choix_prop_actuel(agt_idx(count_agt),idx)=1;
            else
                choix_prop_actuel(agt_idx(count_agt),idx)=0;
            end
        end
        count_agt=count_agt+1;
    end
end


strategie_pr=zeros(2,num_agent,num_histoire)+0.9;%通过常数法生成
for idx=1:num_agent
    for idh=1:num_histoire %初始化策略
    strategie(1,idx,idh)=betarnd(strategie_pr(1,idx,idh),strategie_pr(2,idx,idh));
    end
end
%训练过程
for idt=lgh_histoire+1:jour%对于每一个训练日
his_ajd2=res_actuel(idt-lgh_histoire:idt-1);%存储当日对应的历史
his_ajd_p=choix_prop_actuel(:,idt-lgh_histoire:idt-1);


choix_agent=zeros(1,num_agent); %存储每个agent的选择情况
%利用现有策略生成一个值
    for idg=1:num_agent
        his_ajd=lire_histoire(his_ajd_p(idg,:));
        choix_agent(idg)=binornd(1,strategie(1,idg,his_ajd));
    end
       % choix_mic_predicte(idtt,idt)=sum(choix_agent);
    if  sum(choix_agent)>num_agent/2
        flag=1;
        choix_mac_predicte(idtt,idt)=1;
    else
        flag=0;
        choix_mac_predicte(idtt,idt)=0;
    end
    
if flag==res_actuel(idt)
        res_gen(idt)=res_gen(idt)+1/num_testfois;
end    
    
%利用观测历史修正策略
choix_agent=zeros(1,num_agent); %存储每个agent的选择情况

sum_strategie=0;

for idg=1:num_agent
        his_ajd=lire_histoire(his_ajd_p(idg,:));
        sum_strategie=sum_strategie+strategie(1,idg,his_ajd); %当前历史对应的二项分布参数和
end

for idx=1:num_agent %初始化当前用于分配choix的多项分布

    his_ajd=lire_histoire(his_ajd_p(idx,:));
    if idx==1
        multi(1,idx)=strategie(1,idx,his_ajd)./sum_strategie;
    else
        multi(1,idx)=multi(1,idx-1)+strategie(1,idx,his_ajd)./sum_strategie;
    end
end


if choix_actuel(idt)==num_agent
    choix_agent=ones(1,num_agent);
else
while sum(multi(2,:))<choix_actuel(idt)%若尚未分配完
      [~,tyy]=find(multi(1,:)>=rand(1,1));
      if multi(2,tyy(1))==0
         choix_agent(tyy(1))=1;
        multi(2,tyy(1))=1;
      end

end
multi(2,:)=zeros(1,num_agent);%分配分布矩阵归零
end

%更新自历史
for idg=1:num_agent
    if choix_agent(idg)==1 && choix_actuel(idt)>num_agent/2%多数派
        choix_prop_actuel(idg,idt)=0;
    end
    if choix_agent(idg)==1 && choix_actuel(idt)<num_agent/2%少数派
        choix_prop_actuel(idg,idt)=1;
    end
    if choix_agent(idg)==0 && choix_actuel(idt)>num_agent/2%多数派
        choix_prop_actuel(idg,idt)=1;
    end
    if choix_agent(idg)==0 && choix_actuel(idt)<num_agent/2%少数派
        choix_prop_actuel(idg,idt)=0;
    end
end

%根据选择情况更新每个agent的先验
for ida=1:num_agent
    his_ajd=lire_histoire(his_ajd_p(ida,:));
    strategie_pr(1,ida,his_ajd)=strategie_pr(1,ida,his_ajd)+choix_agent(ida);
    strategie_pr(2,ida,his_ajd)=strategie_pr(2,ida,his_ajd)+1-choix_agent(ida);
end
for idx=1:num_agent %根据更正的先验更新策略
   his_ajd=lire_histoire(his_ajd_p(idx,:));
   strategie(1,idx,his_ajd)=(strategie_pr(1,idx,his_ajd))/(strategie_pr(1,idx,his_ajd)+strategie_pr(2,idx,his_ajd));%通过期望法生成策略
end


end


end
res_gen(1:lgh_histoire)=[];
res_emsemble(idab,:)=res_gen;
end

