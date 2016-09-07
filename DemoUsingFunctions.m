%% Demo of using a function to store repeated calculations

%%
gail.InitializeWorkspaceDisplay

%% Function plotxpax
% Here is a function that we defined in another file that we will use
% multiple times
%
% <include>plotexpax.m</include>
%

%% First plot
plotexpax(-1,[-1 1]);

%% Second plot
plotexpax(1,[-1 1]);

%% Third plot
plotexpax(1,[0 10]);

