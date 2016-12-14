function data_acted=pre_actb(dataens)
%load('data_taikoo_t.mat')
%load('data_stk/s600000.mat')

%dataens=data_taikoo_total;
%dataens=s600000;

[loc_zero,~]=find(dataens(:,3)==0);
dataens(loc_zero,:)=[];
[dtx,~]=size(dataens);
data_acted=zeros(dtx-1,3);

for idx=1:dtx-1
  data_acted(idx,1)=dataens(dtx-idx,1)-dataens(dtx-idx+1,1);
  data_acted(idx,2)=dataens(dtx-idx,2);
%  if data_acted(idx,1)<0.01 && data_acted(idx,1)>0
%      data_acted(idx,1)=0;
%  end
  if data_acted(idx,1)>0
      data_acted(idx,3)=1;
  else
      if data_acted(idx,1)<0
          data_acted(idx,3)=0;
     else
          data_acted(idx,3)=round(rand(1,1));
      end
  end
end

std1=std(data_acted(:,1));

var2=var(data_acted(:,2));
mean2=sum(data_acted(:,2))/dtx-1;

theta2=var2/mean2;
k2=(mean2^2)/var2;

    %data_acted(idx,1)=normcdf(data_acted(idx,1),0,std1);
    %data_acted(idx,2)=gamcdf(data_acted(idx,2),k2,theta2);%±ß¼ÊÐ§ÓÃµÝ¼õ
    data_acted(1:dtx-1,1)=mapminmax(data_acted(1:dtx-1,1)',0,1)';
    data_acted(1:dtx-1,2)=mapminmax(abs(data_acted(1:dtx-1,2)'),0,1)';
    
end

