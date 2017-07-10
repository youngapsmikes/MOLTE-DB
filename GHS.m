function [alpha] = GHS(alphanought, a, n)
% Generalized Harmonic Stepsize 
% returns stepsize of function with tuning parameter 
% a, initial alpha, and iteration number

% Output: 
% alpha - stepsize at iteration n

% Input: 
% a - tuning parameter 
% alphanought - scaling factor 
% n - iteration number 
if (n == 0) 
    error('N must be greater than zero');
end 
    
alpha = alphanought * (a/(a + n - 1));
    
end 




