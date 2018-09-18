%% Crowded Mayor Election
% Some elections, such as the Chicago mayoral election, attract a large
% number of candidates.  If no candidate receives a majority of votes in
% the first election, then there is a run-off of the top two candidates.
%
% Since not all voters vote, one may wonder if the two top preferred
% candidates will actually be chosen in the initial election.  We will
% explore the probability of that happening.

%%
function CrowdedMayoralElection

%% Set Up Candidates
% First we set the probabilities of a voter choosing each of many
% candidates.  Note that the top three candidates have similar
% probabilities.

PMF = [0.13 0.13 0.125:-0.01:0.05];
PMF = [PMF 1-sum(PMF)] %probability mass function for candidates
totalProb = sum(PMF) %check that the sum is one
CDF = cumsum(PMF); %cumulative distribution function
nTrials = 1e4; %number of trials 

%% Chicago Election
% Next we set the number of votes to be like a Chicago election.  The
% function |TwoBestWin| generates random election results.

tic
nVotes = 5e5; %number of votes in election
Yes = TwoBestWin(nTrials,nVotes,CDF); %when do top two candidates win the initial election
CI = binomialCI(nTrials,sum(Yes));
fprintf('Chance that top two will win = [%4.2f%%, %4.2f%%] \n', 100*CI)
toc

%% Suburb Election
% Next we set the number of votes to be similar to that in a suburb.  The
% function |TwoBestWin| generates random election results.

tic
nVotes = 5e3; %number of votes in election
Yes = TwoBestWin(nTrials,nVotes,CDF); %when do top two candidates win the initial election
CI = binomialCI(nTrials,sum(Yes));
fprintf('Chance that top two will win = [%4.2f%%, %4.2f%%] \n', 100*CI)
toc

function Yes = TwoBestWin(nTrials,nVotes,CDF)
Yes(nTrials,1) = 0; %initialize Yes
nCandidate = size(CDF,2); %number of candidates
vote(nCandidate,1) = 0; %initialize votes
for ii = 1:nTrials
   votes = sum(rand(nVotes,1) > CDF,2) + 1;
   for i = 1:nCandidate
      vote(i) = sum(votes == i);
   end
   Yes(ii) = all(vote(1) > vote(3:nCandidate)) && ...
      all(vote(2) > vote(3:nCandidate));
end

