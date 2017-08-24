classdef dataFitClass
   %DATAFITClASS is a class that contains data and that fits and plots the data 
   
   properties %these properties need to be input
      x = 3:9 %input data
      y = [-2 3 4 6 13 14 16]; %output data
   end
   
   properties (Dependent) %these properties are dependent on the input
      n %number of elements
      yfit %fitted regression line
   end
      
   methods
      function obj = dataFitClass(varargin) %construct the class
         if nargin >= 1 %at least one input
            obj.x = varargin{1}(:)';
            if nargin >= 2 %at least two inputs
               obj.y = varargin{2}(:)';
            end
         end
      end
      
      function val = get.n(obj) %evaluate n
         val = numel(obj.x); %number of elements in x
      end
 
      function val = get.yfit(obj) %construct function yfit
         if numel(obj.y) == obj.n
            A = [ones(obj.n,1) obj.x']; %create the matrix for the regression
            coeff = A\obj.y'; %compute the coefficients by least squares
            val = @(t) [ones(numel(t),1) t']*coeff;
         else
            val = [];
         end
      end
      
      function plot(obj) %plot the class
         plot(obj.x,obj.y,'.k','markersize',30) %plot points as dots
         if ~isempty(obj.yfit)
            xplot = [min(obj.x) max(obj.x)]; %x values to plot
            hold on
            plot(xplot,obj.yfit(xplot),'-') %plot the fitted line
            xlabel('x') %label the x axis
            ylabel('y') %label the y axis
         end
      end
   end
end



