%% A Monte Carlo Option Pricing Example 
% This MATLAB script shows how to use Monte Carlo methods to price a
% financial derivative or option.  An option gives the right, but not the
% obligation, to conduct some transaction at a future date.

%% Initializing the workspace and setting the parameters
% These settings clean up the workspace and facilitate a more beautiful
% display.

format compact %eliminate blank lines in output
close all %close all figures
clearvars %clear all variables
set(0,'defaultaxesfontsize',24,'defaulttextfontsize',24, ... %make font larger
      'defaultLineLineWidth',3, ... %thick lines
      'defaultLineMarkerSize',40, ... %big dots
      'defaultTextInterpreter','latex', ... %latex axis labels
      'defaultLegendInterpreter','latex') %latex legends

%% Plot Historical Data
% Here we load in the historical adjusted daily closing prices of a stock
% and plot the most recent year's data.

load AdjCloseData
stockPriceHistory = AdjClose(105:354); % looking at one previous year's data
S0 = stockPriceHistory(end); %stock price today
Delta = 1/250; %daily time increment
timeBefore = (-249:0) * Delta; %daily monitoring for one year
plot(timeBefore, stockPriceHistory,'-',0,S0,'.') %plot history
xlabel('Time \(t\) (in years)') %add nice labels
ylabel('Stock Price')
axis([-1 1 300 900]) %set reasonable scales for axes
print -depsc StockHistory.eps %print the plot

