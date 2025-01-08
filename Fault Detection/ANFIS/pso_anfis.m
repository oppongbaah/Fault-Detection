clc; clear; close all;

function predicted = PSO_ANFIS()
    %% Load Data From a CSV File
    trainData = readtable('..\Data\Train_Data.csv');
    testData = readtable('..\Data\Test_Data.csv');
    checkData = readtable('..\Data\Check_Data.csv');
    
    %% Extract Inputs and Outputs From The Imported Data and Create a Data Object
    Data.trainInput = table2array(trainData(:, 1:10));
    Data.trainTarget = table2array(trainData(:, 11));
    Data.testInput = table2array(testData(:, 1:10));
    Data.testTarget = table2array(testData(:, 11));
    Data.checkInput = table2array(checkData(1, 1:10));
    Data.output = table2array(checkData(1, 11));
    
    %% Create The Initial FIS With Optimized Parameters From The PSO
    % FIS Options
    fisOptions = genfisOptions('FCMClustering');
    fisOptions.FISType = 'sugeno';
    fisOptions.Verbose = 1;
    % Constriction Coefficients
    kappa = 1;
    phi1 = 2.05;
    phi2 = 2.05;
    phi = phi1 + phi2;
    chi = 2*kappa/abs(2-phi-sqrt(phi^2-4*phi));
    
    % Problem Definition
    problem.CostFunction = @(x, y, z) cost_function(x, y, z);       % Cost Function
    problem.nVar = 2;                                               % Number of Unknown (Decision) Variables
    problem.varMin = [2; 1.1];                                      % Lower Bound of Decision Variables
    problem.varMax =  [15; 4];                                      % Upper Bound of Decision Variables
    
    params.fisOptions = fisOptions;                                 % Options to create the initial fis
    params.maxIteration = 10;                                      % Maximum Number of Iterations
    params.nPop = 50;                                               % Population Size (Swarm Size)
    params.w = chi;                                                 % Intertia Coefficient
    params.wdamp = 1;                                               % Damping Ratio of Inertia Coefficient
    params.c1 = chi*phi1;                                           % Personal Acceleration Coefficient
    params.c2 = chi*phi2;                                           % Social Acceleration Coefficient
    params.verbose = 1;                                             % Flag for Showing Iteration Information
    params.Data = Data;                                             % Data Object for Training and Testing
    
    % Find the Optimized Solution Using The PSO
    solution = pso(problem, params);
    anfis = solution.optimized.anfis;
    trainingError = anfis.trainingError;
    validationError = anfis.validationError;
    validationFIS = anfis.validationFIS;
    trainingOutput = solution.optimized.train;
    testingOutput = solution.optimized.test;
    predicted = solution.optimized.prediction;
    bestCosts = solution.allBestCosts;
    
    % Save FIS
    writeFIS(validationFIS, 'model.fis');
    
    % Data
    disp('PSO Optimized Paramters:');
    disp(['Number of Clusters (n): ', num2str(solution.optimized.position(1))]);
    disp(['Partition Matrix Exponent (m): ', num2str(solution.optimized.position(2))]);
    disp(['Training - Root Mean Square Error (RMSE): ', num2str(min(trainingError))]);
    disp(['Testing - Root Mean Square Error (RMSE): ', num2str(min(validationError))]);
    
    %% Plot Results
    % PSO
    figure('Name','PSO Results','NumberTitle','off', 'Color',[1 1 1]);
    semilogy(bestCosts, 'LineWidth', 2);
    xlabel('Iteration');
    ylabel('Best Cost');
    grid on;
    
    % Correlation and Regression Report
    figure('Name','ANFIS Training','NumberTitle','off', 'Color',[1 1 1]);
    subplot(1,2,1);
    plot(Data.trainTarget, 'b*');
    hold on;
    plot(trainingOutput, 'r+');
    hold off
    legend('Training Output','ANFIS Output','Location','NorthWest')
    xlabel({'Number of epoch','(a) Training Result'},'FontWeight','bold');
    ylabel({'Magnitude'},'FontWeight','bold');
    %
    subplot(1,2,2);
    plot(trainingError, '.b');
    hold on;
    plot(validationError,'*r');
    hold off;
    legend('Training Error','Testing Error','Location','NorthWest')
    xlabel({'Number of epoch','(b) Training RMSE'},'FontWeight','bold');
    ylabel({'Magnitude'},'FontWeight','bold');
    % 
    if ~isempty(which('plotregression'))
        figure;
        plotregression(Data.trainTarget, trainingOutput, 'Train Data', ...
                       Data.testTarget, testingOutput, 'Test Data');
        set(gcf,'Toolbar','figure');
    end
end

PSO_ANFIS();