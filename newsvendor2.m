function [y,profit] = newsvendor2(varargin)
% newsvendor problem with demand exponentially distributed and price much
% larger than cost 

% Input:
% numTruth: number of times to run one sample path of newsvendor simulation 
% steprule: alpha 

% Output:
% y: vector of estimates of our optimal demand 

steprule = varargin{1};
numTruth = varargin{2};

% initialization of newsvendor problem parameters 
c = 100; % cost of newspaper
p = 200; % price of newspaper
grad = @vanillanewsvendorgrad; % gradient 
N = 200; % number of iterations in one sample path
mu = 120; % mean of exponential distribution 

% initialize parameters for BAKF
nu = .1;
v = 1; 
beta = .05;
lambda = 1;
BAKFalpha = 1; % initial estimate for alpha for BAKF
alpha = 1;

% initialize parameters for adam
alphanought = .5; 
beta1 = 0.95;
beta2 = 0.95;
mpast = 15;
vpast = 10;
epsilon = 1e-8;


% initialize parameters for adagad
adagradstepsize = 120;

% initialize parameters for GHS
GHSalpha = 10;
GHStheta = 1;

% initialize parameters for Polynomial learning rates 
Polyalpha = 2;
Polybeta = 0.8;

% initialize parameters for Kestens 
K = 0;
kestenalpha = 1;
kestentheta = 10;



for i = 1:numTruth
    
profit = zeros(1, numTruth);

% initialization of variables 
x = 0; 
y = zeros(1, N); % vector of estimates of parameter 
steps = zeros(1, N); % store the stepsizes 
F = zeros(1, N); % profit vector for a single sample path
gradF = 1;
gradFvect = zeros(1, N);


  
% iterate through one sample path
    for j = 1:N

     w = exprnd(mu); % distribution of demand 

     F(j) = p*min(x, w) - c*x;
     prevgradF = gradF;
     gradF = grad(w, x, p, c);
     gradFvect(j) = gradF;
     xprev = x;

     namerule = func2str(steprule);
     % ADAM
     if namerule == string('adam')
        alpha = steprule(j, alphanought, beta1, beta2, mpast, vpast, gradF, epsilon);
     end 
     % GHS
     if namerule == string('GHS')
       alpha = steprule(GHSalpha, GHStheta, j); 
     end 
     % Polynomial learning rates
     if namerule == string('polylearning')
       alpha = steprule(Polyalpha, j, Polybeta);    
     end 
     % adagrad 
     if namerule == string('adagrad')
        if (j == 1) 
            histgrad = zeros(1, 1);
            [alpha, g] = steprule(adagradstepsize, gradF,histgrad, 1, epsilon, 1);
            histgrad = g;
        else 
        [alpha, g] = steprule(adagradstepsize, gradF, histgrad, 1, epsilon, 1);
        histgrad = g;
        end 
     end 

     % BAKF 
     if namerule == string('BAKF') 
         x = x + alpha*gradF;
        [alpha, beta, v, lambda] = steprule(j, x, xprev, nu, beta, v, lambda, BAKFalpha);  
     end 

     % kestens  
     if namerule == string('kestens')

        if (j == 1) 
            K = 0;
        end 
        [alpha, newk] = steprule(kestenalpha, kestentheta, K, prevgradF,gradF);
        K = newk;    
     end 
     
     if namerule ~= string('BAKF')
        x = x + alpha*gradF;
     end 
     
     y(j) = x;
     steps(j) = alpha;
     
    end
        finprofit = F(N);
        profit(i) = finprofit; 
end


end 