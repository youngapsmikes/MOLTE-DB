function [finalalpha] = scalingEstimator()
% we try to find a scaling estimate alphanought 
% Input
% problem: ie. newsvendor, we need the gradient
%
% Output: finalalpha - good estimate of alpha_0
    
    alphanought = 1;
    scalingfactor = 2;
    params = zeros(1, 2); 
    params(1) = 1;
    params(2) = 0.8;
    
                   
    [~,~, gradvect] = newsvendorgradient(@polylearning, 10,params, 1);
    toosmall = compareGrad(gradvect);
     
     % if stepsize of 1 is initially too small
    if (toosmall == true)
        alphatry = alphanought; 
        count = 0;
        while(toosmall == true && count < 8) 
            disp('from toosmall');
            % pass in alphatry and obtain gradient 
            [~, ~, gradvect] = newsvendorgradient(@GHS, 10, params, 1);
            toosmall = compareGrad(gradvect);
            alphatry = alphatry*scalingfactor;
            params(1) = alphatry;
%             disp(alphatry);
            count = count + 1;
        end
        
    % if stepsize of 1 is initially too large
     else 
        alphatry = alphanought; 
        count = 0;
        while(toosmall == false && count < 8) 
            disp('from too large');
            % pass in alphatry and obtain gradient 
%             [~,~,~,gradvect] = problem(200, 600, 10, alphatry, 120, 50, @vanillanewsvendorgrad, @polylearning, 3); 
            [~, gradvect] = newsvendorgradient(@GHS, 10, params, 1);
%             disp(gradvect);
            toosmall = compareGrad(gradvect);
            alphatry = alphatry/scalingfactor;
            params(1) = alphatry; 
%             disp(alphatry);
            count = count + 1;
        end
%         disp(count);
%         disp(toosmall == false);

%         if(count == 8 || toosmall == )
            count = 0;
            toosmall = true;
            while(toosmall == true && count < 2) 
                disp('from second toosmall');
                % pass in alphatry and obtain gradient 
%             [~,~,~,gradvect] = problem(200, 600, 10, alphatry, 120, 50, @vanillanewsvendorgrad, @polylearning, 3); 
%                 [~, gradvect] = linearmodel(1, 10, alphatry);
               [~, gradvect] = newsvendorgradient(@GHS, 10, params,1);
                toosmall = compareGrad(gradvect);
                alphatry = alphatry*scalingfactor;
                params(1) = alphatry;
%                 disp(alphatry);
                count = count + 1;
            end
    end       
    finalalpha = alphatry;
    end 

function toosmall = compareGrad(gradvect)

    N = size(gradvect, 2); 
    hasChanged = false; 
    grad = gradvect(1);
    for i = 2:N
        newgrad = gradvect(i); 
        innerprod = grad * newgrad; 
        grad = newgrad;
        if (innerprod <= 0) 
        hasChanged = true; 
        break; 
        end
    end
    % if gradient hasn't changed we need to use larger stepsize
    if (hasChanged == false)
        toosmall = true;
    end 

    % if gradient has changed we need to use smaller stepsize
    if (hasChanged == true) 
        toosmall = false;
    end 
end 