%% Example using GAIL for options
% This file is a record of what we are doing today.  It is not the
% recommended way to set up option pricing.  See the other demos in
% PublishMATH565Demos

fredOpt = optPrice; %Create an optPrice class object
fredOpt.timeDim.timeVector = 1/52:1/52:1/4; %Change the discrete times
fredOpt.timeDim.timeVector %Look at the time vector
fredOpt.assetParam.volatility = 0.3; %Change the volatility
% Note that the default is a European call option. We know the exact price,
% which is $0.61

methods(fredOpt) %look at the methods for this object

% For fun, we compute the price by Monte Carlo
fredOpt.priceParam.absTol = 0.01; %Change the absolute tolerance
[fredPrice, out] = genOptPrice(fredOpt) %Put optPrice object as the input argument
% This takes about 2e5 paths. For absTol = 0.001, it might take 2e7 paths
fredOpt.priceParam.absTol = 0.001; %Change the absolute tolerance
% [fredPrice, out] = genOptPrice(fredOpt) %Put optPrice object as the input argument

% Let's try the Asian Arithmetic Mean Option
fredOpt.payoffParam.optType = {'amean'};
fredOpt.priceParam.absTol = 0.01; %Change the absolute tolerance
[fredPrice, out] = genOptPrice(fredOpt) %Put optPrice object as the input argument
% Now the price is only $0.37

% What happens if the volatility is higher?
fredOpt.assetParam.volatility = 0.5; %Increase volatility
[fredPrice, out] = genOptPrice(fredOpt) %Price the option
% The price is higher, $0.61

% What happens if the interest rate is higher, like during the oil crisis
fredOpt.assetParam.interest = 0.1; %Increase interest rate
[fredPrice, out] = genOptPrice(fredOpt) %Price the option
% The price is higher, $0.67

% Now let's try a barrier option
fredOpt.assetParam.interest = 0.01; %Change interest rate back
fredOpt.payoffParam.optType = {'downin'}; %Change to a barrier option
fredOpt.payoffParam.putCallType = {'put'}; %Change to a barrier option
fredOpt.payoffParam.barrier = 8; %Set the barrier
[fredPrice, out] = genOptPrice(fredOpt) %Price the option
% The price is $0.78

% Now let's try an ordinary European put option
fredOpt.payoffParam.optType = {'euro'}; %Change to a European option
[fredPrice, out] = genOptPrice(fredOpt) %Price the option
% The price should be higher.  It is $0.98

% Now let's try an American put option
fredOpt.payoffParam.optType = {'american'}; %Change to an American option
[fredPrice, out] = genOptPrice(fredOpt) %Price the option
% The price should be higher than the European option.  But we cannot see
% the difference because the error tolerance is greater than the
% difference.

% Try again with larger interest rate
fredOpt.assetParam.interest = 0.05; %Increas interest rate
fredOpt.priceParam.absTol = 0.002; %Decrease error tolerance
fredOpt.payoffParam.optType = {'euro'}; %Change to a European option
[fredPrice, out] = genOptPrice(fredOpt) %Price the option
fredOpt.payoffParam.optType = {'american'}; %Change to an American option
[fredPrice, out] = genOptPrice(fredOpt) %Price the option

% Try a down and in barrier with barrier = 0
fredOpt.payoffParam.optType = {'downin'}; %Change to a European option
fredOpt.payoffParam.barrier = 0; %Set the barrier
[fredPrice, out] = genOptPrice(fredOpt) %Price the option
% Try a down and out barrier with barrier = 0
fredOpt.payoffParam.optType = {'downout'}; %Change to a European option
[fredPrice, out] = genOptPrice(fredOpt) %Price the option

% Change back to American
fredOpt.payoffParam.optType = {'american'} %Change to an American option
[fredPrice, out] = genOptPrice(fredOpt) %Price the option
% Now try Sobol cubature
fredOpt.priceParam.cubMethod = {'Sobol'} %Change to an American option
[fredPrice, out] = genOptPrice(fredOpt) %Price the option
% The time required is much smaller
fredOpt.bmParam.assembleType = 'PCA' %Change the way that the Brownian motion is constructed
[fredPrice, out] = genOptPrice(fredOpt) %Price the option

