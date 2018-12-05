%% Pricing Options with Antithetic Variates
% Antithetic variates would have us use both a Brownian motion and its
% negative, which is also a Brownian motion, to generate stock price paths
% for option pricing.
%
% This functionality is not yet implemented in the GAIL |optPrice| class,
% so we will solve the problem in a less elegant manner.

%% Initialization
% First we set up the basic common praramters for our examples.

gail.InitializeWorkspaceDisplay %initialize the workspace and the display parameters
inp.timeDim.timeVector = 1/52:1/52:1/4; %weekly monitoring for three months
inp.assetParam.initPrice = 100; %initial stock price
inp.assetParam.interest = 0.05; %risk-free interest rate
inp.assetParam.volatility = 0.5; %volatility
inp.payoffParam.strike = 100; %strike price
inp.payoffParam.optType = {'amean'}; %looking at an arithmetic mean option
inp.payoffParam.putCallType = {'put'}; %looking at a put option
inp.priceParam.absTol = 0.01; %absolute tolerance of a one cent
inp.priceParam.relTol = 0; %zero relative tolerance

%% The Asian arithmetic mean put without antithetic variates
% Next we create an Asian arithmetic mean put |optPrice| object and use
% Monte Carlo to compute the price.

AMeanPut = optPrice(inp); %construct an optPrice object 
[AMeanPutPrice,Aout] = genOptPrice(AMeanPut);
disp(['The price of the Asian arithmetic mean put option is $' ...
   num2str(AMeanPutPrice,'%5.2f')])
disp(['   and this took ' num2str(Aout.nPaths) ' paths and ' ...
   num2str(Aout.time) ' seconds'])

%% The Asian arithmetic mean put *with* antithetic variates
% Since this functionality is not available in GAIL yet, we need to create
% our own function that generates the two sets of payoffs from the Brownian
% motion and its additive inverse, and then takes the average.  We have
% written such a function:
%
% <include>YoptPrice_Anti.m</include>
%
% In the future, this function should not be needed because GAIL will
% contain this functionality.
%
% Now we call |meanMC_g|:
%

[AMeanPriceAnti, AAntiout] = meanMC_g(@(n) YoptPrice_Anti(AMeanPut,n), ...
   inp.priceParam.absTol, inp.priceParam.relTol);
disp(['The price of the Asian arithmetic mean put option is $' ...
   num2str(AMeanPriceAnti,'%5.2f')])
disp(['   and this took ' num2str(AAntiout.ntot) ' paths and ' ...
   num2str(AAntiout.time) ' seconds'])
disp(['   which is ' num2str(AAntiout.ntot/Aout.nPaths) ...
   ' of the paths and ' num2str(AAntiout.time/Aout.time) ' of the time'])
disp('      without antithetic variates')

%% 
% Note that the price is the same, but the time required is much less.
% Unfortunately, it is difficult to know in advance what the optimal drift
% is.
%
% _Author: Fred J. Hickernell_
