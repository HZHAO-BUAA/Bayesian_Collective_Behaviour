%roc_analysis
clear all
mpmx_re=load('test_result_set_commun_mpmx_prop_num_agt/600900.csv.mat');
ga_re=load('test_result_set_commun_ga_prop_num_agt_bf/600900.csv.mat');

load('test_result_set_commun_ga_prop_num_agt/gene.mat')
cher_idx=[1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100,150,200,250,300,350,400];
res_auc=zeros(2,length(cher_idx));
for idp=1:length(cher_idx)
threshold=0.5;
consi_trn=cher_idx(idp);
mpmx_re.res_bin=zeros(400,100);
ga_re.res_bin=zeros(400,100);
mpmx_re.res_avg=zeros(400,1);
ga_re.res_avg=zeros(400,1);
mpmx_re.res_genc=zeros(400,100);
ga_re.res_genc=zeros(400,100);

for idx=1:400
    for idy=1:100
        mpmx_re.res_genc(idx,idy)=sum(mpmx_re.res_gen(idx,idy,:))/100;
        ga_re.res_genc(idx,idy)=sum(ga_re.res_gen(idx,idy,:))/10;
    end
end

for idx=1:400
    for idy=1:100
        if mpmx_re.res_genc(idx,idy)>threshold && res_gene(1,idy)==1
            mpmx_re.res_bin(idx,idy)=1;
        end
        if mpmx_re.res_genc(idx,idy)<threshold && res_gene(1,idy)==0
            mpmx_re.res_bin(idx,idy)=1;
        end
    end
end

for idx=1:400
    for idy=1:100
        if ga_re.res_genc(idx,idy)>threshold && res_gene(1,idy)==1
            ga_re.res_bin(idx,idy)=1;
        end
        if ga_re.res_genc(idx,idy)<threshold && res_gene(1,idy)==0
            ga_re.res_bin(idx,idy)=1;
        end
    end
end
%for idx=1:400
%    mpmx_re.res_avg(idx)=sum(mpmx_re.res_bin(idx,:))/100;
%    ga_re.res_avg(idx)=sum(ga_re.res_bin(idx,:))/100;
%end
targets=res_gene(1,:);
outputs=mpmx_re.res_genc(consi_trn,:);

res_auc(1,idp)=AUC(targets,outputs);

targets=res_gene(1,:);
outputs=ga_re.res_genc(consi_trn,:);
res_auc(2,idp)=AUC(targets,outputs);
end

plot(res_auc','DisplayName','res_auc')
[max11,max12]=max(res_auc(1,:)); %mpmx
max12=cher_idx(max12);
[max21,max22]=max(res_auc(2,:)); %ga
max22=cher_idx(max22);
