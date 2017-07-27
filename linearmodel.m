    function [est, gradvect] = linearmodel(numTrials, scale)


    theta = 10;
    numparams = 1;
    data = zeros(numTrials, 1 + numparams); 
    vectfest = zeros(1, numTrials);
    vectest = zeros(1, numTrials);
    steps = zeros(1, numTrials);
    gradvect = zeros(1, numTrials);
    sigma2 = .5; 
    epsilon = 1e-8;
    % generate linear model
%     for i = 1:numTrials
%         x =  randi([1 10]);
%         f = theta*x;
%         y = f + normrnd(0, sigma2^(.5));
%         data(i,1) = x; 
%         data(i, 2) = y;
%     end
    
%     est = 5;
    
%      alpha = @GHS;
%    alpha = @adagrad; 
%     scale = 1;
%     alpha = @kestens; % .02
%      alpha = @adam; %a = alpha(j, .02, .9, .9, 10, 8, gradF, epsilon); 
%     alpha = @polylearning;  % a = alpha(.03, j, .75);
%     alpha = @BAKF;
      
    prevgradF = 1;
    k = 0;
    
%     xprev = 1;
%     nu = .1;
%     beta = .80; 
%     v = 60;
%     lambda = 30;
%     a = 1e-100;
    numPaths = 1000;
    allvects = zeros(numPaths, numTrials);
    
  for i = 2:2
      if i == 1 
          alpha = @GHS;
      end 
      if i == 2 
          alpha = @adagrad;
      end 
      if i == 3 
          alpha = @kestens;
      end 
      if i == 4
          alpha = @adam;
      end 
      if i == 5 
          alpha = @polylearning;
      end 
    est = 3;
    for p = 1:numTrials
        x =  randi([1 10]);
        f = theta*x;
        y = f + normrnd(0, sigma2^(.5));
        data(p,1) = x; 
        data(p, 2) = y;
    end 
      
  for t = 1:numPaths
    for j = 1:numTrials
        x = data(j, 1);
        y = data(j, 2);
        gradF = (y - est*x)*x;
        gradvect(j) = gradF;        
        if i == 1 %GHS
            a = alpha(.05, 10, j);
        end 
        if i == 2 %adagrad
            if j == 1
            [a, G] = alpha(1, gradF, 1, epsilon);
            else a = alpha(G, 1, gradF, 1, epsilon);
            end 
        end 
        if i == 3 %kestens
            [a, newK] = alpha(.01, 10, k, prevgradF,gradF);
            prevgradF = gradF;
            k = newK;
        end 
        if i == 4 % adam
            a = alpha(j, .01, .9, .9, 10, 8, gradF, epsilon);
        end 
        if i == 5
                a = alpha(.03, j, .75);
        end 
       est = est + a*gradF;
       steps(j) = a;
       vectest(j) = est;
       vectfest(j) = est*x;
    end
%     disp(size(vectest'));
%     disp(size(allvects(t)));
    allvects(t, :) = vectfest';
  end 
%   vectest = mean(vectest);
  vectfest = mean(allvects);
  hold all;
  
      if i == 1
          disp(vectest);
           semilogx(vectest, 'color', 'blue', 'DisplayName', 'GHS');
      end 
      if i == 2
          semilogx(vectfest, 'color', 'cyan', 'DisplayName', 'adagrad');
      end 
      if i == 3
          semilogx(vectfest, 'color', 'magenta', 'DisplayName', 'kestens');
      end
      if i == 4
          semilogx(vectfest, 'color', 'red', 'DisplayName', 'adam');
      end
      if i == 5
          semilogx(vectfest, 'color', 'green', 'DisplayName', 'polylearning');
      end 
  end 
