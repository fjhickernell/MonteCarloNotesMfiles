function coeff = dataFit(x,y)
% This is a script that takes a vector of input data and a vector of output
% data and fits a line to the data

close all %close all figures, don't need to clear variables

%% Plot data
plot(x,y,'.k','markersize',30) %plot points as dots
xlabel('x') %label the x axis
ylabel('y') %label the y axis

%% Compute and Plot the Regression Line
n = numel(x); %number of elements in x
A = [ones(n,1) x']; %create the matrix for the regression
coeff = A\y'; %compute the coefficients by least squares
xplot = [min(x) max(x)]; %x values to plot
yfit = coeff(1) + coeff(2)*xplot; %fitted y values to plot
hold on %don't erase the points
plot(xplot,yfit,'-') %plot the fitted line