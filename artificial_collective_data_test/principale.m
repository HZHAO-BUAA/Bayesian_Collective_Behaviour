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
choix_mic_predicte=zeros(num_testfois,300);%�洢Ԥ�����
choix_mac_predicte=zeros(num_testfois,300);%�洢Ԥ�����


for idtt=1:num_testfois
    idtt
if rem(idtt,20)==1 
[his_mac_gen,his_mic_gen]=gene_strategie(ab,lgh_histoire); %������������
end
[~,jour]=size(his_mac_gen);%��������


num_histoire=2^lgh_histoire;%��ʷ��¼����
accur=zeros(1,num_testfois);%�洢���龫��
choix_actuel=zeros(jour,1); %������ʵ�����ƶϵ�ѡ��,�洢ÿ��ѡ1�����룩��agent����
choix_prop_actuel=zeros(num_agent,jour);%agent������ʷ
res_actuel=zeros(jour,1); %��ʵ����ÿ���ǵ����
strategie_pr=zeros(2,num_agent,num_histoire);%�洢ÿ��agent����ȷ�����Ե�beta����ֲ�
strategie=zeros(1,num_agent,num_histoire);%�洢ÿ��agent���Բ�����ѡ1���ĸ��ʣ�����ֲ�����
multi=zeros(2,num_agent); %�洢���ڷ���choix_actuel��agent�Ķ���ֲ�row 1�����������row 2
choix_agent=zeros(1,num_agent); %�洢ÿ��agent��ѡ�����

for idx=1:jour%����ÿ��ѡ�����
    choix_actuel(idx)=his_mic_gen(idx);
end
for idx=1:jour%����ÿ���ǵ����
    res_actuel(idx)=his_mac_gen(idx);
end
for idx=1:lgh_histoire %��ʼ��ǰ��������ʷ
    agt_idx=randperm(num_agent);
    count_agt=1;
    while count_agt<=num_agent
        if count_agt<=choix_actuel(idx)
            if  choix_actuel(idx)>num_agent/2%ϵ������
                choix_prop_actuel(agt_idx(count_agt),idx)=0;
            else
                choix_prop_actuel(agt_idx(count_agt),idx)=1;
            end
        else
            if  choix_actuel(idx)>num_agent/2%ϵ������
                choix_prop_actuel(agt_idx(count_agt),idx)=1;
            else
                choix_prop_actuel(agt_idx(count_agt),idx)=0;
            end
        end
        count_agt=count_agt+1;
    end
end


strategie_pr=zeros(2,num_agent,num_histoire)+0.9;%ͨ������������
for idx=1:num_agent
    for idh=1:num_histoire %��ʼ������
    strategie(1,idx,idh)=betarnd(strategie_pr(1,idx,idh),strategie_pr(2,idx,idh));
    end
end
%ѵ������
for idt=lgh_histoire+1:jour%����ÿһ��ѵ����
his_ajd2=res_actuel(idt-lgh_histoire:idt-1);%�洢���ն�Ӧ����ʷ
his_ajd_p=choix_prop_actuel(:,idt-lgh_histoire:idt-1);


choix_agent=zeros(1,num_agent); %�洢ÿ��agent��ѡ�����
%�������в�������һ��ֵ
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
    
%���ù۲���ʷ��������
choix_agent=zeros(1,num_agent); %�洢ÿ��agent��ѡ�����

sum_strategie=0;

for idg=1:num_agent
        his_ajd=lire_histoire(his_ajd_p(idg,:));
        sum_strategie=sum_strategie+strategie(1,idg,his_ajd); %��ǰ��ʷ��Ӧ�Ķ���ֲ�������
end

for idx=1:num_agent %��ʼ����ǰ���ڷ���choix�Ķ���ֲ�

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
while sum(multi(2,:))<choix_actuel(idt)%����δ������
      [~,tyy]=find(multi(1,:)>=rand(1,1));
      if multi(2,tyy(1))==0
         choix_agent(tyy(1))=1;
        multi(2,tyy(1))=1;
      end

end
multi(2,:)=zeros(1,num_agent);%����ֲ��������
end

%��������ʷ
for idg=1:num_agent
    if choix_agent(idg)==1 && choix_actuel(idt)>num_agent/2%������
        choix_prop_actuel(idg,idt)=0;
    end
    if choix_agent(idg)==1 && choix_actuel(idt)<num_agent/2%������
        choix_prop_actuel(idg,idt)=1;
    end
    if choix_agent(idg)==0 && choix_actuel(idt)>num_agent/2%������
        choix_prop_actuel(idg,idt)=1;
    end
    if choix_agent(idg)==0 && choix_actuel(idt)<num_agent/2%������
        choix_prop_actuel(idg,idt)=0;
    end
end

%����ѡ���������ÿ��agent������
for ida=1:num_agent
    his_ajd=lire_histoire(his_ajd_p(ida,:));
    strategie_pr(1,ida,his_ajd)=strategie_pr(1,ida,his_ajd)+choix_agent(ida);
    strategie_pr(2,ida,his_ajd)=strategie_pr(2,ida,his_ajd)+1-choix_agent(ida);
end
for idx=1:num_agent %���ݸ�����������²���
   his_ajd=lire_histoire(his_ajd_p(idx,:));
   strategie(1,idx,his_ajd)=(strategie_pr(1,idx,his_ajd))/(strategie_pr(1,idx,his_ajd)+strategie_pr(2,idx,his_ajd));%ͨ�����������ɲ���
end


end


end
res_gen(1:lgh_histoire)=[];
res_emsemble(idab,:)=res_gen;
end

