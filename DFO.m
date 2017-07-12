% INPUT:
% spreedsheet - the file name of the spreedsheet that contains different 
%             problem classes
%

numTruth = 10;
spreadsheet= 'MLETest.xlsx';
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
policies=alldata(problemi+1,3:2+numberofpolicies);
profitmatrix=zeros(numberofpolicies, numTruth); % init profit matrix 
problemclass = str2func(problem);

% loop through the stepsize rules 
for i=1:numberofpolicies
    
    if pol(i)== 'adam'
%       [~, profit] = newsvendor(numTruth, @adam, 1);
        [ ~, profit] = problemclass(@adam, numTruth);
        profitmatrix(i,:)= profit;
    end
    if pol(i)== 'GHS'
%         [~, profit] = newsvendor(numTruth, @GHS, 2);
        [~, profit] = problemclass(@GHS, numTruth);
        profitmatrix(i,:)= profit;
    end
    if pol(i)== 'polylearning'
%         [~, profit] = newsvendor(numTruth, @polylearning, 3);
        [~, profit] = problemclass(@polylearning, numTruth);
        profitmatrix(i,:)= profit;
    end
    if pol(i)== 'adagrad'
%        [~, profit] = newsvendor(numTruth, @adagrad, 4);
       [~, profit] = problemclass(@adagrad, numTruth);
       profitmatrix(i,:)= profit;
    end
    if pol(i)=='BAKF'
%        [~, profit] = newsvendor(numTruth, @BAKF, 5);
       [~, profit] = problemclass(@BAKF, numTruth);
       profitmatrix(i,:)=profit;
    end
    if pol(i)=='kestens'
%         [~, profit] = newsvendor(numTruth, @kestens, 6);
        [~, profit] = problemclass(@kestens, numTruth);
        profitmatrix(i,:)=profit;
%         convmatrix(i, :) = conv;
    end
end

referenceprofit=0;
% our reference profit is how much profit is generated 
% using the first stepsize rule/policy
for i=1:numTruth
    referenceprofit= referenceprofit+profitmatrix(1,i);
end


mean_referenceprofit=referenceprofit/numTruth;
compprofitmatrix=zeros(numberofpolicies-1,numTruth);

% compute "profit"or "MSE"
% more positive equals better compared to policy in first column
for i=1:(numberofpolicies-1)
    for j=1:numTruth
        compprofitmatrix(i,j)=profitmatrix(i+1,j)-mean_referenceprofit;
    end
end

trans= zeros(numTruth,numberofpolicies-1);

for i=1:numTruth
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
colormap (color);
legend(remainingPolicies);

end 
