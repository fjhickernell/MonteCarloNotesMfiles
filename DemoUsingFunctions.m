%% Demo using a function to store repeated calculations

%% 
% Below is the function |plotexpax| that is used to plot \(\exp(ax)\).  The
% main function gives examples of several uses of |plotexpax|.

function DemoUsingFunctions %make it a function to not overwrite other variables
gail.InitializeDisplay

%% First plot
plotexpax(-1,[-1 1]);

%% Second plot
plotexpax(1,[-1 1]);

%% Third plot
plotexpax(1,[0 10]);

end

%% Function plotexpax
% Here is a function that we use multiple times

function plotexpax(a,xrange)
figure
xplot = xrange(1) + (0:0.001:1)*xrange(2);
plot(xplot,exp(a*xplot))
xlabel('\(x\)')
if a == 0
   ytext = '\(1\)';
elseif a == -1
   ytext = '\(\exp(-x)\)';
elseif a == 1
   ytext = '\(\exp(x)\)';
else 
   ytext = ['\(\exp(' num2str(a) 'x)\)'];
end
ylabel(ytext)
end

%%
% _Author: Fred J. Hickernell_

