%% Fitting Data Using Regression and Splines
% This is a script that takes a vector of input data and a vector of output
% data and fits a line or curve to the data.

%% Clean Up
clearvars %clear all variables
close all %close all figures

%% Input Data and Plot It
% The values of x and y are somewhat _arbitrary_.  You may change them.
x = 3:9; %set x to be a vector of inputs
y = [-2 3 4 6 13 14 16]; %a vector of outputs
plot(x,y,'.k','markersize',30) %plot points as dots
xlabel('x') %label the x axis
ylabel('y') %label the y axis

%% Compute and Plot the Regression Line
% First we fit a line to this data
n = numel(x); %number of elements in x
A = [ones(n,1) x'] %create the matrix for the regression
coeff = A\y' %compute the coefficients by least squares
xplot = 2:0.01:10; %points where we want to evaluate fitted model
yfit = coeff(1) + coeff(2)*xplot; %fitted model
hold on %don't erase the points
plot(xplot,yfit,'-') %plot the linear fit

%% Fit a Regression Polynomial
% Next we fit a polynomial of degree |p|.  If |p| is less than |n|, then
% the fit is approximate.
p = 3; %degree of the polynomial
A = bsxfun(@power,x',(0:3)); %the corresponding matrix for regression
coeffpoly = A\y' %compute the coefficients by least squares
ypolyfit = (bsxfun(@power,xplot',(0:3))*coeffpoly)'; %the fitted values of y
plot(xplot,ypolyfit,'-') %plot the polynomial fit

%%
% _Author: Fred J. Hickernell_

