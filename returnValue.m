function val = returnValue(obj,nx,cutoff,risklessInterest)
paths = genPaths(obj,nx); %generate stock paths
[whichDip,whenDip] = max(paths < cutoff,[],2); %find which drop too low
indPaths = sub2ind(size(paths),find(whichDip), whenDip(whichDip)); %transform to linear indices
val(size(paths,1),1) = 0; %initialize value
val(whichDip) = paths(indPaths) ...
   .* exp(-risklessInterest*obj.timeDim.timeVector(whenDip(whichDip)))'; %values of paths that drop too low
val(~whichDip) = paths(~whichDip,end) ...
   .* exp(-risklessInterest*obj.timeDim.timeVector(end)); %values of paths that do not drop too low

