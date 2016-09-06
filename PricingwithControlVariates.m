%% Pricing Options with Control Variates
% This is a test

%% Initialization
% First we set up the basic common praramters for our examples.

gail.InitializeWorkspaceDisplay %initialize the workspace and the display parameters
inp.timeDim.timeVector = 1/52:1/52:1/4; %weekly monitoring for three months
inp.assetParam.initPrice = 120; %initial stock price
inp.assetParam.interest = 0.01; %risk-free interest rate
inp.assetParam.volatility = 0.5; %volatility
inp.payoffParam.strike = 130; %strike price
inp.priceParam.absTol = 0.005; %absolute tolerance of half a penny
inp.priceParam.relTol = 0; %zero relative tolerance
inp.priceParam.cubMethod = 'Sobol'; %Sobol sampling
EuroCall = optPrice(inp) %construct an optPrice object 

%%
% Note that the default is a European call option.  Its exact price is
% coded in

disp(['The price of this European call option is $' num2str(EuroCall.exactPrice)])

%% Arithmetic Mean Options
% The payoff of the arithmetic mean option depends on the average of the
% stock price, not the final stock price.  Here are the discounted payoffs:
%
% \[
% \begin{array}{rcc}
% & \textbf{call} & \textbf{put} \\ \hline
% \textbf{payoff} & 
% \displaystyle \max\biggl(\frac 1d \sum_{j=1}^d S(jT/d) - K,0 \biggr)\mathsf{e}^{-rT} & 
% \displaystyle \max\biggl(K - \frac 1d \sum_{j=1}^d S(jT/d),0 \biggr)\mathsf{e}^{-rT} 
% \end{array}
% \]

%%
% To construct price this option, we construct an |optPrice| object with
% the correct properties.  First we make a copy of our original |optPrice|
% object.  Then we change the properties that we need to change.

ArithMeanCall = optPrice(EuroCall); %make a copy
ArithMeanCall.payoffParam.optType = {'amean'} %change from European to Asian arithemetic mean

%%
% Next we generate the price using the |genOptPrice| method of the |optPrice|
% object. 

[ArithMeanCallPrice,out] = genOptPrice(ArithMeanCall); %uses meanMC_g to compute the price
disp(['The price of this Asian arithemetic mean call option is $' num2str(ArithMeanCallPrice) ...
   ' +/- $' num2str(max(ArithMeanCall.priceParam.absTol, ...
   ArithMeanCall.priceParam.relTol*ArithMeanCallPrice)) ])
disp(['   and it took ' num2str(out.time) ' seconds to compute']) %display results nicely

%%
% The price of the Asian arithmetic mean call option is smaller than the
% price of the European call option. 

%% Speeding Things Up with PCA
% If we use a PCA construction for the Browniam motion, the Sobol will be
% even more efficient.

ArithMeanCallPCA = optPrice(ArithMeanCall);
ArithMeanCallPCA.bmParam.assembleType = 'PCA'
[ArithMeanCallPCAPrice,out] = genOptPrice(ArithMeanCallPCA); %uses meanMC_g to compute the price
disp(['The price of this Asian arithemetic mean call option is $' num2str(ArithMeanCallPrice) ...
   ' +/- $' num2str(max(ArithMeanCallPCA.priceParam.absTol, ...
   ArithMeanCallPCA.priceParam.relTol*ArithMeanCallPCAPrice)) ])
disp(['   and it took ' num2str(out.time) ' seconds to compute']) %display results nicely

%% The Geometric Mean Call as a Control Variate
% To add the geometric mean call we 

ArithGeomMeanCall = optPayoff(ArithMeanCall); %make a copy
% inp = struct('optType',{'amean','gmean','euro'},...
%    'putCallType',{'call','call','call'})
ArithGeomMeanCall.payoffParam = struct( ...
   'optType',{{'amean','gmean','euro','stockprice'}},...
   'putCallType',{{'call','call','call',''}}) %add geometric mean call
sob=scramble(sobolset(numel(ArithGeomMeanCall.timeDim.timeVector)), ...
   'MatousekAffineOwen');
genOptPayoffs(ArithGeomMeanCall,net(sob,6))


%%
% _Author: Fred J. Hickernell_
