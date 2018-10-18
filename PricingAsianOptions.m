%% Pricing Asian Style Options
% As introduced in |IntroGAILOptionPricing|, GAIL has classes that define
% various types of option payoffs for different models of asset price
% paths. In this MATLAB script we show how to use these classes for Monte
% Carlo option pricing of options with Asian style payoffs and European
% exercise.
% 
% * The payoff depends on the whole asset price path, not only on the
% terminal asset price.
% * The option is only exercised at expiry, unlike American options,
% which can be exercised at any time before expiry.

%% Initialization
% First we set up the basic common praramters for our examples.

function BarrierUpInCall = PricingAsianOptions %make it a function to avoid variable conflicts
gail.InitializeDisplay %initialize the workspace and the display parameters
inp.timeDim.timeVector = 1/52:1/52:1/4; %weekly monitoring for three months
inp.assetParam.initPrice = 120; %initial stock price
inp.assetParam.interest = 0.01; %risk-free interest rate
inp.assetParam.volatility = 0.5; %volatility
inp.payoffParam.strike = 130; %strike price
inp.priceParam.absTol = 0.05; %absolute tolerance of a nickel
inp.priceParam.relTol = 0; %zero relative tolerance
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
ArithMeanCall.payoffParam.optType = {'amean'} %change from European to Asian arithmetic mean

%%
% Next we generate the price using the |genOptPrice| method of the |optPrice|
% object. 

[ArithMeanCallPrice,out] = genOptPrice(ArithMeanCall); %uses meanMC_g to compute the price
disp(['The price of this Asian arithmetic mean call option is $' num2str(ArithMeanCallPrice) ...
   ' +/- $' num2str(max(ArithMeanCall.priceParam.absTol, ...
   ArithMeanCall.priceParam.relTol*ArithMeanCallPrice)) ])
disp(['   and it took ' num2str(out.time) ' seconds and ' ...
   num2str(out.nPaths) ' paths to compute']) %display results nicely

%%
% The price of the Asian arithmetic mean call option is smaller than the
% price of the European call option.  
%
% We may also price the Asian arithmetic mean put option as follows:

ArithMeanPut = optPrice(ArithMeanCall); %make a copy
ArithMeanPut.payoffParam.putCallType = {'put'}; %change from call to put
[ArithMeanPutPrice,out] = genOptPrice(ArithMeanPut); %uses meanMC_g to compute the price
disp(['The price of this Asian arithmetic mean put option is $' num2str(ArithMeanPutPrice) ...
   ' +/- $' num2str(max(ArithMeanPut.priceParam.absTol, ...
   ArithMeanPut.priceParam.relTol*ArithMeanPutPrice)) ])
disp(['   and it took ' num2str(out.time) ' seconds and ' ...
   num2str(out.nPaths) ' paths to compute']) %display results nicely

%%
% Note that the price is greater.  This is because one strike price is
% above the initial price, making the expected payoff greater.
%
% In the limit of continuous monitoring \(d \to \infty\), the payoff is 
%
% \[
% \begin{array}{rcc}
% & \textbf{call} & \textbf{put} \\ \hline
% \textbf{payoff} & 
% \displaystyle \max\biggl(\frac 1T \int_{0}^T S(t) \, {\rm d} t - K,0 \biggr)\mathsf{e}^{-rT} & 
% \displaystyle \max\biggl(K - \frac 1T \int_{0}^T S(t) \, {\rm d} t,0 \biggr)\mathsf{e}^{-rT} 
% \end{array}
% \]
%
% Such an option can be approximated by taking smaller time steps:

ArithMeanCallBigd = optPrice(ArithMeanCall); %make a copy
ArithMeanCallBigd.timeDim.timeVector = 1/250:1/250:0.25; %daily monitoring
[ArithMeanCallBigdPrice,out] = genOptPrice(ArithMeanCallBigd); %uses meanMC_g to compute the price
disp(['The price of this Asian arithmetic mean call option is $' num2str(ArithMeanCallBigdPrice) ...
   ' +/- $' num2str(max(ArithMeanCallBigd.priceParam.absTol, ...
   ArithMeanCallBigd.priceParam.relTol*ArithMeanCallBigdPrice)) ])
disp(['   and it took ' num2str(out.time) ' seconds and ' ...
   num2str(out.nPaths) ' paths to compute']) %display results nicely

