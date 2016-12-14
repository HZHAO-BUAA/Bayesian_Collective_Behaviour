idx_idab=[0.01,0.05,0.1,0.15,0.2,0.5,1,1.5,2,5];
idx_range=length(idx_idab);
load('res_ens_20002.mat')
ploty=zeros(1,idx_range);
for idx=1:idx_range
ax=idx_idab(idx);
idx_var(idx)=ax^2/(((ax+ax)^2)*(ax+ax+1));
ploty(idx)=sum(res_emsemble(idx,201:300))/100;
end
plot(idx_var,ploty,'-k','linewidth',2)
xlabel('Variance of Selective Probability')
ylabel('Accurancy')