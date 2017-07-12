    function [err, profit] = MLE(varargin)


steprule = varargin{1};
numTruth = varargin{2};
    
numTrials = 200;
% original = [10, 2, 30];
original = [10];
% initialize parameters for BAKF
v = 10; 
beta = .01;
lambda = .01;
a = .01;


% kestens 
prevgradF = 1;
gradterm = 1;
kestenalpha = .0001; 
kestentheta = 10; 


% initialize parameters for adam
alphanought = .0001; 
beta1 = 0.95;
beta2 = 0.95;
mpast = 0;
vpast = 0;
epsilon = 1e-8;
gradF = 1;

% initialize parameters for adagrad 
adagradstepsize = .001;


% initialization of variables 
theta = original';
numparams = size(original, 2);
data = zeros(numTrials, numparams); 
sigma2 = 10; % variance of noise
fvalues = zeros(1, numTrials);
estprev = 0;
err = zeros(1, numTruth);
profit = zeros(1, numTruth);

for truth = 1:numTruth 

% generate linear model
xvect = zeros(1, numparams)';

    for i = 1:numTrials
            for j = 1:numparams 
                x = randi([1, 100]);
                xvect(j) = x;
            end 
            f = dot(theta, xvect);
            y = f + normrnd(0, sigma2^(.5));
            data(i,:) = xvect'; 
            fvalues(i) = y;
    end

     % use stochastic gradienet ascent algorithm to recover theta
     est = ones(1, numparams)'; % initialize theta as zero.
        
     % iterate through data points until we converge to correct thetas
     numIters = 1;
     estvect = zeros(numIters*numTrials, numparams); 
     funct = zeros(numIters*numTrials); 
     estprev = 10;
     
for iter = 1:numIters %numIters = 1 
        for k = 1:numTrials 
            
            namerule = func2str(steprule);
            
            if namerule == string('GHS')
                a = steprule(.0001, 500, k);
            end 
            if namerule == string('adam')
                a = adam(j, .0001, beta1, beta2, mpast, vpast, gradF,epsilon); 
            end 
            if namerule == string('polylearning')
                a = polylearning(.0001, j, 0.8);
            end 
            if namerule == string('adagrad')
                if (k == 1) 
                histgrad = zeros(1, 1);
                [a, g] = steprule(adagradstepsize, gradF,histgrad, 1, epsilon, 1);
                histgrad = g;
                else 
                [a, g] = steprule(adagradstepsize, gradF, histgrad, 1, epsilon, 1);
                histgrad = g;
                end  
            end 
            % kestens  
           if namerule == string('kestens')
            if (k == 1) 
                 K = 0;
            end 
                [a, newk] = steprule(kestenalpha, kestentheta, K, prevgradF,gradterm);
                K = newk;    
           end 

            for i = 1:numparams
                gradterm = computeGrad(fvalues(k), data(k, :), est, i);
                prevgradF = gradterm;
                est(i) = est(i) + a*gradterm;
                estvect(iter*k, i) = est(i);
            end
            
            estprev = est;
            funct(iter*k) = dot(data(k, :), est); 
        end 
end   
        
       err(truth) = immse(original', est);
       profit(truth) = -immse(original', est); %% tack on a negative sign

     
end
end
    
    function gradterm = computeGrad(y, data, est,paranum)
    
        gradterm = (y - dot(est,data))* data(paranum);
    end 