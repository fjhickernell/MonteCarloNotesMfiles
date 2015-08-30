%% Publish MATH 565 Demo Scripts

cd(fileparts(which('PublishMATH565Demos'))) %change directory to where this is
clearvars %clear all variables
tPubStart = tic; %start timer
save('PublishTime.mat','tPubStart') %save it because clearvars is invoked by demos
publishMathJax('OptionPricingExample')
publishMathJax('NagelSchreckenbergTraffic')
publishMathJax('SandwichShopSimulation')
publishMathJax('OptionPricingMeanMC_CLT')
publishMathJax('CLTCIfail')
publishMathJax('OptionPricingMeanMC_g')
load PublishTime.mat %load back tPubStart
disp('Total time required to publish all scripts is')
disp(['   ', num2str(toc(tPubStart)) ' seconds'])
delete PublishTime.mat %delete the file because it is no longer needed