%% The Nagel-Schreckenberg Traffic Model
% This example comes from Art Owen's lecture notes on Monte Carlo methods
% in <http://statweb.stanford.edu/~owen/mc/>.  Vehicles circulate on a
% track. Their speeding up and slowing down is determined by a random
% process.

%%

function NagelSchreckenbergTraffic %make it a function to not overwrite other variables
gail.InitializeDisplay %initialize the display parameters
set(0,'defaultLineMarkerSize',3) %small dots
tstart=tic; %start timer

%% Parameters for this Simulation
% There are \(N\) vehicles circulating on a track with \(M\) spaces, where
% \(M \ge N\).  The track is circular or oval so that there are no boundary
% conditions to worry about.  The vehicles travel at a maximum speed of
% \(v_{\max}\) spaces per unit time.  This model steps forward in
% increments of one time step.  Vehicles try to speed up one unit if there
% is room in front, while maintaining the speed limit.  Vehicles slow down
% one unit at random with probability \(p\).

N=100; %number of vehicles on the track
M=1000; %number of spaces on the track, who
vmax=5; %speed limit
p=2/3; %probability of slowing

%%
% To mitigate the effect of initial conditions, we run the simulation for
% \(T_0\) time steps before paying attention.  Then we run the simulation
% for another \(T\) time steps.

T0=2500; %number of burn in time steps
T=5000; %number of time steps to be observed
Tall=T0+T; %total number of time steps
flowmax=M*vmax; %maximum flow of vehicles during the time observed

%%
% We first initialize the variable used to record the positions of all
% vehicle at all times.  This pre-allocation of memory saves execution
% time.  We also initalize the variable used to record the velocities of
% all vehicle.

x=zeros(Tall+1,N); %initialize vehicle locations
v=zeros(1,N); %initialize velocity to zero
%v=ceil(vmax*rand(1,N)); %initialize velocity randomly
x0=randperm(M); %initial placement of vehicles at random positions
x(1,:)=sort(x0(1:N)); %then sorted in order

%% Time stepping updates of position
% At each time step we go through a process of computiong the new velocity
% of each vehicle.  This is done in several stages.  We attempt to
%
% * speed up each vehicle if it is going slower than the speed limit,
% * making sure that it does not hit the vehicle in front, and
% * and slow down each vehicle with IID randomly with a fixed probability.
% 
% Then we update the position of each vehicle.

for i=1:Tall
    d=mod([diff(x(i,:)) x(i,1)-x(i,N)],M); %update distances between vehicles
    v=min(v+1,vmax); %speed up by one if below the speed limit
    v=min(v,d-1); %but do not bump into the vehicle in front
    slowdown=rand(1,N)<p; %which vehicles slow down
    v(slowdown)=max(0,v(slowdown)-1); %slow these down
    x(i+1,:)=x(i,:)+v; %update position of vehicles
end
avgvelocity=sum(x(Tall+1,:)-x(T0+1,:))/(N*T); %Average velocity of all vehicles

%% Display results
% Finally we display some summary statistics of the simulated traffic flow.
% Notice that there are places where the vehicles jam up, and these traffic
% jams propagate backwards in time.  Notice that the time for the graphical
% display take much longer than the time for the actual calculation.

disp(['Time for simulation = ' num2str(toc(tstart)) ' seconds'])
disp(['After ' int2str(T0) ' steps of burn in,'])
disp(['     we use the next ' int2str(T) ' steps to compute the behavior.'])
disp(['Average velocity of ' num2str(N) ' vehicles = ' num2str(avgvelocity)])
disp(['     which is ' num2str(100*avgvelocity/vmax) ...
    '% of the maximum velocity of ' num2str(vmax)])
disp(['Flux = ' num2str(avgvelocity*N) ' vehicles per unit time'])
disp(['     which is ' num2str(100*avgvelocity*N/flowmax) ...
    '% of the maximum flux of ' num2str(flowmax)])

tstart=tic; %start timer
figure
plotT=min(T,1000);
plot(mod(x(T0+1+(0:plotT),:),M),repmat((0:plotT)',1,N),'b.')
xlabel('Position')
ylabel('Time')
set(gcf,'Position',[680 558 840 630])
print -depsc NSTraffic.eps
disp(['Time for the graphical display = ' num2str(toc(tstart)) ' seconds'])

%%
% _Author: Fred J. Hickernell_


    
    