%%
% The price is a bit lower, and the time is longer because more time steps
% are needed, which means more random variables are needed.
%
% One can also base the payoff on a geometric mean rather than an
% arithmetic mean.  Such options have a closed form solution.  The price of
% a geometric mean \(\begin{Bmatrix} \text{call} \\ \text{put}
% \end{Bmatrix}\)  option is \(\begin{Bmatrix} \le \\ \ge \end{Bmatrix}\) the
% price of an arithmetic mean \( \begin{Bmatrix} \text{call} \\
% \text{put} \end{Bmatrix}\) option because a geometric mean is smaller
% than an arithmetic mean.

%% Barrier Options
% In barrier options the payoff only occurs if the asset price crosses or
% fails to cross a barrier, \(b\)
%
% \[
% \begin{array}{rcc}
% & \textbf{up} (S(0) < b) & \textbf{down} (S(0) > b) \\ \hline
% \textbf{in} & \text{active if } S(t) \ge b & \text{active if } S(t) \le
% b \\
% \textbf{out} & \text{inactive if } S(t) \ge b & \text{inactive if } S(t) \le
% b 
% \end{array}
% \]
%
% For the barrier option with a European call type payoff, this corresponds to 
%
% \[
% \begin{array}{rcc}
% \textbf{payoff} & \textbf{up} (S(0) < b) & \textbf{down} (S(0) > b) \\ \hline
% \textbf{in} & 
% 1_{[b,\infty)}(\max_{0 \le t \le T} S(t)) \max(S(T)-K,0)\mathsf{e}^{-rT} & 
% 1_{[0,b]}(\min_{0 \le t \le T} S(t)) \max(S(T)-K,0)\mathsf{e}^{-rT} \\
% \textbf{out} & 1_{[0,b)}(\max_{0 \le t \le T} S(t)) \max(S(T)-K,0)\mathsf{e}^{-rT} & 
% 1_{[b,\infty)}(\min_{0 \le t \le T} S(t)) \max(S(T)-K,0)\mathsf{e}^{-rT}
% \end{array}
% \]

%%
% Again, the |optPrice| object can price such options using adaptive Monte
% Carlo.

BarrierUpInCall = optPrice(EuroCall); %make a copy
BarrierUpInCall.payoffParam.barrier = 150; %barrier
BarrierUpInCall.payoffParam.optType = {'upin'}; %up and in
[BarrierUpInCallPrice,out] = genOptPrice(BarrierUpInCall); %uses meanMC_g to compute the price
disp(['The price of this barrier up and in call option is $' ...
   num2str(BarrierUpInCallPrice) ...
   ' +/- $' num2str(max(BarrierUpInCall.priceParam.absTol, ...
   BarrierUpInCall.priceParam.relTol*BarrierUpInCallPrice)) ])
disp(['   and it took ' num2str(out.time) ' seconds and ' ...
   num2str(out.nPaths) ' paths to compute']) %display results nicely

%%
% Note that this price is less than the European call option because the
% asset price must cross the barrier for the option to become active.

%% Lookback Options
% Lookback options do not use a strike price but use the minimum or maximum
% asset price as their strike.  The discounted payoffs are
%
% \[
% \begin{array}{rcc}
% & \textbf{call} & \textbf{put} \\ \hline
% \textbf{payoff} & 
% \displaystyle \Bigl(S(T) - \min_{0 \le t \le T} S(t),0 \Bigr)\mathsf{e}^{-rT} & 
% \displaystyle \Bigl(\max_{0 \le t \le T} S(t) - S(T),0 \Bigr)\mathsf{e}^{-rT} 
% \end{array}
% \]
%
% where the values of \(t\) considered for the minimum or maximum are
% either discrete, \(0, T/d, \dots, T\), or continuous.  Note that we would
% expect the prices of these options to be greater than their out of the
% money European counterparts.

LookCall = optPrice(EuroCall); %make a copy
LookCall.payoffParam.optType = {'look'}; %lookback
[LookCallPrice,out] = genOptPrice(LookCall); %uses meanMC_g to compute the price
disp(['The price of this lookback call option is $' ...
   num2str(LookCallPrice) ...
   ' +/- $' num2str(max(LookCall.priceParam.absTol, ...
   LookCall.priceParam.relTol*LookCallPrice)) ])
disp(['   and it took ' num2str(out.time) ' seconds and ' ...
   num2str(out.nPaths) ' paths to compute']) %display results nicely

%%
% _Author: Fred J. Hickernell_
