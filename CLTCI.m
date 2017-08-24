function quantci=quantileCI(quant,Xsample,alpha,extremes)
% QUANTCI computes  1-alpha  confidence intervals 
%  for the  quant  quantile of a random variable X 
%  with extreme values  extremes
%  using IID data  Xsample
n=length(Xsample); %number of samples
Xorder=[extremes(1); sort(Xsample); extremes(2)]; %order statistics
al2=alpha/2;
lo=1+binoinv_bs_ver2(al2,n,quant);
up=2+binoinv_bs_ver2(1-al2,n,quant);
quantci=[Xorder(lo),Xorder(up)]; %confidence interval for quantile