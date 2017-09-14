%% Monte Carlo Option Pricing Example Using CLT Confidence Intervals
% This MATLAB script shows how to use approximate Central Limit Theorem
% (CLT) confidence intervals with Monte Carlo to price a financial
% derivative or option.  See |OptionPricingExample| for some of the
% background of this example.

%% Initialize the workspace and setting the display parameters
% These settings clean up the workspace and make the display beautiful.

function OptionPricingMeanMC_CLT %make it a function to not overwrite other variables
gail.InitializeDisplay %initialize the display parameters

%% Plot historical hata
% Here we load in the historical adjusted daily closing prices of a stock
% and plot the most recent year's data.  The data were obtained from
% <http://finance.yahoo.com> for GOOG for the period ending May 19, 2015.

load stockPriceHistory.txt -ascii %load one year of stock price data into memory
S0 = stockPriceHistory(end); %stock price today
Delta = 1/250; %daily time increment in years
timeBefore = (-249:0) * Delta; %daily monitoring for one year prior to today
plot(timeBefore, stockPriceHistory,'-',0,S0,'.') %plot history
xlabel('Time, \(t\), in years\hspace{5ex}') %add labels
ylabel('Stock Price, \(S(t)\), in dollars') %to identify the axes
axis([-1 1 300 900]) %set reasonable scales for axes
print -depsc StockHistory.eps %print the plot to a .eps file

%% Estimate drift and volatility
% Although we know the past, we do not know the future.  However, we can
% use historical data to build a random (stochastic) model of the future.
% Let \(S(t)\) denote the price of this stock at time \(t\) measured in
% years.  The geometric Brownian motion model of a stock price says that 
% 
% \[ S(t+\Delta ) = S(t) \exp( \Delta m + \sigma \sqrt{\Delta} Z ), \]
%
% where 
% 
% * \(\Delta = 1/250\) is the _time increment_ (250 trading days per year), 
% * \(m\) is a constant _drift_, 
% * \(\sigma\) is the constant _volatility_, and 
% * \(Z\) is a Gaussian (normal) random variable with zero mean and unit
% variance. 
%
% For the data that we have, \((t_j,S(t_j)),\ j=-249, -248, \ldots, 0\),
% the relationship between stock prices at successive times can be written
% as
% 
% \[ \log\biggl(\frac{S(t_{j+1})}{S(t_{j})} \biggr) = \log(S(t_{j+1} )) -
% \log(S(t_j)) = \Delta m + \sigma \sqrt{\Delta} Z_j, \]
%
% where the \(Z_j\) are independent and identically distributed (IID)
% \(\mathcal{N}(0,1)\).  This means that we can estimate \(\Delta m\) and
% \(\sigma^2 \Delta\) by the sample mean and variance of the difference of
% the logged stock price data:
%
% \[ \Delta m  = \frac{1}{249} \sum_{j=-249}^{-1}
% \log\biggl(\frac{S(t_{j+1})}{S(t_{j})} \biggr), \qquad  \sigma^2 \Delta =
% \frac{1}{248} \sum_{j=-249}^{-1}
% \biggl[\log\biggl(\frac{S(t_{j+1})}{S(t_{j})} \biggr) - \Delta m
% \biggr]^2, \qquad t_j = \frac{j}{250}. \]

diffLogStockPrice = diff(log(stockPriceHistory)); %difference of the log of the stock prices
scDrift = mean(diffLogStockPrice); %sample mean
drift = scDrift/Delta %estimated drift
scVolatility = std(diffLogStockPrice); %sample standard deviation
volatility = scVolatility/sqrt(Delta) %estimated volatility

%% Simulating European call option payoffs
% In |OptionPricingExample| we plotted asset paths monitored daily out for
% half a year.  However, for pricing the European call option, we only need
% the price at the expiry time, \(T\), of a half year later, not at the
% times in between.  This simplifies the Monte Carlo simulation and reduces
% the time required.

%%
% This function generates \(n\) stock prices at the final time

timeFinal = 1/2; %final time
SVal = @(n) S0*exp(drift*timeFinal ... %the time varying part
   + volatility * sqrt(timeFinal) * randn(n,1)); %randn produces Gaussian random numbers

%%
% This function generates \(n\) discounted payoffs

K = 600; %strike price
interest = drift + volatility^2/2 %interest rate
euroCallPayoff = @(n) max(SVal(n) - K, 0) * exp(-interest * timeFinal); %discounted payoffs

%%
% Now we plot an empirical distribution of those discounted payoffs, which
% is an approximation to the cumulative distribution function of the random
% variable \(Y = \)discounted payoff

n = 1e4; %number of payoffs to plot
payoffs = euroCallPayoff(n); %generate n payoffs
sortedpay = sort(payoffs); %sort them
figure
plot(sortedpay,((1:n)-1/2)/n,'-'); %plot the empirical distribution function scenarios
xlabel('Payoff in dollars')
ylabel('CDF')
axis([0 300 0 1])
print -depsc PayoffCDF.eps %print the plot to a .eps file

%% Computing the European call option price to a desired accuracy
% The European call option is the expected value of the payoff, i.e.,
%
% \[ \text{fair price} = \mu = \mathbb{E}(Y) = \mathbb{E}(\text{discounted
% payoff}). \]
%
% We want a fixed width confidence interval, i.e., given an absolute error
% tolerance \(\varepsilon_{\text{a}}\) and a relative error tolerance
% \(\varepsilon_{\text{r}}\) we want to find \(\hat{\mu}\) such that
%
% \[ \mathbb{P}[|\mu - \hat{\mu}| \le \max(\varepsilon_{\text{a}},
% \varepsilon_{\text{r}}|\mu|) \ge 99\%. \]
%
% Using the Central Limit Theorem we can compute an approximate confidence
% interval like that above by the GAIL function |meanMC_CLT|.

absTol = 1e-1; %10 cents absolute error
relTol = 0; %no relative error
tic
[euroCallPrice,out] = meanMC_CLT(euroCallPayoff,absTol,relTol)
toc

%%
% There is an exact formula for the price of a European call option:
%
% \begin{align*}
% \text{fair price} & = \mu \\
% & = S(0) \Phi \left(\frac{\log(S(0)/K) + (r + \sigma^2/2)T}{\sigma \sqrt{T}} \right)\\
% & \qquad \qquad  -Ke^{-rT} \Phi \left(\frac{\log(S(0)/K) + (r - \sigma^2/2)T}{\sigma \sqrt{T}} \right)
% \end{align*}
%
% where \(\Phi\) is the CDF of the standard Gaussian random variable.  For
% this set of parameters is

trueEuroCallPrice = S0 * normcdf((log(S0/K) ...
   + (interest + volatility.^2/2)*timeFinal)/(volatility * sqrt(timeFinal))) ...
   - K * exp(-interest * timeFinal) * normcdf((log(S0/K) ...
   + (interest - volatility.^2/2)*timeFinal)/(volatility * sqrt(timeFinal)))

%%
% Our Monte Carlo approximation is within \(\pm \$0.1\) of the true price.
%
% We can also set a pure relative error criterion of 5 cents on 10 dollars:

absTol = 0; %No absolute error
relTol = 0.005; %0.5% relative error
tic
[euroCallPrice,out] = meanMC_CLT(euroCallPayoff,absTol,relTol)
toc

%%
% Now our Monte Carlo approximation is within \(\pm 0.005 \times \$9.889 =
% \pm \$0.05\) of the true price.
%
% _Author: Fred J. Hickernell_
