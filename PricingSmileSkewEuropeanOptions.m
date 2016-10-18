%% Pricing Options with Volatility Smile and Skew
% When we allow the volatility of the asset price to vary with the asst
% price itself, we must solve the stochastic differential equation
% describin the asset path _approximately_, using, say an Euler-Maruyama
% scheme.
%
% This kind of asset path is not yet implemented in the GAIL |assetPath|
% class, so we will solve the problem in a less than elegant manner. 

%% Initialization
% First we set up the basic common praramters for our examples.

gail.InitializeWorkspaceDisplay %initialize the workspace and the display parameters
t0 = tic;
inp.timeDim.timeVector = 1/52:1/52:1/4; %weekly monitoring for three months
bmObj = brownianMotion(inp); %create a Brownian motion object
inp.assetParam.initPrice = 100; %initial stock price
inp.assetParam.interest = 0.01; %risk-free interest rate
inp.assetParam.volatility = 0.5; %volatility
inp.payoffParam.strike = 100; %strike price
inp.payoffParam.putCallType = {'call'}; %call option
inp.priceParam.absTol = 0.05; %absolute tolerance of a nickel
inp.priceParam.relTol = 0; %zero relative tolerance
EuroCall = optPrice(inp); %construct an optPrice object 

%% The European call option price without skew and smile
% For reference, the price of the European call option is as follows

disp('The price of the European call option')
disp(['    with a geometric Brownian motion is $' num2str(EuroCall.exactPrice,'%5.2f')])

%% Setting up Parameters for the Smile and Skew
% Here are some asset and payoff parameters that would normally be in part
% of the |optPrice| class, but need to be input in another way because the
% |assetPath| class does not yet support the smile and skew.

inp.assetParam.sigskew = 0.4; %skew parameter
inp.assetParam.sigsmile = 0.6; %smile parameter

%%
% We have written a function to generate smile and skew paths and also the
% payoffs
%
% <include>smileSkewEuro.m</include>
%
% Again, in the future, this function should not be needed because
% |assetPath| will contain this functionality.

%% Generating the European call option price with skew and smile
% So now we can generate the option price using |meanMC_g|

SmileSkewOptionPrice = meanMC_g(@(n) smileSkewEuro(n,bmObj,inp), ...
   inp.priceParam.absTol, inp.priceParam.relTol);
disp('The price of the European call option')
disp(['    with a skew and smile is $' num2str(SmileSkewOptionPrice,'%5.2f')])

%%
% This price is higher because the volatility rises as the stock price
% moves above the strike price.

%% Generating the European put option price with skew and smile
% Let's compare the put price.  First we construct the put object with a
% geometric Brownian motion path

EuroPut = optPrice(EuroCall); %construct an optPrice object 
EuroPut.payoffParam.putCallType = {'put'}; %put option
disp('The price of the European put option')
disp(['    with a geometric Brownian motion is $' num2str(EuroPut.exactPrice,'%5.2f')])

%%
% Next we compute the compute the put option price with the skew and smile

inp.payoffParam.putCallType = {'put'}; %put option
SmileSkewOptionPrice = meanMC_g(@(n) smileSkewEuro(n,bmObj,inp), ...
   inp.priceParam.absTol, inp.priceParam.relTol);
disp('The price of the European put option')
disp(['    with a skew and smile is $' num2str(SmileSkewOptionPrice,'%5.2f')])
toc(t0) %how much time does this take

%%
% _Author: Fred J. Hickernell_
