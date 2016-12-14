%smart_agent convolutionary algorithim.
function [res_gen]=simulation_ga_simple(strategie,his_ajd,choix_ncd)
num_agent=81;
%num_testfois=1000;


%sreategie_proba=ones(1,24).*0.5;
%strategie=[0.1 0.25 0.25 0.4 sreategie_proba];
%his_ajd=[0;0;1];
%choix_ncd=1;

prop_agent=round(strategie(1:4).*num_agent);
while sum(prop_agent)>81
    [~,pos]=max(prop_agent);
    prop_agent(pos(1))=prop_agent(pos(1))-1;
end
while sum(prop_agent)<81
    [~,pos]=min(prop_agent);
    prop_agent(pos(1))=prop_agent(pos(1))+1;
end
res_gen=0;

    for idx=1:4
        his_ajd2=lire_histoire(his_ajd);
        if idx==1
        res_gen=prop_agent(idx)*0.5;
        else
            res_gen=res_gen+prop_agent(idx)*strategie(4+his_ajd2+8*(idx-2));
        end


    end
        res_gen=res_gen/81;
        if choix_ncd==0
            res_gen=1-res_gen;
        end



