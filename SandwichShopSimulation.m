%% Sandwich Shop Simulation
% Here we look at the case of a restaurant modeling its operations.  We can
% see how the different parameter settings affect the average profit.

%% Initializing the workspace and setting the display parameters
% These settings clean up the workspace and make the display beautiful.

format compact %eliminate blank lines in output
close all %close all figures
clearvars %clear all variables
set(0,'defaultaxesfontsize',24,'defaulttextfontsize',24, ... %make font larger
      'defaultLineLineWidth',3, ... %thick lines
      'defaultLineMarkerSize',40, ... %big dots
      'defaultTextInterpreter','latex', ... %LaTeX interpreted axis labels
      'defaultLegendInterpreter','latex') %and legends

%% Sandwich Shop Parameters
% A sandwich shop orders \(O\) sandwiches each day at a fixed price of
% \(W\) dollars.  They sell them at a price of \(R\) dollars.  The demand
% for sandwiches, \(D\), is a random variable that is \(\mathcal{U}\{5, 6,
% \ldots, 35\}\).  How much profit will be made on average?
%
% We may simulate \(n\) replications of \(m\) consecutive days:

tic;
whole = 3; %wholesale price of sandwich
retail = 5; %retail price of sandwich
order = 20; %quantity of sandwiches ordered daily
demandlo = 5; %lo end of demand
demandhi = 35; %hi end of demand
ndays = 3*365; %number of days for simulation
ndvec = (1:ndays)'; %vector of 1 to number of days
nreps = 10000; %number of reptitions
nrvec = (1:nreps)'; %number of reptitions of the simulation

%% Perform simulation
% The number of sandwiches sold, \(S\), is the minimum of the demand, and
% the number ordered, i.e., 
%
% \[
% S = \min(D,O).
% \]
%
% The profit, \(P\) each day is the difference between the income and the expense:
% 
% \[
% P = S \times R - O \times W
% \]
%
% In our case we are computing \(P_{ij}\) for \(i=1, \ldots, n\) and \(j =
% 1, \ldots, m\).  Then we compute the average profit of \(m\) days for
% each run \(i\).

demand = randi([demandlo,demandhi],nreps,ndays); %uniform random numbers for demand
sold = min(demand,order); %amount of sandwiches sold that day
dayprofit = sold*retail-order*whole; %profit for the day
avgprofitrun = mean(dayprofit,2); %average profit for the first m days
avgprofit = mean(avgprofitrun); %average profit over all runs and days
toc

%% Output results
% We output the results of our simulation.  Notice how the sample average
% converges as the number of replications increases.
%Numerical output
disp(['For ' int2str(nreps) ' replications of'])
disp(['    ' int2str(ndays) ' days of business'])
disp(['    sandwiches costing $' num2str(whole,' %6.2f') ' apiece'])
disp(['    and sold for $' num2str(retail,' %6.2f') ' apiece'])
disp(['For a supply of ' int2str(order) ' sandwiches ordered daily'])
disp('and a random demand that is uniform over a range of')
disp(['   {' int2str(demandlo) ',...,' ...
    int2str(demandhi), '} sandwiches'])
disp(['The average daily profit over this whole time = $' ...
    num2str(avgprofit,' %6.2f')])
disp(['   compared to the maximum possible profit of $' ...
    num2str(order*(retail-whole),' %6.2f')])
disp(' ');

%Plot daily and cumulative average profit
semilogx((1:nreps)',cumsum(avgprofitrun)./(1:nreps)','-');
set(gca,'xtick',10.^(0:ceil(log10(nreps))));
xlabel('Number of Replications'); ylabel('Avg Daily Profit')

%% Saving sandwiches
% In the above example, the daily profits are independent random variables.
% Suppose that we consider the case where sandwiches may be saved for one
% day, and we sell the old sandwiches first.  Then the daily profits are
% _dependent_ random variables.  The modified simulation is as follows

sold(:,1) = min(demand(:,1),order); %sandwiches sold the first day, none leftover from the day before
remain(:,1) = order - sold(:,1); %sandwiches leftover
for j = 2:ndays
   sold(:,j) = min(demand(:,j),order + remain(:,j-1)); %amount of sandwiches sold that day
   remain(:,j) = order + min(remain(:,j-1) - sold(:,1),0); %cannot keep sandwiches more than one day
end
dayprofit=sold*retail-order*whole; %profit for the day
avgprofitrun=mean(dayprofit,2); %average profit for the first m days
avgprofit=mean(avgprofitrun); %average profit over all runs and days
toc

%Numerical output
disp(['For ' int2str(nreps) ' replications of'])
disp(['    ' int2str(ndays) ' days of business'])
disp(['    sandwiches costing $' num2str(whole,' %6.2f') ' apiece'])
disp(['    and sold for $' num2str(retail,' %6.2f') ' apiece'])
disp('Sandwiches can be kept for tomorrow.')
disp(['For a supply of ' int2str(order) ' sandwiches ordered daily'])
disp('and a random demand that is uniform over a range of')
disp(['   {' int2str(demandlo) ',...,' ...
    int2str(demandhi), '} sandwiches'])
disp(['The average daily profit over this whole time = $' ...
    num2str(avgprofit,' %6.2f')])
disp(['   compared to the maximum possible profit of $' ...
    num2str(order*(retail-whole),' %6.2f')])
disp(' ');

%Plot daily and cumulative average profit
semilogx((1:nreps)',cumsum(avgprofitrun)./(1:nreps)','-');
set(gca,'xtick',10.^(0:ceil(log10(nreps))));
xlabel('Number of Replications'); ylabel('Avg Daily Profit')

%%
% _Author: Fred J. Hickernell_


    