%% Late for a Date
% This example demonstrates the confidence intervals for probabilities
% assuming that you must take different modes of transportation to get to
% your date.
%
% Suppose that you leave your office and walk to the parking lot.  You then
% drive to Chinatown, park your car, and walk to Ming Hin restaurant to
% meet your friends.  For illustration purposes, we assume that 
%
% \begin{align*}
% T_1  &= \text{ time to walk to your car } \sim \mathcal{U}[4,7], \\
% T_2  &= \text{ time to drive to Chinatown } \sim \mathcal{U}[10,15], \\
% T_3  &= \text{ time to find a parking spot } \sim \mathcal{U}[0,12], \\
% T_4  &= \text{ time to walk to Ming Hin } \sim \mathcal{U}[2,8], \\
% T_{\text{total}}  &= \text{ total travel time } = T_1 + T_2 + T_3 + T_4.
% \end{align*}
% 
% All times are given in minutes.  We want to know what is the probability
% of needing more than $35$ minutes to get to the restaurant from your
% office.

InitializeWorkspaceDisplay %initialize the workspace and the display parameters

%% Simulating travel times
% First we construct a function that generates IID travel times.  If $U_1,
% \ldots, U_4$ are IID $\mathcal{U}[0,1]$ random variables, then 
%
% \begin{align*}
% T_1  &= 4 + 3 U_1, \\
% T_2  &= 10 + 5 U_2, \\
% T_3  &= 12 U_3, \\
% T_4  &= 2 + 6 U_4, \\
% T_{\text{total}}  & = T_1 + T_2 + T_3 + T_4 = 16 + 3U_1 + 5U_2 + 12U_3 + 6 U_4.
% \end{align*}

Ttot = @(n) 16 + sum(bsxfun(@times,rand(n,4),[3 5 12 6]),2);

%%
% The average travel time is 
% 
% \[
% \mu  = \mathbb{E}(T_{\text{total}}) = 16 + (3 + 5 + 12 + 6) \mathbb{E}(U)
% = 16 + 26 \times 1/2 = 29.
% \]
%
% Monte Carlo methods can be used to approximate this as well:

muhat = meanMC_g(Ttot,0.01,0)

%% Computing the probability of being late
% We now perform \(n\) trials, and count the number of late dates.  Then we
% use _binomialCI_ to compute a confidence interval on the probability of
% being late for the date.  

n = 1e3; %number of samples
lateTime = 35; %what is considered late
Ttotval = Ttot(n);
lateDateBinCI = binomialCI(n,sum(Ttotval > lateTime))

%%
% The chance is of being late is between \(6\%\) and \(11\%\).

%% Computing the cut-off time for being on time with a high probability
% A related problem is determining how late we can leave our office and
% still get to the restaurant on time with a high probability.  Again we
% use 

p = 0.02; %the probability of lateness that can be tolerated
extremeVal = [16 42]; %the extreme values of the distribution
lateDateQuantCI = quantileCI(1-p,Ttotval,extremeVal)

%%
% The worst \(2\%\) is around \(36.7\) to \(38\) minutes.  You need to
% allow \(38\) minutes to make sure that you will be on time with at least
% a \(98\%\) probability.