%% Estimate Drift and Volatility
% Although we know the past, we do not know the future.  However, we can
% use historical data to build a random (stochastic) model of the future.
% Let \(S(t)\) denote the price of this stock at time \(t\) measured in
% years.  The geometric Brownian motion of a stock price says that 
% 
% \[ S(t+\Delta ) = S(t) \exp( \Delta m + \sigma \sqrt{\Delta} Z ), \]
%
% where 
% 
% * \(\Delta = 1/250\) is the time increment (250 trading days per year, 
% * \(m\) is a constant _drift_, 
% * \(\sigma\) is the _volatility_, and 
% * \(Z\) is a Gaussian (normal) random variable with zero mean and unit
% variance. 
%
% For the data \((t_j,S(t_j)\) that we have, this can be written as
% 
% \[ \log\biggl(\frac{S(t_{j+1})}{S(t_{j})} \biggr) = \log(S(t_{j+1} )) -
% \log(S(t_j)) = \Delta m + \sigma \sqrt{\Delta} Z_j, \]
%
% where the \(Z_j\) are independent and identically
% distributed (IID) \(\mathcal{N}(0,1)\).  This means that we can estimate
% \(\Delta m\) and \(\sigma^2 \Delta\) by the sample mean and variance of
% the difference of the logged stock price data:
%
% \[ \Delta m  = \frac{1}{249} \sum_{j=-249}^{-1}
% \log\biggl(\frac{S(t_{j+1})}{S(t_{j})} \biggr), \qquad  \sigma^2 \Delta =
% \frac{1}{248} \sum_{j=-249}^{-1}
% \biggl[\log\biggl(\frac{S(t_{j+1})}{S(t_{j})} \biggr) - \Delta m
% \biggr]^2, \qquad t_j = \frac{j}{250}. \]

diffLogStockPrice = diff(log(stockPriceHistory)); %difference of log of stock prices
scDrift = mean(diffLogStockPrice); %sample mean
drift = scDrift/Delta; %estimated drift
scVolatility = std(diffLogStockPrice); %sample standard deviation
volatility = scVolatility/sqrt(Delta); %estimated volatility

%%
% The interesting part is what comes next!

%% Future Price Movement
% Next we use these estimated quantities to plot scenarios representing
% what this stock might do in the future.  We set up times looking half a
% year ahead: 

d = 125; %look at d new time steps
timeAfter = (1:d) * Delta; %time steps ahead
timeFinal = timeAfter(d); %final time

%%
% Next we program a function that computes \(n\) possible scenarios:

SVal = @(n) S0*exp(bsxfun(@plus, ... %bsxfun is a great way to operate on one vector and one matrix
   drift*timeAfter, ... %the time varying part
   scVolatility * cumsum(randn(n,d),2))); %randn produces Gaussian random numbers
hold on 
h = plot(timeAfter,SVal(8)); %plot 8 paths into the future

%%
% Which one of these is correct?  In fact, there are infinitely many
% possibilities.  This time let's plot more and look at the histogram.

delete(h); %delete the old paths
stockVal = SVal(1e4); %generate a large number of paths
plot(timeAfter,stockVal) %plot a large number of paths
[binCt,binEdge] = histcounts(stockVal(:,d)); %compute a histogram of the prices at the final time
nBin = numel(binCt); %number of bins used
MATLABblue = [0 0.447 0.741]; %the RGB coordinates of the default MATLAB blue for plotting
patch(timeFinal + [0; reshape([binCt; binCt],2*nBin,1); 0]*(0.4/max(binCt)), ... %x values
   reshape([binEdge; binEdge], 2*nBin+2, 1), ... %y values
   MATLABblue,'EdgeColor',MATLABblue) %plot the histogram patch

%%
% Note that this distribution of final prices is skewed towards the higher
% values.

%% European Option Pricing
% A European option comes in two types, call and put, and pays an amount at
% the time of expiry, \(T\), that depends on the final price of the stock
%
% \[
% \begin{array}{rcc}
% & \text{put} & \text{call} \\ \hline
% \text{payoff} & \max(S(T) - K,0) & \max(K - S(T),0) 
% \end{array}
% \]
%
% Here, \(K\) denotes an agreed upon _strike price_.  The future stock
% price path is a random (stochastic) profess, so \(S(T)\) is random, and
% the option payoff is random. Although we cannot know the actual future
% payoff, we can try to compute the fair price of the option, which is the
% expected value or mean of the payoff.  In fact, there is a small wrinkle.
% Because money today is generally worth more than money in the future, the
% fair price of the option is the expected value of the payoff times a
% discounting factor that depends on the prevailing riskless interest rate,
% \(r\), i.e.,
%
% \[ \text{fair price} = \mathbb{E}(\text{payoff}\mathrm{e}^{-rT}). \]
%
% One way to estimate this mean is by the sample mean of the many payoffs.
% Let \(Y_i\) denote the payoff of option according to the \(i\)th random
% stock path.  Then the approxmate fair price is 
%
% \[ \text{approximate fair price} = \frac{1}{n}\sum_{i=1}^n Y_i
% \mathrm{e}^{-rT} = \begin{cases} \displaystyle \frac{1}{n}\sum_{i=1}^n
% \max(S_i(T) - K,0) \mathrm{e}^{-rT}, & \text{call}, \\ \displaystyle
% \frac{1}{n}\sum_{i=1}^n \max(K - S_i(T),0) \mathrm{e}^{-rT}, &
% \text{put}. \end{cases} \]
%
% There is a relationship between the riskless interest rate and the drift, which is
% 
% \[m = r - \frac{\sigma^2}{2} \]
%
% This allows us to estimate the interest rate.  Let's try to price a
% European call option with a strike price of $600.

K = 600; %strike price
interest = drift + volatility^2/2 %interest rate
euroCallPrice = mean(max(stockVal(:,d) - K, 0)) * exp(-interest * timeFinal)

%%
% We can try again

stockVal = SVal(1e4); %generate a large number of new paths
euroCallPrice = mean(max(stockVal(:,d) - K, 0)) * exp(-interest * timeFinal)

%%
% These two approximations to the option prices are similar, but not the
% same.

%% Discussion, Caveats and Open Problems
%
% * The accuracy of the approximation depends on the number of stock price
% paths used, \(n\).  We will discuss this dependence and how to choose
% \(n\) to obtain the desired accuracy.
%
% * This example looked at one of the simplest options to price.  However,
% note that one can consider options where they payoff is a more
% complicated function of the stock path, \(S(T/d), S(2T/d), \ldots,
% S(T))\), and the Monte Carlo method will work the same way.
%
% * The geometric Brownian motion model for the stock price may not capture
% the real world best.  Other models can be used, and the Monte Carlo
% method still works.
%
% * There are exact formulas for prices of European put and call options
% with this the geometric Brownian motion stock price paths. One does not
% really need Monte Carlo to price them, but Monte Carlo is needed for more
% sophisticated options.  We considered European options for the sake of
% simplicity.
%
% * We used IID sampling.  If one is careful, other sampling schemes may be
% used to obtain the desired answer in less time, i.e., with fewer samples. 
%

