%% Generating Random Variables and Vectors
% MATLAB has basic random number generators
%
% * |rand| for generating \(\mathcal{U}[0,1]\) random variables, and
% * |randn| for generating \(\mathcal{N}[0,1]\) random variables.
%
% In this MATLAB script we want to show how to generate other kinds of
% random variables

%% \(\mathcal{U}[\boldsymbol{a},\boldsymbol{b}]\) random vectors
% The command |rand(n,d)| generates \(n\) IID uniform random \(d\)-vectors
% with distribution \(\mathcal{U}[0,1]^d\).  If we need uniform random
% vectors over an arbitrary, finite \(d\)-dimensional box
% \([\boldsymbol{a},\boldsymbol{b}]\), then we can make an affine
% transformation.

InitializeWorkspaceDisplay %initialize the workspace and the display parameters
unif = @(n,ab) bsxfun(@plus,ab(1,:), bsxfun(@times, diff(ab,1,1),rand(n,size(ab,2))));
   %function to generate n uniform random vectors on the box defined by ab
figure
box = [-3 5; 4 6]; %some box
unifpts = unif(30,[-3 5; 4 6]); %generate some random vectors
plot(unifpts(:,1),unifpts(:,2),'.') %plot the random vectors
axis([box(1,1) box(2,1) box(1,2) box(2,2)]) %set axes to match the box

%% \(\mathcal{N}(\boldsymbol{m},\mathsf{\Sigma})\) random vectors
% The command |randn(n,d)| generates \(n\) IID Gaussian (normal) random
% \(d\)-vectors with distribution
% \(\mathcal{N}(\boldsymbol{0},\mathsf{I})\).  If we need Gaussian random
% vectors with an arbitrary mean and covariance matrix, i.e.,
% \(\boldsymbol{Z} \sim \mathcal{N}(\boldsymbol{m},\mathsf{\Sigma})\), then
% we can make an affine transformation.
%
% If \(\mathsf{A}\) is an arbitrary \(d \times d\) matrix,
% \(\boldsymbol{m}\) is an arbitrary \(d\)-vector, and \(\boldsymbol{X}
% \sim \mathcal{N}(\boldsymbol{0},\mathsf{I})\), then
%
% \[ \boldsymbol{Z} = \boldsymbol{m} +  \mathsf{A} \boldsymbol{X} \]
%
% is automatically Gaussian with mean 
%
% \[ \mathbb{E}(\boldsymbol{Z}) = \mathbb{E}(\boldsymbol{m}) +  \mathsf{A}
% \mathbb{E}(\boldsymbol{X}) = \boldsymbol{m} \]
%
% and variance 
%
% \[ \text{var}(\boldsymbol{Z}) =
% \mathbb{E}\bigl[(\boldsymbol{Z} - \boldsymbol{m})(\boldsymbol{Z} -
% \boldsymbol{m})^T \bigr] = \mathbb{E}\bigl[\mathsf{A}
% \boldsymbol{X}\boldsymbol{X}^T \mathsf{A}^T \bigr] = \mathsf{A}
% \mathbb{E} \bigl[\boldsymbol{X} \boldsymbol{X}^T \bigr] \mathsf{A}^T = \mathsf{A}
% \mathsf{A}^T \]
%
% So if we can choose \(\mathsf{A}\) such that \( \mathsf{\Sigma} =
% \mathsf{A} \mathsf{A}^T\), we have a way to generate Gaussian random
% vectors with arbitrary mean and covariance matrix.  One way to do that is
% using the Cholesky decomposition. Note that in our notation above our
% random vectors are column vectors, but in our MATLAB notation below they
% are row vectors.

Sigma = [2 1; 1 1] %a symmetric positive-definite matrix
eig(Sigma) %note that the eigenvalue are all positive
Gaussian = @(n,m,B) bsxfun(@plus,m,randn(n,size(m,2))*B);
   %function to generate n Gaussian random row vectors, where B corresponds
   %to A'
B = chol(Sigma) %uses the Cholesky decomposition to create an upper triangluar matrix such that B'B = Sigma
   %note that this B corresponds to our A' above
shouldBeSigma = B'*B %checking that this is Sigma
m = [-1 3];
figure
Gaussianpts = Gaussian(1000,m,B); %generate some random vectors
plot(Gaussianpts(:,1),Gaussianpts(:,2),'.') %plot the random vectors
axis([-6 4 -1 7])

%% 
% We may check that the sample quantities are close to the population
% quantities:

shouldBeAlmostM = mean(Gaussianpts) %should be close to m
shouldBeAlmostSigma = cov(Gaussianpts) %should be close to Sigma

