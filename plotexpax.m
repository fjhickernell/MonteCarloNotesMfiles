function plotexpax(a,xrange)
figure
xplot = xrange(1) + (0:0.001:1)*xrange(2);
plot(xplot,exp(a*xplot))
xlabel('\(x\)')
if a == 0
   ytext = '\(1\)';
elseif a == -1
   ytext = '\(\exp(-x)\)';
elseif a == 1
   ytext = '\(\exp(x)\)';
else 
   ytext = ['\(\exp(' num2str(a) 'x)\)'];
end
ylabel(ytext)
return