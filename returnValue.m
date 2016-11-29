function val = returnValue(obj,nx,cutoff,risklessInterest)
paths = genPaths(obj,nx);
[whichDip,whenDip] = max(paths < cutoff,[],2);
indPaths = sub2ind(size(paths),find(whichDip), whenDip(whichDip));
val(size(paths,1),1) = 0;
val(whichDip) = paths(indPaths) ...
   .* exp(-risklessInterest*obj.timeDim.timeVector(whenDip(whichDip)))';
val(~whichDip) = paths(~whichDip,end) ...
   .* exp(-risklessInterest*obj.timeDim.timeVector(end));

