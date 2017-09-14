%% Demonstration of RAM problems
% The time required by a Monte Carlo computation is often proportional to
% the number of samples required. However, when the size of the variables
% get too large, then the computation may be slowed way down by the act of
% writing the variables to the hard drive. This script demonstrates the
% problems and a potential workaround.

%%
function RAMproblems %make it a function to not overwrite other variables
gail.InitializeDisplay %initialize the display parameters

%% The mean of the sum of IID \(\mathcal{U}[0,1]\) random variables
% Let
%
% \[ Y = X_1 + \cdots + X_d, \quad X_j \overset{\text{IID}}{\sim}
% \mathcal{U}[0,1]. \]
%
% and note that \(\mathbb{E}(Y) = d/2\).  We may also calculate this using
% |meanMC_g|

abstol = 0.02; %absolute error tolerance
reltol = 0; %relative error tolerance
d = 30; %set d value
[muhat,out] = meanMC_g(@(n) sum(rand(n,d),2),abstol,reltol);
disp(['The mean = ' num2str(muhat,'%7.2f') ' +/- ' num2str(abstol,'%3.2f')])
disp(['Number of samples required = ' int2str(out.ntot)]) %number of samples required
disp(['             Time required = ' num2str(out.time) '  seconds']) %time required

%%
% This problem only requires about \(160\,000\) samples.
%
% If we increase \(d\) we still get the correct answer

d = 300; %set d value
[muhat,out] = meanMC_g(@(n) sum(rand(n,d),2),abstol,reltol);
disp(['The mean = ' num2str(muhat,'%7.2f') ' +/- ' num2str(abstol,'%3.2f')])
disp(['Number of samples required = ' int2str(out.ntot)]) %number of samples required
disp(['             Time required = ' num2str(out.time) '  seconds']) %time required

%%
% but now the time required is about \(50\) times a long.  This can be
% explained by the fact that the number of samples required is about
% \(5\) times as many and that \(d\) is now \(10\) times as large, so we
% need \(5 \times 10 = 50\) times as many random numbers to complete the
% calculation.
%
% If \(d\) is increased to \(3000\), then we get an error in MATLAB because
% we are trying to create an \(n \times d\) array in RAM, that is too big.
% We cannot complete the calculation, and an error message is issued.

try 
   d = 3000; %set d value
   [muhat,out] = meanMC_g(@(n) sum(rand(n,d),2),abstol,reltol);
catch ME
   disp(getReport(ME))
end


%% A way around RAM problems
% The workaround is to write a function that creates \(m \times d\) arrays
% of uniform random nubers for \(m\) much smaller than \(n\), and only
% stores the \(Y_i\).  This involves for loops.
%
% <include>sumUnifRand.m</include>

d = 3000; %set d value
[muhat,out] = meanMC_g(@(n) sumUnifRand(n,d),abstol,reltol);
disp(['The mean = ' num2str(muhat,'%7.2f') ' +/- ' num2str(abstol,'%3.2f')])
disp(['Number of samples required = ' int2str(out.ntot)]) %number of samples required
disp(['             Time required = ' num2str(out.time) '  seconds']) %time required

%%
% Even though the number of samples required overruns the time budget, at
% least the computation can be completed.
