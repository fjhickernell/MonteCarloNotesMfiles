%% Pricing Options Using Quasi-Monte Carlo Sampling
% Most of our Monte Carlo methods have relied on independent and
% identically distributed (IID) samples.  But we can often compute the
% answer faster by using _low discrepancy_ or _highly stratified_ samples.
% This demo shows the advantages for some of the option pricing problems
% that have been studied using IID sampling.

%% Different sampling strategies
% We consider the problem of sampling uniformly on the unit cube, \([0,1]^d\). 
% For illustration we choose \(d = 2\).  Here are \(n=256\) IID samples

gail.InitializeWorkspaceDisplay %initialize the workspace and the display parameters
d = 2; %dimension
n = 256; %number of samples
xIID = rand(n,d); %uniform (quasi-)random numbers
plot(xIID(:,1),xIID(:,2),'.') %plot the points 
xlabel('$x_1$') %and label
ylabel('$x_2$') %the axes
title('IID points')
axis square %make the aspect ratio equal to one

%%
% Since the points are IID, there are gaps and clusters.  The points do not
% know about the locations of each other.

%% Shifted lattice node sets
% One set of more _evenly_ distributed points are node sets of _integration
% lattices_.  They look like a tilted grid. Here is an example with a shift
% modulo one.

figure
xLattice = mod(bsxfun(@plus,gail.lattice_gen(1,n,d),rand(1,d)),1); %the first n rank-1 lattice node sets, shifted
plot(xLattice(:,1),xLattice(:,2),'.') %plot the points 
xlabel('$x_1$') %and label
ylabel('$x_2$') %the axes
title('Rank-1 lattice node set')
axis square %make the aspect ratio equal to one

%%
% Now the gaps are smaller and the clusters are less dense.  The points
% _do_ know about the locations of each other, so they are _dependent_.

%% Scrambled Sobol' points
% Another way to sample more _evenly_ is to use Sobol' points.  Here is a
% plot of the same number of _scrambled and shifted_ Sobol' points. They
% are also random, but not IID.

figure
sob = scramble(sobolset(d),'MatousekAffineOwen'); %create a scrambled Sobol object
xSobol = net(sob,n); %the first n points of a Sobol' sequence
plot(xSobol(:,1),xSobol(:,2),'.') %plot the points 
xlabel('$x_1$') %and label
ylabel('$x_2$') %the axes
title('Sobol'' points')
axis square %make the aspect ratio equal to one

%% Pricing the Asian Arithmetic Mean Call Option
% Now we set up the parameters for option pricing.  We consider first the
% Asian Geometric Mean Call with weeky monitoring for three months

inp.timeDim.timeVector = 1/52:1/52:1/4; %weekly monitoring for three months
inp.assetParam.initPrice = 100; %initial stock price
inp.assetParam.interest = 0.02; %risk-free interest rate
inp.assetParam.volatility = 0.5; %volatility
inp.payoffParam.strike = 100; %strike price
inp.payoffParam.optType = {'amean'}; %looking at an arithmetic mean option
inp.payoffParam.putCallType = {'call'}; %looking at a put option
inp.priceParam.absTol = 0.005; %absolute tolerance of a one cent
inp.priceParam.relTol = 0; %zero relative tolerance

%% 
% The first method that we try is simple IID sampling

AMeanCallIID = optPrice(inp) %construct an optPrice object 
[AMeanCallIIDPrice,AoutIID] = genOptPrice(AMeanCallIID);
fprintf(['The price of the Asian geometric mean call option using IID ' ...
   'sampling is \n   $%3.3f +/- $%2.3f and this took %10.0f paths and %3.6f seconds\n'], ...
   AMeanCallIIDPrice,AMeanCallIID.priceParam.absTol,AoutIID.nPaths,AoutIID.time)

%%
% Note that in this case we know the correct answer, and our IID Monte
% Carlo gives the correct answer.
% 
% Next we try Sobol' sampling and see a big speed up:

AMeanCallSobol = optPrice(AMeanCallIID); %make a copy of the IID optPrice object
AMeanCallSobol.priceParam.cubMethod = 'Sobol' %change to Sobol sampling
[AMeanCallSobolPrice,AoutSobol] = genOptPrice(AMeanCallSobol);
fprintf(['The price of the Asian geometric mean call option using Sobol'' ' ...
   'sampling is\n   $%3.3f +/- $%2.3f and this took %10.0f paths and %3.6f seconds,\n' ...
   'which is only %1.5f the time required by IID sampling\n'], ...
   AMeanCallSobolPrice,AMeanCallSobol.priceParam.absTol,AoutSobol.nPaths, ...
   AoutSobol.time,AoutSobol.time/AoutIID.time)

%%
% Again the answer provided is correct.  For a greater speed up, we may use
% the PCA construction, which reduces the effective dimension of the
% problem.

AMeanCallSobol.bmParam.assembleType = 'PCA'; %change to a PCA construction
[AMeanCallSobolPrice,AoutSobol] = genOptPrice(AMeanCallSobol);
fprintf(['The price of the Asian geometric mean call option using Sobol'' ' ...
   'sampling and PCA is\n   $%3.3f +/- $%2.3f and this took %10.0f paths and %3.6f seconds,\n' ...
   'which is only %1.5f the time required by IID sampling\n'], ...
   AMeanCallSobolPrice,AMeanCallSobol.priceParam.absTol,AoutSobol.nPaths, ...
   AoutSobol.time,AoutSobol.time/AoutIID.time)

%% 
% Another option is to use lattice sampling.

AMeanCallLattice = optPrice(AMeanCallSobol); %make a copy of the IID optPrice object
AMeanCallLattice.priceParam.cubMethod = 'lattice' %change to lattice sampling
[AMeanCallLatticePrice,AoutLattice] = genOptPrice(AMeanCallLattice);
fprintf(['The price of the Asian geometric mean call option using lattice ' ...
   'sampling is\n   $%3.3f +/- $%2.3f and this took %10.0f paths and %3.6f seconds,\n' ...
   'which is only %1.5f the time required by IID sampling\n'], ...
   AMeanCallLatticePrice,AMeanCallLattice.priceParam.absTol,AoutLattice.nPaths, ...
   AoutLattice.time,AoutLattice.time/AoutIID.time)

%% 
% Note that the time is also less than for IID, but similar to that for
% Sobol' sampling.

%% Sobol' Sampling with Control Variates
% We can use control variates with Sobol' and lattice sampling, but it is a
% bit different than for IID sampling.  Here is an example.
AMeanCallSobolCV = optPrice(AMeanCallSobol); %make a copy of the object
AMeanCallSobolCV.payoffParam = struct( ...
   'optType',{{'amean','gmean'}},...  %Add two payoffs
   'putCallType',{{'call','call'}});  %both calls
AMeanCallSobolCV.priceParam.cubMethod = 'SobolCV'; %change method to use control variates
[AMeanCallSobolCVPrice,AoutSobolCV] = genOptPrice(AMeanCallSobolCV);
fprintf(['The price of the Asian geometric mean call option using Sobol'' ' ...
   'sampling with PCA and control variates is\n' ...
   '$%3.3f +/- $%2.3f and this took %10.0f paths and %3.6f seconds,\n' ...
   'which is only %1.5f the time required by IID sampling\n'], ...
   AMeanCallSobolCVPrice,AMeanCallSobolCV.priceParam.absTol,AoutSobolCV.nPaths, ...
   AoutSobolCV.time,AoutSobolCV.time/AoutIID.time)

%%
% The use of control variates reduces the time to compute the answer even
% further compared to Sobol' sampling without control variates.
%
% _Author: Fred J. Hickernell_
