function YAnti=YoptPrice_Anti(optPayoffObj,n)
% YOPTPRICE_Anti creates payoffs from antithetic Brownian motion sampling
% for an Asian arithmetic mean put.

bmObj = brownianMotion(optPayoffObj); %make a Brownian motion object
BMPaths =  genPaths(bmObj,n); %ordinary Brownian motion paths
temp1 = (optPayoffObj.assetParam.interest - (optPayoffObj.assetParam.volatility.^2)/2) ...
   .* optPayoffObj.timeDim.timeVector; %(r-sigma^2/2)*t
stockPrice1 = optPayoffObj.assetParam.initPrice*exp(bsxfun(@plus, temp1, ...
   optPayoffObj.assetParam.volatility.*BMPaths)); %with original Brownian paths
stockPrice2 = optPayoffObj.assetParam.initPrice*exp(bsxfun(@minus, temp1, ...
   optPayoffObj.assetParam.volatility.*BMPaths)); %with minus Brownian paths

YAnti = (max(optPayoffObj.payoffParam.strike - mean(stockPrice1,2),0) ...
   + max(optPayoffObj.payoffParam.strike - mean(stockPrice2,2),0)) ...
   .* (0.5*exp(-optPayoffObj.assetParam.interest * optPayoffObj.timeDim.endTime));
   % the averge of the Asian arithmetic mean put payoffs using the two
   % stock price paths

