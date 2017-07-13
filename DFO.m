% INPUT:
% spreedsheet - the file name of the spreedsheet that contains different c
%             problem classes
%

% number of times we simulate each problem for newsvendor and MLE
% for energy policy this is the number of time we perform the 
% random restart for gradient ascent 
numSim = 10; 
spreadsheet= 'DerivativeFree.xlsx';
[ndata, text, alldata] = xlsread(spreadsheet,'','','basic');
[numPPp, numA]=size(ndata);

numPP=numPPp;
% addpath('StepPolicies');

% loop through the problems ie. the rows of the spreadsheet
for problemi = 1:numPP 

% problem = alldata{2, 1};
problem = alldata{problemi+1, 1}; 

% numberofpolicies=alldata{2,2};
numberofpolicies=alldata{problemi+1,2};

pol=strings(numberofpolicies,1);


% read in the policies as strings 
for i=1:numberofpolicies
%     pol(i)= string(text(2,i+2));
    pol(i)= string(text(problemi+1,i+2));
end


% policies=alldata(2,3:2+numberofpolicies);

% transform input string to function handle so we can call stepsize
% functions 
problemclass = str2func(problem);

if strcmp(problem, 'energyinventory')
   numSim = 5;
end
policies=alldata(problemi+1,3:2+numberofpolicies);
profitmatrix=zeros(numberofpolicies, numSim); % init profit matrix 


% loop through the stepsize rules 
for i=1:numberofpolicies
    
    if pol(i)== 'adam'
        [ ~, profit] = problemclass(@adam, numSim);
        profitmatrix(i,:)= profit;
    end
    if pol(i)== 'GHS'
        [~, profit] = problemclass(@GHS, numSim);
        profitmatrix(i,:)= profit;
    end
    if pol(i)== 'polylearning'
        [~, profit] = problemclass(@polylearning, numSim);
        profitmatrix(i,:)= profit;
    end
    if pol(i)== 'adagrad'
       [~, profit] = problemclass(@adagrad, numSim);
       profitmatrix(i,:)= profit;
    end
    if pol(i)=='BAKF'
       [~, profit] = problemclass(@BAKF, numSim);
       profitmatrix(i,:)=profit;
    end
    if pol(i)=='kestens'
        [~, profit] = problemclass(@kestens, numSim);
        profitmatrix(i,:)=profit;
    end
end

referenceprofit=0;
% our reference profit is how much profit is generated 
% using the first stepsize rule/policy
for i=1:numSim
    referenceprofit= referenceprofit+profitmatrix(1,i);
end


mean_referenceprofit=referenceprofit/numSim;
compprofitmatrix=zeros(numberofpolicies-1,numSim);

% compute "profit"or "MSE"
% positive equals better compared to policy in first column
for i=1:(numberofpolicies-1)
    for j=1:numSim
        compprofitmatrix(i,j)=profitmatrix(i+1,j)-mean_referenceprofit;
    end
end

trans= zeros(numSim,numberofpolicies-1);

for i=1:numSim
    for j=1:(numberofpolicies-1)
        trans(i,j)= compprofitmatrix(j,i);
    end
end


% create histograms 

color=[1,0,0;0,0.95,0.95;0.6,0.3,0.9;0,1,0;1,1,0;1,0.25,0.75;0,0.5,0.75;0.5,0.95,0.75;];
firstPolicy=policies{1};
remainingPolicies=policies(2:length(policies));
figure
% hist(trans(:,1:(numberofpolicies-1)),200);

hist(trans(:,1:(numberofpolicies-1)), 200);

% this is to make sure the y limits are correct for energy inventory
% histogram since we only obtain one profit for each policy
if strcmp(problem, 'energyinventory')
   ylim([0 1]);
end
colormap (color);
legend(remainingPolicies);

end 
