%% Pricing Options with Importance Sampling
% Out of the money options can be priced more efficiently by adjusting the
% stock paths to generate more positive payoffs.  At the same time, these
% paths with positive payoffs will be given less weight so that the sample
% mean still approximates the true mean or true option price.
%
% This functionality is not yet implemented in the GAIL |optPrice| class,
% so we will solve the problem in a less elegant manner.

%% Initialization
% First we set up the basic common praramters for our examples.

InitializeWorkspaceDisplay %initialize the workspace and the display parameters
inp.timeDim.timeVector = 1/52:1/52:1/4; %weekly monitoring for three months
inp.assetParam.initPrice = 100; %initial stock price
inp.assetParam.interest = 0.05; %risk-free interest rate
inp.assetParam.volatility = 0.5; %volatility
inp.payoffParam.strike = 90; %strike price
inp.payoffParam.optType = {'amean'}; %looking at an arithmetic mean option
inp.payoffParam.putCallType = {'put'}; %looking at a put option
inp.priceParam.absTol = 0.01; %absolute tolerance of a one cent
inp.priceParam.relTol = 0; %zero relative tolerance

%% The Asian arithmetic mean put without importance sampling
% Next we create an Asian arithmetic mean put |optPrice| object and use
% Monte Carlo to compute the price.

AMeanPut = optPrice(inp); %construct an optPrice object 
[AMeanPutPrice,Aout] = genOptPrice(AMeanPut);
disp(['The price of the Asian arithmetic mean put option is $' ...
   num2str(AMeanPutPrice,'%5.2f')])
disp(['   and this took ' num2str(Aout.time) ' seconds'])
disp(['The total number of paths needed is ' num2str(Aout.nPaths)])

%% The Asian arithmetic mean put *with* importance sampling
% The stock price must drop significantly for the payoff to be positive.
% So we will give a downward drift to the Brownian motion that defines the
% stock price path.  We can think of the option price as the
% multidimensional integral
%
% \begin{equation*} 
% \mu = \mathbb{E}[f(\boldsymbol{X})] = \int_{\mathbb{R}^d}
% f(\boldsymbol{x}) 
% \frac{\exp\bigl(-\frac12 \boldsymbol{x}^T\mathsf{\Sigma}^{-1}
% \boldsymbol{x}\bigr)}
% {\sqrt{(2 \pi)^{d} \det(\mathsf{\Sigma})}} \, \mathrm{d} \boldsymbol{x} ,
% \end{equation*} 
%
% where
% 
% \begin{align*} 
% \boldsymbol{X} & \sim \mathcal{N}(\boldsymbol{0}, \mathsf{\Sigma}), \qquad
% \mathsf{\Sigma} = \bigl(\min(j,k)T/d \bigr)_{j,k=1}^d, \\
% d & =  13 \text{ in this case} \\
% f(\boldsymbol{x}) & = \max\biggl(K - \frac 1d \sum_{j=1}^d
% S(jT/d,\boldsymbol{x}), 0 \biggr) \mathrm{e}^{-rT}, \\
% S(jT/d,\boldsymbol{x}) &= S(0) \exp\bigl((r - \sigma^2/2) jT/d +
% \sigma x_j\bigr).
% \end{align*} 
%
% We will replace \(\boldsymbol{X}\) by 
%
% \[ \boldsymbol{Z} \sim \mathcal{N}(\boldsymbol{a}, \mathsf{\Sigma}),
% \qquad \boldsymbol{a} = (aT/d)(1, \ldots, d)
% \]
%
% where a negative \(a\) will create more positive payoffs.  This
% corresponds to giving our Brownian motion a drift.  To do this we
% re-write the integral as 
%
% \begin{gather*} 
% \mu = \mathbb{E}[\tilde{f}(\boldsymbol{Z})] 
% = \int_{\mathbb{R}^d}
% \tilde{f}(\boldsymbol{z}) 
% \frac{\exp\bigl(-\frac12 (\boldsymbol{z}-\boldsymbol{a})^T
% \mathsf{\Sigma}^{-1}
% (\boldsymbol{z} - \boldsymbol{a}) \bigr)}
% {\sqrt{(2 \pi)^{d} \det(\mathsf{\Sigma})}} \, \mathrm{d} \boldsymbol{z} ,
% \\
% \tilde{f}(\boldsymbol{z}) = 
% f(\boldsymbol{z}) 
% \frac{\exp\bigl(-\frac12 \boldsymbol{z}^T
% \mathsf{\Sigma}^{-1} \boldsymbol{z} \bigr)}
% {\exp\bigl(-\frac12 (\boldsymbol{z}-\boldsymbol{a})^T
% \mathsf{\Sigma}^{-1}
% (\boldsymbol{z} - \boldsymbol{a}) \bigr)}
% = f(\boldsymbol{z}) \exp\bigl((\boldsymbol{a}/2 - \boldsymbol{z})^T
% \mathsf{\Sigma}^{-1}\boldsymbol{a} \bigr)
% \end{gather*} 
%
% Finally note that 
%
% \[ \mathsf{\Sigma}^{-1}\boldsymbol{a} = \begin{pmatrix} 0 \\ 0 \\ \vdots
% \\ 0 \\ a \end{pmatrix}, \qquad \tilde{f}(\boldsymbol{z}) =
% f(\boldsymbol{z}) \exp\bigl((aT/2 - z_d)a \bigr) \]
%
% Since this functionality is not available in GAIL yet, we need to create
% our own function that generates the payoffs from the drifted Brownian
% motion and the multiplies by the weights. We have written such a
% function:
%
% <include>YoptPrice_IS.m</include>
%
% In the future, this function should not be needed because GAIL will
% contain this functionality.
%
% Now we call |meanMC_g|:
%

drift = -2; %the amount of the drift
[AMeanPriceIS, AISout] = meanMC_g(@(n) YoptPrice_IS(AMeanPut,n,drift), ...
   inp.priceParam.absTol, inp.priceParam.relTol);
disp(['The price of the Asian arithmetic mean put option is $' ...
   num2str(AMeanPriceIS,'%5.2f')])
disp(['   and this took ' num2str(AISout.time) ' seconds,'])
disp(['   which is ' num2str(AISout.time/Aout.time) ...
   ' of the time without importance sampling'])
disp(['The total number of paths needed is ' num2str(AISout.ntot)])

%% 
% Note that the price is the same, but the time required is much less.
% Unfortunately, it is difficult to know in advance what the optimal drift
% is.
%
% _Author: Fred J. Hickernell_
