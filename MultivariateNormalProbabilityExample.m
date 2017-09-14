%% Multivariate Normal Probabilities
% The multivariate normal probability is defined as 
%
% \[
% p = \int_{[\boldsymbol{a},\boldsymbol{b}]} 
% \frac{\exp\bigl((\boldsymbol{x} - \boldsymbol{\mu})^T \Sigma^{-1} 
% (\boldsymbol{x} - \boldsymbol{\mu})/2\bigr)}
% {\sqrt{(2\pi)^d \textrm{det}(\Sigma)}} \, \mathrm{d} \boldsymbol{x}.
% \]
%
% where \(\boldsymbol{a}\), \(\boldsymbol{b}\), \(\boldsymbol{\mu}\), and
% \(\Sigma\) are parameters. Except for very special cases of these
% parameters, \(p\) must be approximated numerically.

%%
function MultivariateNormalProbabilityExample %make it a function to not overwrite other variables
gail.InitializeDisplay %clean up 
format long

%% Parameter Set-Up
% Let's set up one example to look at
C = [4 1 1; 0 1 0.5; 0 0 0.25];
Sigma = C'*C %the covariance matrix
mu = 0; %mean of the distribution
a = [-6 -2 -2]; %lower left corner of the hyperbox
b = [5 2 1]; %upper right coner of the hyperbox
alpha = 0.01; %uncertainty
absTol = 2e-4; %absolute error tolerance
errMeth = 'g'; %use adaptive method to automatically meet tolerance

%% 
% The class |multivarGauss| has been constructed to compute the above
% probability via different methods.  We will illustrate some of methods
% below.  There is an important transformation by Alan Genz, that turns
% this \(d\)-dimensional integeral over \([\boldsymbol{a},
% \boldsymbol{b}]\) into a \(d-1\)-dimensional integeral over \([0,
% 1]^{d-1}\).  We will use this for most of our examples

%% IID sampling
% First we try IID sampling.
[MVNProbIID] = multivarGauss('a',a,'b',b,'Cov',Sigma, 'errMeth',errMeth, ...
   'cubMeth','IID','intMeth','Genz','absTol',absTol) %set up object
[MVNProbIIDprob, IIDOut] = compProb(MVNProbIID); %compute probability
fprintf(['The probability is %2.6f +/- %1.6f via IID sampling \n' ...
   '   which takes %3.6f seconds and %8.0f samples.\n'], ...
   MVNProbIIDprob, absTol, IIDOut.time, IIDOut.ntot)

%% Scrambled Sobol sampling
% Next we try scrambled Sobol Sampling
MVNProbSobol = multivarGauss('a',a,'b',b,'Cov',Sigma, 'errMeth',errMeth, ...
   'cubMeth','Sobol','intMeth','Genz','absTol',absTol) %set up object
[MVNProbSobolprob, SobolOut] = compProb(MVNProbSobol); %compute probability
fprintf(['The probability is %2.6f +/- %1.6f via IID sampling \n' ...
   '   which takes %3.6f seconds and %8.0f samples.\n'], ...
   MVNProbSobolprob, absTol, SobolOut.time, SobolOut.n)

%% Shifted lattice sampling
% Next we try shifted lattice Sampling
MVNProbLattice = multivarGauss('a',a,'b',b,'Cov',Sigma, 'errMeth',errMeth, ...
   'cubMeth','lattice','intMeth','Genz','absTol',absTol) %set up object
[MVNProbLatticeprob, latticeOut] = compProb(MVNProbSobol); %compute probability
fprintf(['The probability is %2.6f +/- %1.6f via IID sampling \n' ...
   '   which takes %3.6f seconds and %8.0f samples.\n'], ...
   MVNProbLatticeprob, absTol, latticeOut.time, latticeOut.n)

%%
% _Author: Fred J. Hickernell_

