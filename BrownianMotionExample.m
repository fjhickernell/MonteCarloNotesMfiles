%% Brownian Motions 
% A Brownian motion, \(B\), is a _random_ function that satisfies the
% following properties:
%
% \begin{align*}
% B(0) & = 0 \text{ with probability one}, \\
% B(\tau) \text{ and } B(t) - B(\tau) 
% &\text{ are independent for all } 0 \le \tau \le t.\\
% B(t) - B(\tau) &\sim \mathcal{N}(0,t - \tau) 
% \quad \text{for all } 0 \le \tau \le t.
% \end{align*}
%
% This script shows what Brownian motion paths look like and how to
% generate them using the GAIL |brownianMotion| class.

%% Using GAIL to generate some Brownian motion paths
% The |develop| branch of the GAIL repository has a |brownianMotion| class.
%  To generate some paths we first set the parameters

function BrownianMotionExample %keep workspace safe
gail.InitializeDisplay %initialize the display parameters
tic
inp.timeDim.timeVector = 0.004:0.004:1; %time increments of 0.004 up to time 1
ourBrownianMotion = brownianMotion(inp) %construct a Brownian motion object
whos %note that its class is shown
methods(ourBrownianMotion) %these are the methods that can be used to operate on this object

%%
% We have not generated any Brownian motion paths, only constructed the
% class that generates samples of Brownian motions.  Note that the
% properties of this class are that it uses IID sampling and a
% time-differencing scheme, namely
%
% \[ B(0) = 0, \qquad B(t_j) = B(t_{j-1}) + \sqrt{t_j - t_{j-1}} Z_j, 
% \quad Z_1, Z_2, \ldots \text{ IID } \mathcal{N(0,1)}. 
% \]
%
% Next we use the |plot| method to plot some paths.

nplot = 20; %number of paths to plot
figure
plot(ourBrownianMotion,nplot) %plot n paths
xlabel('Time')
ylabel('Brownian Motion Paths')
print -depsc BrownianMotionPaths.eps

%%
% Notice that each path is different.

%% Statistics of the Brownian motion paths
% We can check that the sample charateristics of these paths mirror the
% population characeristics.  Let's generate some paths with the |genPaths|
% method:

n = 1e4; %number of paths to generate
bmPaths = genPaths(ourBrownianMotion,n); %an n by 250 matrix of numbers
whos

%%
% Now we check the sample characteristics and how much they differ from
% what they should be

largestMean = max(abs(mean(bmPaths))) %this should be close to zero
covBMPaths = cov(bmPaths); %this should be close to min(t_i,t_j)
worstCov = max(max(abs(covBMPaths ...
   - bsxfun(@min,ourBrownianMotion.timeDim.timeVector', ...
   ourBrownianMotion.timeDim.timeVector)))) %this should be close to zero

%% Another Construction method
% We may also construct Brownian motions using a principal component
% analysis (PCA) method.  For IID sampling there is not much difference,
% but for low discrepancy (Sobol', lattice) sampling, this method might be
% better.

ourPCA_BM = brownianMotion(ourBrownianMotion); %make a new copy
ourPCA_BM.bmParam.assembleType = 'PCA'; %change the construction method
figure 
plot(ourPCA_BM,nplot) %plot n paths
xlabel('Time')
ylabel('Brownian Motion Paths')
print -depsc BrownianMotionPaths.eps
bmPaths = genPaths(ourPCA_BM,n); %an n by 250 matrix of numbers
largestMean = max(abs(mean(bmPaths))) %this should be close to zero
covBMPaths = cov(bmPaths); %this should be close to min(t_i,t_j)
worstCov = max(max(abs(covBMPaths ...
   - bsxfun(@min,ourPCA_BM.timeDim.timeVector', ...
   ourPCA_BM.timeDim.timeVector)))) %this should be close to zero
toc

%%
% _Author: Fred J. Hickernell_
