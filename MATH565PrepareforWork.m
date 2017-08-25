function MATH565PrepareforWork(GAIL,MATH565,PubDemo)
% This function downloads and installs GAIL version 2.1 into the
% location you choose
%
%   Step 1.  Place this M-file where you want GAIL to go
%
%   Step 2.  Set the MATLAB path to that same directory
%
%   Step 3.  Run this M-file in MATLAB
%
% This file installs 
% 
%    o the development branch of the latest version of GAIL, and
%
%    o the MonteCarloNotesMfiles repository
%
% where this function file is placed.  These repositories are also added to
% the MATLAB path.
%
% _Author: Fred J. Hickernell_

if nargin < 3
   PubDemo = true; %publish the demo
   if nargin < 2
      MATH565 = true; %install the MATH565 files
      if nargin < 1
         GAIL = true; %install GAIL
      end
   end
end

%% Download the GAIL package and add to the MATLAB path
if GAIL
   if ~exist('GAIL_Dev-develop','dir')
      disp('The GAIL package is now being downloaded...')
      unzip('https://github.com/GailGithub/GAIL_Dev/archive/develop.zip'); %download and unzip
   end
   disp('Adding GAIL_Dev-develop to path')
   addpath(genpath(fullfile(cd,'GAIL_Dev-develop')))
   savepath  
end

%% Download the MonteCarloNotesMfiles repository and add to the MATLAB path
if MATH565
   if ~exist('MonteCarloNotesMfiles-master','dir')
      fprintf('The MonteCarloNotesMfiles package is now being downloaded...\n')
      unzip('https://github.com/fjhickernell/MonteCarloNotesMfiles/archive/master.zip'); %download and unzip
   end
   disp('Adding MonteCarloNotesMfiles-master to path')
   wholepath=genpath(fullfile(cd,'MonteCarloNotesMfiles-master'));% Generate strings of paths to GAIL subdirectories
   addpath(wholepath); % Add MonteCarloNotesMfiles directories and subdirectories
   savepath  
   fprintf('MonteCarloNotesMfiles has been succesfully installed.\n\n')
end

%% Test things out
if PubDemo 
   disp('Now we perform a test by publishing one demo: OptionPricingExample')
   publishMathJax OptionPricingExample
   web(['MonteCarloNotesMfiles-master' filesep 'html' filesep 'OptionPricingExample.html'])
end

end
