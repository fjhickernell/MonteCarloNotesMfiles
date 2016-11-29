%% A Trading Strategy
% This MATLAB script shows how to use (quasi-)Monte Carlo methods with the
% |assetPath| class to investigate a particular trading strategy.

%%
gail.InitializeWorkspaceDisplay %initialize the workspace and the display parameters


%% Setting Up the AssetPath Object
% Let \(S(t)\) denote the price of this stock at time \(t\) measured in
% years.  The geometric Brownian motion model of a stock price says that 
% 
% \[ S(t) = S(0) \exp( (r^* - \sigma^2/2) t + \sigma B(t) ), \]
%
% where 
% 
% * \(S(0)\) is the initial stock price,
% * \(r^*\) is the _risk-neutral rate_, 
% * \(\sigma\) is the constant _volatility_, and 
% * \(B(t)\) is a Brownian motion. 
%
% We set up an |assetPath| object with typical values of thes parameters

inp.timeDim.timeVector = 1/52:1/52:1/2; %weekly monitoring for half a year
inp.assetParam.initPrice = 100; %initial stock price
inp.assetParam.interest = 0.02; %risk-neutral rate
inp.assetParam.volatility = 0.5; %volatility
risklessInterest = 0.01; %interest for putting money in bank
cutoff = 75; %cutoff where we should sell
absTol = 0.05; %absolute tolerance 
relTol = 0; %relative tolerance
StockMC = assetPath(inp)

%% Cautious Trading Strategy
% We know that according to the geometric Brownian motion model, the
% expected stock price after half a year should be \(S(0) \exp(r^*/2)\),
% which means a return of \(S(0) (\exp(r^*/2)-1)\).  This corresponds to a
% disounted return of \(S(0) (\exp((r^*-r)/2)-1)\), where \(r\) is the
% risk-free rate. But suppose that we decide to protect against adverse
% loss by selling if the stock ever gets below \(\$75\).  Will this affect
% our expected return?  Let's see.
%
% <include>returnValue.m</include>

fprintf(1,'The expected discounted return if one just waits six months is $%6.4f\n', ...
   inp.assetParam.initPrice*(exp((inp.assetParam.interest-risklessInterest)/2)-1))
[expValMC,outMC] = meanMC_g(@(n) returnValue(StockMC,n,cutoff,risklessInterest), ...
   absTol,relTol);
fprintf(1,'The expected discounted return if cuts losses is $%6.4f, which seems smaller\n', ...
   expValMC - inp.assetParam.initPrice)
fprintf(1,'   This required %10.0f Monte Carlo samples and %6.3f seconds\n', ...
   outMC.ntot, outMC.time)
fprintf(1,'      for a tolerance of %6.4f\n', ...
   absTol)

%% Using Sobol' Sampling to Get the Answer Quicker
% This time we do the same calculation but using |cubSobol_g|.  First we
% need a new class

StockSobol = assetPath(StockMC); %make a copy
StockSobol.inputType = 'x'; %cubSobol uses x values as inputs
StockSobol.wnParam.sampleKind = 'Sobol'; %change from IID
StockSobol.bmParam.assembleType = 'PCA' %makes the calculations more efficient
d = size(StockSobol.timeDim.timeVector,2); %the dimension of the problem
absTol = 0.005; %smaller absolute tolerance
[expValSobol,outSobol] = cubSobol_g(@(x) returnValue(StockSobol,x,cutoff,risklessInterest), ...
   [zeros(1,d); ones(1,d)],'uniform', absTol, relTol);
fprintf(1,'The expected discounted return if cuts losses, now using Sobol, is $%6.4f\n', ...
   expValSobol - inp.assetParam.initPrice)
fprintf(1,'   This required %10.0f Sobol samples and %6.3f seconds,\n', ...
   outSobol.n, outSobol.time)
fprintf(1,'      but for a smaller tolerance of only %6.4f\n', ...
   absTol)


%%
%
% _Author: Fred J. Hickernell_
