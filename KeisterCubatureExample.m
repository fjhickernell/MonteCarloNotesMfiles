%% Keister's Example of Multidimensional Integration
% 
% B. D. Keister, Multidimensional quadrature algorithms, _Computers in
% Physics_, *10*, pp. 119-122, 1996, presents the following
% multidimensional integral, inspired by a physics application:
%
% \[ \mu = \int_{\mathbb{R}^d} \cos(\lVert \boldsymbol{t} \rVert)
% \exp(-\lVert \boldsymbol{t} \rVert^2) \, \mathrm{d} \boldsymbol{t},
% \qquad d = 1, 2, \ldots. \]

%% Expressing the integral as an expectation
% Let's evaluate the integral using Monte Carlo cubature.  We first note
% that the change of variable \(\boldsymbol{t} = a \boldsymbol{x}\)
% transforms this integral into
%
% \begin{align*} \mu &= \int_{\mathbb{R}^d} \cos(a \lVert \boldsymbol{x}
% \rVert) \exp(-a^2 \lVert \boldsymbol{x} \rVert^2) \, a^d \, \mathrm{d} 
% \boldsymbol{x}, \qquad a > 0, \\ & = \int_{\mathbb{R}^d}
% \underbrace{(2\pi a^2)^{d/2} \cos(a \lVert \boldsymbol{x} \rVert)
% \exp((1/2-a^2) \lVert \boldsymbol{x} \rVert^2)}_{f(\boldsymbol{x})}
% \times \underbrace{\frac{\exp(-\lVert \boldsymbol{x} \rVert^2/2)}
% {(2\pi)^{d/2}}}_{\varrho(\boldsymbol{x})} \, \mathrm{d} \boldsymbol{x} \\
% & = \mathbb{E}[f(\boldsymbol{X})], \qquad \text{where } \boldsymbol{X}
% \sim \mathcal{N}(\boldsymbol{0}, \mathsf{I}). \end{align*}

%% Evaluating the integral using |meanMC_g|
% To find \(\mu\) by Monte Carlo methods we define an anonymous function
% \(f\) as follows:

function KeisterCubatureExample %make it a function to not overwrite other variables

gail.InitializeDisplay %initialize the display parameters
normsqd = @(t) sum(t.*t,2); %squared l_2 norm of t
f1 = @(normt,a,d) ((2*pi*a^2).^(d/2)) * cos(a*sqrt(normt)) ...
   .* exp((1/2-a^2)*normt);
f = @(t,a,d) f1(normsqd(t),a,d);

%%
% Next we call |meanMC_g|

abstol = 0; %absolute error tolerance
reltol = 0.01; %relative error tolerance
dvec = 1:5; %vector of dimensions
a = 1 %default value of a
IMCvec = zeros(size(dvec)); %vector of answers
tic
for d = dvec
   IMCvec(d) = meanMC_g(@(n) f(randn(n,d),a,d),abstol,reltol); %compute the integral for different d
end
toc
IMCvec

%% Checking the real error
% There is a way to get the value of this integral to machine precision
% using the function |Keistertrue|
%
% <include>Keistertrue.m</include>

[~,Ivec] = Keistertrue(dvec(end));
relErrMC = abs(Ivec-IMCvec)./abs(Ivec)

%%
% All values are within the requested error tolerance.

%% Choosing different values of \(a\)
% The value of the integral does not depend on the value of the parameter
% \(a\), but the time required may. Let's try two other values:

a = sqrt(1/2) %a smaller value of a
tic
for d = dvec
   IMCvec(d) = meanMC_g(@(n) f(randn(n,d),a,d),abstol,reltol); %compute the integral for different d
end
toc
IMCvec
relErrMC = abs(Ivec-IMCvec)./abs(Ivec)

a = 1.2 %a larger value of a
tic
for d = dvec
   IMCvec(d) = meanMC_g(@(n) f(randn(n,d),a,d),abstol,reltol); %compute the integral for different d
end
toc
IMCvec
relErrMC = abs(Ivec-IMCvec)./abs(Ivec)

%% Choosing all values of \(a\)
% The algorithm |meanMC_CLT| has the option for you to provide several
% random variables with the same mean.  The sample means from these several
% random variables are then weighted to provide an approximation to their
% common mean.
%
% First we try with three different values of \(a\)

d = 4; %a typical value
avec = [1/sqrt(2) 1 1.2]; %three different choices of a
tic
IMCsmallA = meanMC_CLT(@(n) f(randn(n,d),avec(1),d),abstol,reltol)
toc
tic
IMCmedA = meanMC_CLT(@(n) f(randn(n,d),avec(2),d),abstol,reltol)
toc
tic
IMClargeA = meanMC_CLT(@(n) f(randn(n,d),avec(3),d),abstol,reltol)
toc

%%
% Next we try with all values of \(a\)

fAllA = @(t) [f(t,avec(1),d) f(t,avec(2),d) f(t,avec(3),d)];
tic
IMCAllA = meanMC_CLT('Y', @(n) fAllA(randn(n,d)), 'nY',3, ...
   'absTol', abstol, 'relTol',reltol)
toc

%%
% The time is worse than for the best choice of \(a\), but better than for
% the worst choice of \(a\).  It is like an insurance policy.  |meanMC_g|
% does not yet have this capability, but it should be added.

%% Lattice cubature
% We may sample the integrand using the nodeset of a rank-1 integration
% lattice to approximate this integral.

a = 1; %default value of a again
ILatticevec = zeros(size(dvec)); %vector of answers
tic
for d = dvec
   ILatticevec(d) = cubLattice_g(@(x) f(x,a,d),[-inf(1,d); inf(1,d)], ...
      'normal',abstol,reltol);
end
toc
ILatticevec
relErrLattice = abs(Ivec-ILatticevec)./abs(Ivec)

%%
% We see that the the relative error using the lattice rule is still within
% tolerance, but the time required is much less.

%% Sobol cubature
% We may use the Sobol' cubature to approximate this integral.

a = 1; %default value of a again
ISobolvec = zeros(size(dvec)); %vector of answers
tic
for d = dvec
   ISobolvec(d) = cubSobol_g(@(x) f(x,a,d),[-inf(1,d); inf(1,d)], ...
      'normal',abstol,reltol);
end
toc
ISobolvec
relErrSobol = abs(Ivec-ISobolvec)./abs(Ivec)

%%
% Again, the relative error using the Sobol' rule is within tolerance, but
% the time required is much less.
%
% _Author: Fred J. Hickernell_

   