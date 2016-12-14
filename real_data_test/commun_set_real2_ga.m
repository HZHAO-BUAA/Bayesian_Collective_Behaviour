%smart_agent convolutionary algorithim.
clear all
[filename, pathname] = uigetfile('*.csv', 'MultiSelect', 'on');
num_file=length(filename);
lgh_histoire=3;
cons_ga1=zeros(25,28);
cons_gaeq=zeros(1,28);
cons_gaeq(1,1:4)=1;
cons_gaeqb=1;
cons_ga1b=ones(25,1);
cons_ga1b(1)=0.5;
cons_ga1(1,1)=1;
for idx=1:24
    cons_ga1(1+idx,4+idx)=1;
end
cons_galb=zeros(28,1);
cons_gaub=ones(28,1);
ga_options = gaoptimset('CrossoverFraction',0.7,'PopulationSize',10,'Generations',50,'TimeLimit',10);
num_testfois=10;
big_num_testfois=10;
for idf=1:num_file 
    disp(char(strcat('File name:',filename(idf))))
    disp(char(strcat('File number:',num2str(idf))))  
    xc=csvread(char(strcat('data_stk/',filename(idf))),1,3);
    data_actedi=pre_actb(xc);
    data_actedi=data_actedi(1:503,:);

    res_gen=zeros(400,100,big_num_testfois);%训练长度，预测位点，重复次数
    res_fn1=zeros(400,100);
    res_fn2=zeros(1,400);
    num_agent=31;
    num_agent_demi=num_agent./2;

    

    parfor idp=1:big_num_testfois
            res_tmp_gen=zeros(400,100);
        for idttt=1:500 %开始位点
            data_acted=data_actedi(idttt:end,:);
            his_mac_gen=data_acted(1:end,3)';
            his_mic_gen=ceil(data_acted(1:end,1).*num_agent)';
            [~,jour]=size(his_mac_gen);%交易天数
            
%sreategie_proba=ones(1,24).*0.5;
%strategie=[0.1 0.25 0.25 0.4 sreategie_proba];

            num_histoire=2^lgh_histoire;%历史记录数量
            choix_actuel=zeros(jour,1); %根据真实数据推断的选择,存储每日选1（买入）的agent数量
            res_actuel=zeros(jour,1); %真实数据每日涨跌情况
            choix_mic_predicte=zeros(num_testfois,jour-3);%存储预测情况
            choix_mac_predicte=zeros(num_testfois,jour-3);%存储预测情况
            for idx=1:jour%计算每日涨跌情况
                res_actuel(idx)=his_mac_gen(idx);
            end


  
%训练过程

            count=0;
            cher_idx=[];
            for idg=max(405-idttt,4):min(404,504-idttt)
                  if idg-1>=1 && idg-3<=10
                      cher_idx(count+1)=idg;
                      count=count+1;
                  end
                  if idg-3>11 && idg-3<=100 && rem(idg-3,10)==0
                      cher_idx(count+1)=idg;
                      count=count+1;
                  end
                  if idg-3>101 && idg-3<=400 && rem(idg-3,50)==0
                      cher_idx(count+1)=idg;
                      count=count+1;
                  end
            end
            cher_range=length(cher_idx);
            for idc=1:cher_range%对于每一个训练日
                idt=cher_idx(idc);

                
                if idttt+idt-1>=404 && idt-3<=400 && idttt+idt-1<=503 %如果进入测试区域
                    his_ajd2=res_actuel(idt-lgh_histoire:idt-1);%存储当日对应的历史
                    his_ajd=lire_histoire(his_ajd2);
                    choix_agent1=zeros(1,num_agent); %存储每个agent的选择情况
                    his_train=res_actuel(1:idt-1);



  
                    if idt-1<3
                    sreategie_proba=ones(1,24).*0.5;
                    strategie=[0.1 0.25 0.25 0.4 sreategie_proba]; 
                    else
                    strategie=ga(@(strategie) obj_gatest(his_train,strategie),28,cons_ga1,cons_ga1b,cons_gaeq,cons_gaeqb,cons_galb,cons_gaub,[],ga_options);
                    end


                    [accur,var,detail]=simulation_ga(strategie,his_ajd2,res_actuel(idt),num_testfois);
                    idrga=idt-3;
                    idrgb=idttt+idt-1-403;
                    res_tmp_gen(idrga,idrgb)=sum(detail)/num_testfois;
                end

                
            end
            

        end
        res_gen(:,:,idp)=res_tmp_gen;
    end

    save(char(strcat('test_result_set_commun_ga_prop_num_agt/',filename(idf),'.mat')),'res_gen')
end