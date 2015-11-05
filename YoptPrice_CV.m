function YCV=YoptPrice_CV(optPayoffObj,n)
% YOPTPRICE_CV creates the control variate output for option pricing using
% the |optPayoff| object

meanX = optPayoffObj.exactPrice(2:end); %get the exact option prices for the control variates
YX = genOptPayoffs(optPayoffObj,n); %get the Y and X values
beta = bsxfun(@minus,YX(:,2:end),mean(YX(:,2:end),1))\YX(:,1); %optimal beta
YCV = YX(:,1) - bsxfun(@minus,YX(:,2:end),meanX)*beta; %control variate random variable