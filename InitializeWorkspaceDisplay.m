%% Initialize the workspace and set the display parameters
% These settings clean up the workspace and make the display beautiful.

format compact %eliminate blank lines in output
close all %close all figures
clearvars %clear all variables
set(0,'defaultaxesfontsize',24,'defaulttextfontsize',24, ... %make font larger
      'defaultLineLineWidth',3, ... %thick lines
      'defaultLineMarkerSize',40) %big dots
LatexInterpreter %LaTeX interpreted axis labels, tick labels, and legends
