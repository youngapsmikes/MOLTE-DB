

% given battery storage pricing data find optimal set of sell/buy prices 
% such that profit is maximized

function [maxtheta, maxprofit] = energyinventory(steprule, numrestart)

% kestens 
prevgradF = 1;
gradterm = 1;
kestenalpha = .0001; 
kestentheta = 10; 


% initialize parameters for adam
beta1 = 0.95;
beta2 = 0.95;
mpast = 0;
vpast = 0;
epsilon = 1e-8;
gradF = 1;

% initialize parameters for adagrad 
adagradstepsize = .001;


maxprofit = 0;
maxtheta = zeros(1,2)';
prices = findprices();

gradvect = zeros(2,1); % initialize gradient vector  
prevgrad = [1, 1];




for k = 1:numrestart
    
N = 100;

theta = getRandom()'; % initialize theta_S, theta_B

thetas = zeros(1, N);
thetab = zeros(1, N);
for i = 1:N
    
    namerule = func2str(steprule);  
    % GHS 
    if namerule == string('GHS')
        a = steprule(.00001, 1, i);
    end 
    % adam
    if namerule == string('adam')
        a = adam(i, .0001, beta1, beta2, mpast, vpast, gradF,epsilon); 
    end 
    % polyomial learning
    if namerule == string('polylearning')
        a = polylearning(.0001, i, 0.8);
    end 
    % adagrad
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
    gradvect = getgradF(theta, prices);
    theta = theta + a*gradvect;
    
    if (theta(1) < 0)
        theta(1) = 0;
    end 
    if (theta(2) < 0)
        theta(2) = 0;
    end 
    if (theta(1) < theta(2))
        theta(2) = theta(1);
    end 
    % get profit 
    thetas(i) = theta(1); 
    thetab(i) = theta(2); 
    thetaest = [theta(1), theta(2)]';
end 
    thetatry = theta; 
    [~, profittry] = getF(thetatry, prices);
    if (profittry >= maxprofit) 
        maxprofit = profittry; 
        maxtheta = thetatry;
    end 
    
    
end 


end 

% compute numerical gradient 
function gradient = getgradF(theta, prices)
    delta = 5; 
    gradient = zeros(2,1);
    thetaSperturb = theta + [1 0]'* delta;
    thetaBperturb = theta + [0 1]'* delta;
    [Fs, ~] = getF(thetaSperturb, prices); 
    [Fb, ~] = getF(thetaBperturb, prices); 
    [F, ~] = getF(theta, prices);

    gradFs = (Fs-F)/delta;
    gradFb = (Fb-F)/delta;
    gradient(1) = gradFs; 
    gradient(2) = gradFb;
end 

% get profit 
function [F, finalprofit] = getF(theta, prices) 
    
    T = size(prices,1); %% simulate for # iterations equal to # prices
    sellprice = theta(1);
    buyprice = theta(2);
    R = size(prices, 1);
    inventory = 50;
    
    profit = 0;
    F = 0;
    for t = 1:T
        price = prices(t); %% get a price 
        if(isnan(price)) 
            R(t) = inventory;
            continue;
        end 
        if(price < 0) 
            R(t) = inventory;
            continue;
        end 
        
        decision = getDecision(price, sellprice, buyprice,inventory);

        if (inventory > 100) 
            inventory = 100;
        end 
        if (inventory < 0) 
            inventory = 0;
        end 
        if (decision == -1) 
           inventory = inventory - 1;
           profit = profit + .95*price;
           F = F + .95*price;
        elseif (decision == 1) 
            inventory = inventory + .95;
            profit = profit - price;
            F = F - .95*price;
        else 
        end 
        R(t) = inventory;
    end 
    finalprofit = profit;
end 

function findecision = getDecision(price, sellprice, buyprice, R)

    if (price > sellprice && R > 0) 
        decision = -1;
    elseif (price < buyprice)
        decision = 1;
    else
        decision = 0;
    end 
    findecision = decision;
    
end 
% generate a random set of sell/buy prices 
function randtheta = getRandom() 

    thetas = randi([10, 100]);
    thetab = randi([10,100]); 
    while ((thetas < thetab) || (thetas <0) || (thetab< 0))
        thetas = randi([5, 100]);
        thetab = randi([5,100]); 
    end 
    randtheta(1) = thetas; 
    randtheta(2) = thetab;
end
