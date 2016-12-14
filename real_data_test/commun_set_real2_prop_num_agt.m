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
        res_gene=zeros(400,100);%ѵ�����ȣ�Ԥ��λ�㣬agent����
        for idttt=1:500 %��ʼλ��
            data_acted=data_actedi(idttt:end,:);
            [dlghx,~]=size(data_acted);
            his_mac_gen=data_acted(1:end,3)';
            his_mic_gen=ceil(data_acted(1:end,1).*num_agent)';
            [~,jour]=size(his_mac_gen);%��������


            num_histoire=2^lgh_histoire;%��ʷ��¼����
            accur=zeros(1,num_testfois);%�洢���龫��
            choix_actuel=zeros(jour,1); %������ʵ�����ƶϵ�ѡ��,�洢ÿ��ѡ1�����룩��agent����
            res_actuel=zeros(jour,1); %��ʵ����ÿ���ǵ����
            strategie=zeros(1,num_agent,num_histoire);%�洢ÿ��agent���Բ�����ѡ1���ĸ��ʣ�����ֲ�����
            multi=zeros(2,num_agent); %�洢���ڷ���choix_actuel��agent�Ķ���ֲ�row 1�����������row 2
            choix_agent=zeros(1,num_agent); %�洢ÿ��agent��ѡ�����
            choix_mic_predicte=zeros(num_testfois,jour-3);%�洢Ԥ�����
            choix_mac_predicte=zeros(num_testfois,jour-3);%�洢Ԥ�����
            
            for idx=1:jour%����ÿ��ѡ�����
                choix_actuel(idx)=his_mic_gen(idx);
            end
            for idx=1:jour%����ÿ���ǵ����
                res_actuel(idx)=his_mac_gen(idx);
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
                his_ajd=lire_histoire(his_ajd2);

                %�Ӵ˿�ʼѵ������
                if idttt+idt-1>=404 && idt-3<=400 %�����������������ڣ�����ѡ�񣬼�¼���
 
                    choix_agent1=zeros(1,num_agent); %�洢ÿ��agent��ѡ�����
                    %�������в�������һ��ֵ
                    
                    for idg=1:num_agent
                        choix_agent1(idg)=binornd(1,strategie(1,idg,his_ajd));
                    end
                    
                

                    
           
                    idrga=idt-3; %ѵ������
                    idrgb=idttt+idt-1-403; %ʵ�ʶ�Ӧ���Լ��������
                    idrgc=idtt;
                    
                    res_genb(idrga,idrgb)=sum(choix_agent1)/num_agent;
                    res_gene(idrga,idrgb)=res_actuel(idt); %ʵ��ѡ��


                end
                choix_agent=zeros(1,num_agent); %�洢ÿ��agent��ѡ�����

                sum_strategie=sum(strategie(1,:,his_ajd)); %��ǰ��ʷ��Ӧ�Ķ���ֲ�������

                for idx=1:num_agent %��ʼ����ǰ���ڷ���choix�Ķ���ֲ�
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
                for ida=1:num_agent
                    strategie_pr(1,ida,his_ajd)=strategie_pr(1,ida,his_ajd)+choix_agent(ida);
                    strategie_pr(2,ida,his_ajd)=strategie_pr(2,ida,his_ajd)+1-choix_agent(ida);
                end
                for idx=1:num_agent %���ݸ�����������²���
                    strategie(1,idx,his_ajd)=(strategie_pr(1,idx,his_ajd))/(strategie_pr(1,idx,his_ajd)+strategie_pr(2,idx,his_ajd));%ͨ�����������ɲ���
                end
                %�Ӵ˽���ѵ������
                
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