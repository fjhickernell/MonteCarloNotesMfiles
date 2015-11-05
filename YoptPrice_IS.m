function YIS=YoptPrice_IS(optPayoffObj,n, drift)
% YOPTPRICE_IS creates the new \(Y\) for an Asian arithmetic mean put with
% a downward drift.

bmObj = brownianMotion(optPayoffObj); %make a Brownian motion object
BMPaths =  genPaths(bmObj,n); %ordinary Brownian motion paths
driftvec = drift*optPayoffObj.timeDim.timeVector; %set up new mean (drift) vector
BMPaths = bsxfun(@plus,BMPaths,driftvec); %add the drift to the original Brownian motion
stockPrice = optPayoffObj.assetParam.initPrice ...
   *exp(bsxfun(@plus, ...
   (optPayoffObj.assetParam.interest - (optPayoffObj.assetParam.volatility.^2)/2) ...
   .* optPayoffObj.timeDim.timeVector, ...
   optPayoffObj.assetParam.volatility.*BMPaths));
YIS = max(optPayoffObj.payoffParam.strike - mean(stockPrice,2),0) ...
   * exp(-optPayoffObj.assetParam.interest * optPayoffObj.timeDim.endTime);
   % the Asian arithmetic mean put payoff using the drifted paths
YIS = YIS .* exp(bsxfun(@minus,driftvec(end)/2,BMPaths(:,end))*drift); %multiply by weights