%%
% Given a covariance matrix \(\mathsf{\Sigma}\) there are many matrices
% \(\mathsf{A}\) satisfying \(\mathsf{\Sigma} = \mathsf{A} \mathsf{A}^T\).
%  For example, if \(\mathsf{U}\) is any unitary matrix, i.e., any
%  matrix satisfying \(\mathsf{U}^T \mathsf{U} = \mathsf{I}\), then
%  \(\mathsf{\Sigma} = \mathsf{C} \mathsf{C}^T\) for \(\mathsf{C} =
%  \mathsf{A}\mathsf{U}^T\).  Another way to find a matrix \(\mathsf{A}\)
%  satisfying \(\mathsf{\Sigma} = \mathsf{A} \mathsf{A}^T\) is to use the
%  singular value decomposition:  \(\mathsf{\Sigma} =
%  \mathsf{U}\mathsf{\Gamma}\mathsf{V}'\), where \(\mathsf{U}\) and
%  \(\mathsf{V}\) are unitary.  Since \(\mathsf{\Sigma}\) is symmetric,
%  \(\mathsf{U} = \mathsf{V}\)

[U,Gamma] = svd(Sigma,'econ'); %computes the SVD decomposition 
B = bsxfun(@times,sqrt(diag(Gamma)),U') % to create an upper triangluar matrix such that B'B = Sigma
   %note that this B corresponds to our A' above
shouldBeSigma = B'*B %checking that this is Sigma
figure
Gaussianpts = Gaussian(1000,m,B); %generate some random vectors
plot(Gaussianpts(:,1),Gaussianpts(:,2),'.') %plot the random vectors
axis([-6 4 -1 7])

%% 
% Again we may check that the sample quantities are close to the population
% quantities:

shouldBeAlmostM = mean(Gaussianpts) %should be close to m
shouldBeAlmostSigma = cov(Gaussianpts) %should be close to Sigma

%% Generating Exp(\(\lambda\)) Random Numbers by the Inverse Distribution Transformation
% For random vectors that are not distributed uniformly or Gaussian, we may
% sometimes use the inverse cumulative distribution function.  To genearate
% an exponentially distributed random variable, \(Y \sim \)
% Exp(\(\lambda\)), one uses the transformation
%
% \[ Y = \frac{-\log(X)}{\lambda}, \qquad X \sim [0,1]. \]
%
% Suppose that the taxis arrive at a rate of once per ten minutes,
% \(\lambda = 0.1\) min\({}^{-1}\).  Then the average time required to wait
% for two taxis to take your group of eight friends is \(20\) minutes,
% which can be computed analytically and by Monte Carlo:

twotaxiwait = @(n) -10*sum(log(rand(n,2)),2);
avgwait = meanMC_g(twotaxiwait,0.01,0)

%% Generating Discrete Random Numbers by the Inverse Distribution Transformation
% Discrete random variables have their probablity mass functions,
% \(\varrho\), and cumulative distribution functions, \(F\), given by
% tables, e.g.,
%
% \[
% \begin{array}{r|cccc}
% y & 0 & 1 & 2 & 3 \tabularnewline
% \varrho(y) = \mathcal{P}(Y=y) & 0.2 & 0.4 & 0.3 & 0.1 \tabularnewline
% F(y) = \mathcal{P}(Y \le y) & 0.2 & 0.6 & 0.9 & 1 \tabularnewline
% \end{array}
% \]

yvals = 0:3 %ordered possible values of the random variable Y
PDFvals = [0.2 0.4 0.3 0.1] %corresponding values of the PDF
CDFvals = cumsum(PDFvals) %corresponding values of the CDF

%%
% We can use the |griddedInterpolant| to build the quantile function,
% \(F^{-1}\).

quantileFun = griddedInterpolant(CDFvals,yvals,'next'); %next neighbor interpolation

%%
% This allows us to generate IID values of \(Y\).

X = rand(1,8) %generate IID standard uniform random numbers
Y = quantileFun(X) %generate IID random numbers with the desired distribution

%%
% We can check the sample statistics of this random number generator and
% note that they are close to the correponding population values

n = 1e4; %sample size
Y = quantileFun(rand(n,1)); %generate a large number of Y values
prob0 = sum(Y == 0)/n %sample proportion of 0 values, should be close to 0.2
prob1 = sum(Y == 1)/n %sample proportion of 1 values, should be close to 0.4
prob2 = sum(Y == 2)/n %sample proportion of 2 values, should be close to 0.3
prob3 = sum(Y == 3)/n %sample proportion of 3 values, should be close to 0.1

%%
% _Author: Fred J. Hickernell_
