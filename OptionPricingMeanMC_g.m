%% Monte Carlo Option Pricing Example Using GAIL
% This MATLAB script shows how to use the Guaranteed Automatic Integration
% Library (GAIL) to perform Monte Carlo option pricing.  The solution has a
% more rigorous foundation than CLT confidence intervals. See
% |OptionPricingExample| for some of the background of this example for the
% background of the problem.  See |OptionPricingMeanMC_CLT| for the
% solution using CLT confidence intervals.

%%
function OptionPricingMeanMC_g %make it a function to not overwrite other variables
gail.InitializeDisplay %initialize the display parameters

%% Initialize Parameters
% Rather than calibrate the model from scratch, we use the parameters
% given. 
S0 = 537.36; %initial stock price
timeFinal = 1/2; %half year to expiry
interest = 0.0050238; %interest
volatility = 0.19654; % volatility
SVal = @(n) S0*exp((interest - volatility.^2/2)*timeFinal ... %the time varying part
   + volatility * sqrt(timeFinal) * randn(n,1)); %randn produces Gaussian random numbers
K = 600; %strike price
euroCallPayoff = @(n) max(SVal(n) - K, 0) * exp(-interest * timeFinal); %discounted payoffs
trueEuroCallPrice = S0 * normcdf((log(S0/K) ...
   + (interest + volatility.^2/2)*timeFinal)/(volatility * sqrt(timeFinal))) ...
   - K * exp(-interest * timeFinal) * normcdf((log(S0/K) ...
   + (interest - volatility.^2/2)*timeFinal)/(volatility * sqrt(timeFinal)))

%% Computing the European call option price to a desired accuracy
% First we use the Central Limit Theorem confidence interval approach:

absTol = 0.05;
relTol = 0;
[euroCallPrice,out] = meanMC_CLT(euroCallPayoff,absTol,relTol);
disp(['The approximate European call price = ' ...
   num2str(euroCallPrice,'%6.3f') ' +/- ' num2str(absTol,'%4.3f') ])
disp(['   based on ' num2str(out.nSample) ' samples and ' ...
   num2str(out.time,'%4.4f') ' seconds'])

%%
% Next we use the guaranteed confidence interval 
[euroCallPrice,out] = meanMC_g(euroCallPayoff,absTol,relTol);
disp(['The approximate European call price = ' ...
   num2str(euroCallPrice,'%6.3f') ' +/- ' num2str(absTol,'%4.3f') ])
disp(['   based on ' num2str(out.ntot) ' samples and ' ...
   num2str(out.time,'%4.4f') ' seconds'])

%%
% The time is a somewhat more for |meanMC_g| because more samples are
% required, but the answer comes with a sounder justification.

%% Greater Capabilities in GAIL
% GAIL also includes some classes defined to facilitate option pricing.
% Let's set up some input parameters

inp.timeDim.timeVector = timeFinal; %just one time step
inp.wnParam.xDistrib = 'Gaussian'; %use randn
inp.assetParam.initPrice = S0; %initial stock price
inp.assetParam.interest = interest; %interest rate
inp.assetParam.volatility = volatility; %volatility
inp.payoffParam.strike = K; %strike price
inp.priceParam.absTol = absTol; %absolute tolerance criterion

%%
% Next we use the class constructor |optPrice| to create an instance of an
% the |optPrice| class with the input parameters specified and the other
% parameters kept as the defaults 

euroCallPriceObject = optPrice(inp)

%%
% Note all the properties of this object.  Here we have the exact price
% already, but in case we do not, we can use IID Monte Carlo with our
% guaranteed confidence intervals to get the price to the accuracy
% specified.

[euroCallPriceGAIL,out] = genOptPrice(euroCallPriceObject);
disp('Using the GAIL optPrice class,')
disp(['   the approximate European call price = ' ...
   num2str(euroCallPriceGAIL,'%6.3f') ' +/ ' num2str(absTol,'%4.3f') ])
disp(['   based on ' num2str(out.nPaths) ' samples and ' ...
   num2str(out.time,'%4.4f') ' seconds'])

%%
% Unfortunately, this is much slower, but it is convenient.
%
%% Teaser of the future
% Peeking ahead, one can try a faster Monte Carlo method, called Sobol'
% sampling:

euroCallPriceObject.priceParam.cubMethod = 'Sobol'
[euroCallPriceGAIL,out] = genOptPrice(euroCallPriceObject);
disp('Using the GAIL optPrice class with Sobol sampling,')
disp(['   the approximate European call price = ' ...
   num2str(euroCallPriceGAIL,'%6.3f') ' +/- ' num2str(absTol,'%4.3f') ])
disp(['   based on ' num2str(out.nPaths) ' samples and ' ...
   num2str(out.time,'%4.4f') ' seconds'])

%%
% You may need to run this program a couple of times to attain the possible
% speed, but this is a big speed up.
%
% We may even change this to become a _lookback put_ option. Now each stock
% price path is 125 steps long and the discounted payoff is
%
% \[ \Bigl [\max_{0 \le t \le T} S(t) - S(T) \Bigr] \mathrm{e}^{-rT}.\]
%
% The maximum stock price acts like the strike price.

lookbackPutPriceObject = euroCallPriceObject; %copy the European price object
lookbackPutPriceObject.timeDim.timeVector = 1/250:1/250:0.5; %daily monitoring
lookbackPutPriceObject.bmParam.assembleType = {'PCA'}; ... %PCA construction of Brownian motion
lookbackPutPriceObject.payoffParam.optType = {'look'}; ... %lookback option
lookbackPutPriceObject.payoffParam.putCallType = {'put'} %put option
[lookbackPutPriceGAIL,out] = genOptPrice(lookbackPutPriceObject);
disp('Using the GAIL optPrice class with Sobol sampling,')
disp(['   the approximate lookback put price = ' ...
   num2str(lookbackPutPriceGAIL,'%6.3f') ' +/- ' num2str(absTol,'%4.3f') ])
disp(['   based on ' num2str(out.nPaths) ' samples and ' ...
   num2str(out.time,'%4.4f') ' seconds'])

%% 
% With Sobol' sampling this is fast, but with IID Monte Carlo sampling, it
% is slow because many more paths are needed

lookbackPutPriceObject.priceParam.cubMethod = 'IID_MC';
lookbackPutPriceObject.inputType = 'n';
lookbackPutPriceObject.wnParam.xDistrib = 'Gaussian'
[lookbackPutPriceGAIL,out] = genOptPrice(lookbackPutPriceObject);
disp('Using the GAIL optPrice class with IID sampling,')
disp(['   the approximate lookback put price = ' ...
   num2str(lookbackPutPriceGAIL,'%6.3f') ' +/- ' num2str(absTol,'%4.3f') ])
disp(['   based on ' num2str(out.nPaths) ' samples and ' ...
   num2str(out.time,'%4.4f') ' seconds'])

%%
% _Author: Fred J. Hickernell_
