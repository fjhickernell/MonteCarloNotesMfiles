%% An Example of Importance Sampling for a Game
% Consider a game where \(X_1, X_2 \overset{\textrm{IID}}{\sim}
% \mathcal{U}[0,1]\) are drawn with a payoff of 
%
% \[ 
% Y = \text{payoff}(X_1,X_2) = \begin{cases} \$100, & 1.7 \le X_1 + X_2 \le 2, \\
% 0, & 0 \le X_1 + X_2 < 1.7,
% \end{cases}
% \]
%
% What is the expected payoff of this game?

%% Vanilla Monte Carlo
% With ordinary Monte Carlo we do the following:
%
% \[ \mu = \mathbb{E}(Y) = \int_{[0,1]^2} \text{payoff}(x_1,x_2) \,
% \mathrm{d} x_1 \mathrm{d}x_2.\]

Y = @(n) 100*(sum(rand(n,2),2)>=1.7); %is sum large enough, then you win
absTol = 0.005; %half a penny tolerance
[expPay, out] = meanMC_g(Y,absTol,0);
fprintf('The expected payoff = $%3.2f +/- $%1.3f\n', ...
   expPay,absTol)
fprintf('   using %6.0f samples and %3.6f seconds\n', ...
   out.ntot,out.time)

%% Monte Carlo with Importance Sampling
% We may add the importance sampling to increase the number of samples with
% positive payoffs. Let 
%
% \[ \boldsymbol{Z} = (X_1^{1/(p+1)}, X_2^{1/(p+1)}), \qquad
% \boldsymbol{X} \sim \mathcal{U}[0,1]^2. \]
%
% This means that \(Z_1\) and \(Z_2\) are IID with common CDF \(F(z) =
% z^{p+1}\) and common PDF \(\varrho(z) = (p+1)z^{p}\).  Thus,
%
% \[ \mu = \mathbb{E}(Y) = \int_{[0,1]^2}
% \frac{\text{payoff}(z_1,z_2)}{(p+1)^2(z_1z_2)^{p}} \, \varrho(z_1)
% \varrho(z_2) \, \mathrm{d} z_1 \mathrm{d}z_2 = \int_{[0,1]^2}
% \frac{\text{payoff}(x_1^{1/(p+1)},x_2^{1/(p+1)})}{(p+1)^2(x_1x_2)^{p/(p+1)}}
% \, \mathrm{d} x_1 \mathrm{d}x_2\]

p = 1;
YIS = @(x) (100/(p+1).^2)*(sum(x.^(1/(p+1)),2)>=1.7)./ ...
   ((prod(x,2).^(p/(p+1)))); %is sum large enough, then you win
[expPay, out] = meanMC_g(@(n) YIS(rand(n,2)),absTol,0);
fprintf('Using importance sampling, the expected payoff = $%3.2f +/- $%1.3f\n', ...
   expPay,absTol)
fprintf('   using %6.0f samples and %3.6f seconds\n', ...
   out.ntot,out.time)

