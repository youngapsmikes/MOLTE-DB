function[alpha, beta, v, lambda] = BAKF(iter, x, xprev, nu, beta, v, lambda, a)
    
    [beta,v,var,lambda] = updateStats(x, xprev, nu, beta, v, lambda, a);

    % update alpha for next time step
    if iter == 1 || iter == 2 
        a = (1) / (iter+1);
        alpha = a;
    end 
    
%     a = 1 - ((var) / ((1+lambda)*var + beta*beta));
    a = 1 - (var)/(v);
    alpha = a;

end 

function [beta1,v1,var1,lambda1] = updateStats(theta, prevtheta, nu, beta, v, lambda, a)

    epsilon = prevtheta - theta;
    beta1 = (1-nu)*beta + nu*epsilon;
    v1 = (1-nu)*v + nu*epsilon*epsilon;
    var1 = (v-beta*beta) / (1+lambda);
    lambda1 = (1 - a)*lambda + (a)^2;
    
end 

% function [alpha = BAKF(x, xprev, beta, v, var, lambda)%BAKF(var, bias, n, alpha, lambda)
% % bias-adjusted Kalman filter stepsize rule
% 
% % sigma2 is the variance of the observation theta at timestep n
% % beta (at n) is the bias computed after iteration n
% % alpha is the previous stepsize 
%     
%     if n == 1 || n == 2 
%          alpha = 1 / (n+1);
%     end 
%     
%     
%     
%     % update stepsizes for next iteration
%     updateStats(x, xprev, 0.1, beta, v, lambda);
%     
%     alpha = 1 - ((var) / ((1+lambda)*var + bias*bias)); 
% %     else 
%     lambda = (1-alpha)*(1-alpha)*lambda + alpha*alpha;
% %     end 
%     
% end
% 
% function [epsilon, beta,v, var] = updateStats(theta, prevtheta, nu, beta, v, lambda)
% 
%     epsilon = prevtheta - theta;
%     beta = (1-nu)*beta + nu*epsilon;
%     v = (1-nu)*v + nu*epsilon*epsilon;
%     var = (v-beta*beta) / (1+lambda);
%     
% end 
