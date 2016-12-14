%teste_setcommun
clear all
[filename, pathname] = uigetfile('*.csv', 'MultiSelect', 'on');
num_file=length(filename);
lgh_histoire=3;
for idf=1:num_file 
    disp(char(strcat('File name:',filename(idf))))
    disp(char(strcat('File number:',num2str(idf))))  
    xc=csvread(char(strcat('data_stk/',filename(idf))),1,3);
    data_actedi=pre_actb(xc);
    data_actedi=data_actedi(1:503,:);
    num_testfois=100;
    
    res_fn1=zeros(400,100);
    res_fn2=zeros(1,400);
    num_agent=31;
    num_agent_demi=num_agent./2;

          res_gen=zeros(400,100,num_testfois);  
    parfor idtt=1:num_testfois
        res_genb=zeros(400,100);  
        res_gene=zeros(400,100);%训练长度，预测位点，agent个数
        for idttt=1:500 %开始位点
            data_acted=data_actedi(idttt:end,:);
            [dlghx,~]=size(data_acted);
            his_mac_gen=data_acted(1:end,3)';
            his_mic_gen=ceil(data_acted(1:end,1).*num_agent)';
            [~,jour]=size(his_mac_gen);%交易天数


            num_histoire=2^lgh_histoire;%历史记录数量
            accur=zeros(1,num_testfois);%存储试验精度
            choix_actuel=zeros(jour,1); %根据真实数据推断的选择,存储每日选1（买入）的agent数量
            res_actuel=zeros(jour,1); %真实数据每日涨跌情况
            strategie=zeros(1,num_agent,num_histoire);%存储每个agent用以操作（选1）的概率，二项分布参数
            multi=zeros(2,num_agent); %存储用于分配choix_actuel到agent的多项分布row 1，及命中情况row 2
            choix_agent=zeros(1,num_agent); %存储每个agent的选择情况
            choix_mic_predicte=zeros(num_testfois,jour-3);%存储预测情况
            choix_mac_predicte=zeros(num_testfois,jour-3);%存储预测情况
            
            for idx=1:jour%计算每日选择情况
                choix_actuel(idx)=his_mic_gen(idx);
            end
            for idx=1:jour%计算每日涨跌情况
                res_actuel(idx)=his_mac_gen(idx);
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
                his_ajd=lire_histoire(his_ajd2);

                %从此开始训练操作
                if idttt+idt-1>=404 && idt-3<=400 %如果在允许测试区域内，开放选择，记录结果
 
                    choix_agent1=zeros(1,num_agent); %存储每个agent的选择情况
                    %利用现有策略生成一个值
                    
                    for idg=1:num_agent
                        choix_agent1(idg)=binornd(1,strategie(1,idg,his_ajd));
                    end
                    
                

                    
           
                    idrga=idt-3; %训练长度
                    idrgb=idttt+idt-1-403; %实际对应测试集天数序号
                    idrgc=idtt;
                    
                    res_genb(idrga,idrgb)=sum(choix_agent1)/num_agent;
                    res_gene(idrga,idrgb)=res_actuel(idt); %实际选择


                end
                choix_agent=zeros(1,num_agent); %存储每个agent的选择情况

                sum_strategie=sum(strategie(1,:,his_ajd)); %当前历史对应的二项分布参数和

                for idx=1:num_agent %初始化当前用于分配choix的多项分布
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
                for ida=1:num_agent
                    strategie_pr(1,ida,his_ajd)=strategie_pr(1,ida,his_ajd)+choix_agent(ida);
                    strategie_pr(2,ida,his_ajd)=strategie_pr(2,ida,his_ajd)+1-choix_agent(ida);
                end
                for idx=1:num_agent %根据更正的先验更新策略
                    strategie(1,idx,his_ajd)=(strategie_pr(1,idx,his_ajd))/(strategie_pr(1,idx,his_ajd)+strategie_pr(2,idx,his_ajd));%通过期望法生成策略
                end
                %从此结束训练操作
                
            end
        end
    res_gen(:,:,idtt)=res_genb;
    end
            res_genc=zeros(400,100);
            for idxx=1:400
                for idxy=1:100;
                    res_genc(idxx,idxy)=sum(res_gen(idxx,idxy,:))/num_testfois;
                end
            end

    save(char(strcat('test_result_set_commun_mpmx_prop_num_agt/',filename(idf),'.mat')),'res_gen')
end