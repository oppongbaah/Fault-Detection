function [condition, Output, error] = my_ANFIS()
%%
clc; close all;
%%
%% LOADING DATA
TrainData = csvread('..\Data\Train_Data.csv');
TestData = csvread('..\Data\Test_Data.csv');
CheckInput = csvread('..\Data\Test_Data.csv');
%%
%% EXTRACTING THE INPUTS AND OUTPUTS FROM THE DATA
TrainInput = TrainData(:, 1:10);
TrainTarget = TrainData(:, 11);
TestInput = TestData(:, 1:10);
TestTarget = TestData(:, 11);
%%
%% SELECTION OF FIS GENERATION METHOD
Option{1}='Grid Partitioning (genfis1)';
Option{2}='Subtractive Clustering (genfis2)';
Option{3}='FCM (genfis3)';
% Save the option chosen from the dialog box in the ANSWER variable
ANSWER = questdlg('Select FIS Generation Approach:',...
                'Select GENFIS',...
                Option{1},Option{2},Option{3},...
                Option{3});
pause(0.01);
%%
%% FIS GENERATION
switch ANSWER
    case Option{1}
        Prompt={'Number of MFs','Input MF Type:','Output MF Type:'};
        Title = 'Enter genfis1 parameters';
        DefaultValues = {'5', 'gaussmf', 'linear'};
        PARAMS = inputdlg(Prompt, Title, 1, DefaultValues);
        pause(0.01);
        %
        fisOptions = genfisOptions('GridPartition');
        fisOptions.NumMembershipFunctions = str2double(PARAMS{1});
        fisOptions.InputMembershipFunctionType = PARAMS{2};
        fisOptions.OutputMembershipFunctionType = PARAMS{3};
        %       
        fis = genfis(TrainInput, TrainTarget, fisOptions);
    case Option{2}
        Prompt={'Influence Radius:', 'Data Scale', 'Squash Factor', ...
            'Accept Ratio', 'Reject Ratio' };
        Title='Enter genfis2 parameters';
        DefaultValues={'0.2', 'auto', '1.25', '0.5', '0.15', };
        PARAMS=inputdlg(Prompt, Title, 1, DefaultValues);
        pause(0.01);
        %
        fisOptions = genfisOptions('SubtractiveClustering');
        fisOptions.ClusterInfluenceRange = str2double(PARAMS{1});
        fisOptions.DataScale = PARAMS{2};
        fisOptions.SquashFactor = str2double(PARAMS{3});
        fisOptions.AcceptRatio = str2double(PARAMS{4});
        fisOptions.RejectRatio = str2double(PARAMS{5});        
        fisOptions.Verbose = 1; % show the progress information
        %
        fis = genfis(TrainInput, TrainTarget, fisOptions);   
    case Option{3}
        Prompt={'FIS Type', 'Number fo Clusters (c):',...
                'Partition Matrix Exponent (q):',...
                'Maximum Number of Iterations:',...
                'Minimum Improvemnet:'};
        Title='Enter genfis3 parameters';
        DefaultValues={'sugeno', '10', '2', '100', '1e-5'};
        PARAMS=inputdlg(Prompt,Title,1,DefaultValues);
        pause(0.01);
        %
        fisOptions = genfisOptions('FCMClustering');
        fisOptions.FISType = PARAMS{1};
        fisOptions.NumClusters = str2double(PARAMS{2});
        fisOptions.Exponent = str2double(PARAMS{3});
        fisOptions.MaxNumIteration = str2double(PARAMS{4});
        fisOptions.MinImprovement = str2double(PARAMS{5});
        fisOptions.Verbose = 1;
        %
        fis = genfis(TrainInput, TrainTarget, fisOptions);
end
%%
%% TRAIN AND VALIDATE FIS
Prompt={'Maximum Number of Epochs:',...
        'Error Goal:',...
        'Initial Step Size:',...
        'Step Size Decrease Rate:',...
        'Step Size Increase Rate:'};
Title='Enter genfis3 parameters';
DefaultValues={'100', '0', '0.01', '0.9', '1.1'};
%
PARAMS=inputdlg(Prompt,Title,1,DefaultValues);
pause(0.01);
%
options = anfisOptions;
options.InitialFIS = fis;
options.EpochNumber = str2double(PARAMS{1});
options.ErrorGoal = str2double(PARAMS{2});  
options.InitialStepSize = str2double(PARAMS{3});
options.StepSizeDecreaseRate = str2double(PARAMS{4});
options.StepSizeIncreaseRate = str2double(PARAMS{5});
%
options.DisplayANFISInformation = 1;
options.DisplayErrorValues = 1;
options.DisplayStepSize = 1;
options.DisplayFinalResults = 1;
% The validation data is the testing data
options.ValidationData = [TestInput TestTarget];
options.OptimizationMethod = 1;
% 0: Backpropagation
% 1: Hybrid   
% Train the FIS with the training data
[myAnfis, trainError,stepSize,chkFIS,chkError] = anfis(TrainData, options);  %#ok
%%
%% SAVE FIS
writeFIS(chkFIS, 'classifier.fis')
%%
%% EVALUATE FIS
% evalute the training and testing datasets to check the accuracy of the model
TrainOutput = evalfis(myAnfis, TrainInput);
TestOutput = evalfis(myAnfis, TestInput);
% Test FIS using the checking data. This gives the output of the system
Output = evalfis(myAnfis, CheckInput);
%%
%% CALCULATE ERRORS
TrainingRMSE = min(trainError); %#ok
TestingRMSE = min(chkError); %#ok
%%
%% Plot Results
figure('Name','ANFIS Training','NumberTitle','off', 'Color',[1 1 1]);
subplot(1,2,1);
plot(TrainTarget, 'b*');
hold on;
plot(TrainOutput, 'r+');
hold off
legend('Training Output','ANFIS Output','Location','NorthWest')
xlabel({'Number of epoch','(a) Training Result'},'FontWeight','bold');
ylabel({'Magnitude'},'FontWeight','bold');
%
subplot(1,2,2);
plot(trainError, '.b');
hold on;
plot(chkError,'*r');
hold off;
legend('Training Error','Testing Error','Location','NorthWest')
xlabel({'Number of epoch','(b) Training RMSE'},'FontWeight','bold');
ylabel({'Magnitude'},'FontWeight','bold');
%
if ~isempty(which('plotregression'))
    figure;
    plotregression(TrainTarget, TrainOutput, 'Train Data', ...
                   TestTarget, TestOutput, 'Test Data');
    set(gcf,'Toolbar','figure');
end
%%
%% INTERPRETATING THE RESULTS
output = round(Output);
if output == 0
    condition = 'External Fault';
%     msgbox(condition, phaseName, 'help');
    Fault = false;
    error = output - 0;
elseif output == 1
    condition = 'Ground Fault';
%     msgbox(condition, phaseName, 'help');
    Fault = true;
    error = output - 1;
elseif output == 2
    condition = 'Inrush Currents';
%     msgbox(condition, phaseName, 'help');
    Fault = false;
    error = output - 2;
elseif output == 3
    condition = 'Line Fault';
%     msgbox(condition, phaseName, 'help');
    Fault = true;
    error = output - 3;
elseif output == 4
    condition = 'No Fault';
%     msgbox(condition, phaseName, 'help');
    Fault = false;
    error = output - 4;
else
    condition = 'Healthy';
%     msgbox(condition, phaseName, 'help');
    Fault = false;
    error = output;
end
end