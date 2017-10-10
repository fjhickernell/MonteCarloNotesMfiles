%% Publish MATH 565 Demo Scripts
% This m-file publishes as html files the sample programs used in MATH 565
% Monte Carlo Methods in Finance.
%
% First we move to the correct directory
cd(fileparts(which('PublishMATH565Demos'))) %change directory to where this is
clearvars %clear all variables
tPubStart = tic; %start timer
save('PublishTime.mat','tPubStart') %save it because clearvars is invoked by demos

%% MATH 565 Part I Introduction
% Simulation of the game of craps:
publishMathJax('CrapsSimulation')

%% 
% How to use a function for repeated operations:
publishMathJax('DemoUsingFunctions')

%%
% How to use Monte Carlo methods to price a European option:
publishMathJax('OptionPricingExample')

%%
% How to use Monte Carlo methods to model traffic flow:
publishMathJax('NagelSchreckenbergTraffic')

%%
% How to use Monte Carlo methods to compute average profit for a sandwich
% shop:
publishMathJax('SandwichShopSimulation')

%%
% How price options to a given error tolerance using CLT-based fixed width
% confidence intervals:
publishMathJax('OptionPricingMeanMC_CLT')

%%
% How CLT-based confidence intervals can fail:
publishMathJax('CLTCIfail')

%%
% How price options to a given error tolerance using a guaranteed algorithm
% for computing fixed width confidence intervals---this algorithm is in
% GAIL:
publishMathJax('OptionPricingMeanMC_g')

%%
% Confidence intervals for binomial random variables and quantiles:
publishMathJax('LateDateBinomialQuantileCI')

%%
% Demonstrates how to avoid problems of insufficient RAM in certain cases:
publishMathJax('RAMproblems')

%%
% Keister's multidimensional integration example:
publishMathJax('KeisterCubatureExample')

%%
% Multivariate normal (Gaussian) probability examble:
publishMathJax('MultivariateNormalProbabilityExample')

%%
% Simulating Brownian motions:
publishMathJax('BrownianMotionExample')

%%
% Using the GAIL classes for pricing options with (quasi-)Monte Carlo
% methods:
publishMathJax('IntroGAILOptionPricing')

%%
% The differences between handles and values:
publishMathJax('HandlesVsValues')

%% Part II Generating Random Variables and Vectors
% Generating random variables with more complicated distributions:
publishMathJax('GenerateRandomVariables')

%% Part III Pricing Options
% Pricing options with Asian type payoffs:
publishMathJax('PricingAsianOptions')

% Pricing American options:
publishMathJax('PricingAmericanOptions')

% Pricing European options with a smile and a skew:
publishMathJax('PricingSmileSkewEuropeanOptions')

%% Part IV Increasing Efficiency
% Pricing options with control variates:
publishMathJax('OptionPricingControlVariates')

% Pricing options with importance sampling:
publishMathJax('OptionPricingImportanceSampling')

% A game with importance sampling:
publishMathJax('GamewithImportanceSampling')

% Pricing options with antithetic variates:
publishMathJax('OptionPricingAntitheticVariates')

% Pricing options with quasi-Monte Carlo sampling:
publishMathJax('QuasiMonteCarloOptionPricing')

% Comparing two trading strategies
publishMathJax ATradingStrategyExample

%%
% Clean up and publish the total time taken.
load PublishTime.mat %load back tPubStart
disp('Total time required to publish all scripts is')
disp(['   ', num2str(toc(tPubStart)) ' seconds'])
delete PublishTime.mat %delete the file because it is no longer needed