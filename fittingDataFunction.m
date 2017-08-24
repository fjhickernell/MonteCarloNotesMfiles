function coeff = fittingDataFunction(x,y)
% Plot first
close all %close all figures
plot(x,y,'.','markersize',30)
xlabel('x') %label the x axis
ylabel('y') %label the y axis

% First we fit a line to this data
n = numel(x); %number of elements in x
A = [ones(n,1) x']; %create the matrix for the regression
coeff = A\y'; %compute the coefficients by least squares 
xplot = 2:0.01:10; %points where we want to evaluate fitted model
yfit = coeff(1) + coeff(2)*xplot; %fitted model 
hold on %don't erase the points 
plot(xplot,yfit,'-') %plot the linear fit