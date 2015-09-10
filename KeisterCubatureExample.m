%% Keister's Example of Multidimensional Integration
% 
% B. D. Keister, Multidimensional quadrature algorithms, _Computers in
% Physics_, *10*, pp. 119-122, 1996, presents the following
% multidimensional integral, inspired by a physics application:
%
% \[ I = \int_{\mathbb{R}^d} \cos(\lVert \boldsymbol{x} \rVert)
% \exp(-\lVert \boldsymbol{x} \rVert^2) \, \mathrm{d} \boldsymbol{x},
% \qquad d = 1, 2, \ldots. \]

%% Expressing the integral as an expectation
% Let's evaluate the integral using Monte Carlo cubature.  We first note
% that the change of variable \(\boldsymbol{t} = \boldsymbol{x}/a\)
% transforms this integral into
%
% \begin{align*} I &= \int_{\mathbb{R}^d} \cos(a \lVert \boldsymbol{t}
% \rVert) \exp(-a^2 \lVert \boldsymbol{t} \rVert^2) \, a^d \mathrm{d}
% \boldsymbol{t}, \qquad a > 0, \\ & = \int_{\mathbb{R}^d}
% \underbrace{(2\pi a^2)^{d/2} \cos(a \lVert \boldsymbol{t} \rVert)
% \exp((1/2-a^2) \lVert \boldsymbol{t} \rVert^2)}_{f(\boldsymbol{t})}
% \times \underbrace{\frac{\exp(-\lVert \boldsymbol{t} \rVert^2/2)}
% {(2\pi)^{d/2}}}_{\varrho(\boldsymbol{t})} \, \mathrm{d} \boldsymbol{t} \\
% & = \mathbb{E}[f(\boldsymbol{T})], \qquad \text{where } \boldsymbol{T} \sim \mathcal{N}(\boldsymbol{0},
% \mathsf{I}). \end{align*}

%% Evaluating the integral using |meanMC_g|
% To find \(I\) by Monte Carlo methods we define an anonymous function
% \(f\) as follows:

InitializeWorkspaceDisplay %initialize the workspace and the display parameters
normsqd = @(t) sum(t.*t,2); %squared l_2 norm of t
f1 = @(normt,a,d) ((2*pi*a^2).^(d/2)) * cos(a*sqrt(normt)) ...
   .* exp((1/2-a^2)*normt);
f = @(t,a,d) f1(normsqd(t),a,d);

%%
% Next we call |meanMC_g|

abstol = 0; %absolute error tolerance
reltol = 0.01; %relative error tolerance
dvec = 1:5; %vector of dimensions
a = 1; %default value of a
IMCvec = zeros(size(dvec)); %vector of answers
tic
for d = dvec
   IMCvec(d) = meanMC_g(@(n) f(randn(n,d),a,d),abstol,reltol);
end
toc
IMCvec

%% Checking the real error
% There is a way to get the value of this integral to machine precision
% using the function |Keistertrue|

type Keistertrue
[~,Ivec] = Keistertrue(dvec(end));
relErrMC = abs(Ivec-IMCvec)./abs(Ivec)

%%
% All values are within the requested error tolerance.

%% Choosing a different value of \(a\)
% The time needed depends on the value of the parameter \(a\).  Let's try
% two other values:

a = sqrt(1/2) %a smaller value of a
tic
for d = dvec
   IMCvec(d) = meanMC_g(@(n) f(randn(n,d),a,d),abstol,reltol);
end
toc
IMCvec
relErrMC = abs(Ivec-IMCvec)./abs(Ivec)

a = 1.2 %a larger value of a
tic
for d = dvec
   IMCvec(d) = meanMC_g(@(n) f(randn(n,d),a,d),abstol,reltol);
end
toc
IMCvec
relErrMC = abs(Ivec-IMCvec)./abs(Ivec)

   