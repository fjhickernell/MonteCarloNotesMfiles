%% CLT-Based Confidence Intervals Can Fail
% In many cases, one can successfully use the Central Limit Theorem (CLT)
% to compute a confidence interval or to build an automatic Monte Carlo
% algorithm.  See |OptionPricingMeanMC_CLT| for an example.  However, an
% analysis based on the CLT is heuristic, not rigorous.  This example
% points to how CLT based confidence intervals might fail.

%%

function CLTCIfail %make it a function to not overwrite other variables
gail.InitializeDisplay %initialize the display parameters

%% The test case
% Consider the case of \(Y = X^p\) where \(X \sim \mathcal{U}(0,1)\).  Then
% we can compute that 
%
% \begin{gather*}
% \mu = \int_0^1 x^p \, {\rm d} x  = \frac{1}{p+1}, \qquad \text{provided }
% p > -1, \\
% \mathbb{E}(Y^2) = \int_0^1 x^{2p} \, {\rm d} x  = \frac{1}{2p+1}, \qquad \text{provided }
% p > -1/2, \\
% \text{var}(Y) = \mathbb{E}(Y^2) - \mu^2  = \frac{p^2}{(2p+1)(p+1)^2}, \qquad \text{provided }
% p > -1/2.
% \end{gather*}

%% Set up parameters
% Now we try using |meanMC_CLT| on this test case

absTol = 0.01; %error tolerance
alpha = 0.01; %uncertainty
Ntry = 5000; %number of trials
Y=@(n,p) rand(n,1).^p; %Y=X^p where X is standard uniform
mu = @(p) 1/(p+1); %true answer
muhat(Ntry,1) = 0; %initialize

%% Run the simulation for a nice \(p\)
p = 0.4; %should be >-1 for mu to be finite, and >-0.5 for var(Y) to be finite
tic
for j = 1:Ntry %perform Monte Carlo Ntry times
    [muhat(j),out]=meanMC_CLT(@(n) Y(n,p),absTol,0,alpha); %estimated mu using CLT confidence intervals
end
err = abs(mu(p)-muhat); %compute true error
fail = mean(err>absTol); %proportion of failures to meet tolerance
toc %compute elapsed time
disp(['For Y = X.^' num2str(p)])
disp('   with X distributed uniformly on [0, 1]')
disp(['For an uncertainty = ' num2str(100*alpha) '%' ])
disp(['            nsigma = ' int2str(out.nSig)])
disp(['  inflation factor = ' num2str(out.CM.inflate)])
disp(['         tolerance = ' num2str(absTol)])
disp(['         true mean = ' num2str(mu(p))])
disp('The CLT-based confidence interval')
disp(['   fails ' num2str(100*fail) '% of the time ' ...
   'for ' num2str(Ntry) ' trials'])
disp(' ')

%%
% This case works pretty well.

%% Run the simulation again for a bad \(p\)
p = -0.4; %should be >-1 for mu to be finite, and >-0.5 for var(Y) to be finite
tic
for j = 1:Ntry %perform Monte Carlo Ntry times
    [muhat(j),out]=meanMC_CLT(@(n) Y(n,p),absTol,0,alpha); %estimated mu using CLT confidence intervals
end
err = abs(mu(p)-muhat); %compute true error
fail = mean(err>absTol); %proportion of failures to meet tolerance
toc %compute elapsed time

%% Display results
disp(['For Y = X.^' num2str(p)])
disp('   with X distributed uniformly on [0, 1]')
disp(['            nsigma = ' int2str(out.nSig)])
disp(['  inflation factor = ' num2str(out.CM.inflate)])
disp(['         tolerance = ' num2str(absTol)])
disp(['         true mean = ' num2str(mu(p))])
disp('The CLT-based confidence interval')
disp(['   fails ' num2str(100*fail) '% of the time ' ...
   'for ' num2str(Ntry) ' trials'])

%%
% In this case the algorithm fails more than 1% of the time because the
% variance estimates are not accurate.  One can check that the variance of
% the variance is infinite.
%
% _Author: Fred J. Hickernell_



