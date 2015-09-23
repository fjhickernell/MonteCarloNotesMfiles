function Y = sumUnifRand(n,d)
Y = zeros(n,1); %initialize Y
ndmax = 1e7; %largest number of elements that we allow at a time
npc = floor(ndmax/d); %number of samples per piece
nit = floor(n/npc); %number of iterations in the for loop
for j = 1:nit
   Y((j-1)*npc+1:j*npc) = sum(rand(npc,d),2); %sum of d uniform random variables
end
nrem = n - nit*npc; %left overs
if nrem > 0
   Y(nit*npc+1:n) = sum(rand(nrem,d),2); %sum of d uniform random variables
end
end