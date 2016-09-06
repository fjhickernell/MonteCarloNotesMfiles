%% Handles Versus Values
gail.InitializeWorkspaceDisplay %initialize the workspace and the display parameters

%%
% A value variable is what we are most familiar with.  First we set |x| to
% be a value and copy it to |y|.

x = 4 %set x to be a value
y = x %copy x to y

%%
% Changing the value of |y| does not change the value of |x|.

y = 7 %change the value of y
x %this doe not change the value of x

%%
% But handles are different.  They are pointers. The GAIL objects used for
% option pricing are handles.
%
% Suppose we set |x| to be a Brownian motion and copy |x| to |y|.  

x = brownianMotion %set x to be a brownianMotion object
y = x %copy x to y

%%
% If we change a property of |y| , then that property of |x| is changed
% also, because they point to the same place in memory.

y.timeDim.timeVector = 1 %change the property of y
x %x is changed also, because x and y point to the same place in memory 

%%
% Now if we clear |x| , that pointer is gone.  But |y| is still there, so
% the place in memory has not been cleared.

clear x %clear the variable x
exist('x') %x is gone
y %but the place in memory is still there, because y is still there.

%% 
% If we want to make a distinct copy of |y| we should use the class
% constructor. Then when we change a property of this copy, the
% corresponding property of the original |y| remains unchanged.

z = brownianMotion(y) %a distinct copy of y
z.timeDim.timeVector = 1:2 %change a property of z
y %y remains as before

%%
% _Author: Fred J. Hickernell_
