%smart_agent convolutionary algorithim.
function [res_gen,var_gen,res_gen1]=simulation_ga(strategie,his_ajd,choix_ncd,num_testfois)
num_agent=81;
%num_testfois=1000;
choix_agent=zeros(num_testfois,81);

%sreategie_proba=ones(1,24).*0.5;
%strategie=[0.1 0.25 0.25 0.4 sreategie_proba];
%his_ajd=[0;0;1];
%choix_ncd=1;
res_gen1=zeros(1,num_testfois);
prop_agent=round(strategie(1:4).*num_agent);
while sum(prop_agent)>81
    [~,pos]=max(prop_agent);
    prop_agent(pos(1))=prop_agent(pos(1))-1;
end
while sum(prop_agent)<81
    [~,pos]=min(prop_agent);
    prop_agent(pos(1))=prop_agent(pos(1))+1;
end

for testfois=1:num_testfois
    for idx=1:4
        his_ajd2=lire_histoire(his_ajd);
        if  prop_agent(idx)~=0
            for idg=1:prop_agent(idx)
                if idx==1 %对于随机组
                    choix_agent(testfois,idg)=round(rand(1,1));
                end
                if idx==2 %对于策略1组
                    choix_agent(testfois,prop_agent(1)+idg)=binornd(1,strategie(4+his_ajd2));
                end
                if idx==3 %对于策略2组
                    choix_agent(testfois,sum(prop_agent(1:2))+idg)=binornd(1,strategie(12+his_ajd2));
                end
                if idx==4 %对于策略3组
                    choix_agent(testfois,sum(prop_agent(1:3))+idg)=binornd(1,strategie(20+his_ajd2));
                end
                
            end
        end
    end
end

for idx=1:num_testfois
 
    res_gen1(idx)=sum(choix_agent(idx,:))/81;%选取比例

end
res_gen=sum(res_gen1)/num_testfois;
var_gen=var(res_gen1);