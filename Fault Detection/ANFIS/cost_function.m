%% Trains the Initial FIS and computes the RMSE
function [rmse, ANFIS, train, test, prediction] = cost_function(position, fisOptions, Data)
    fisOptions.NumClusters = position(1);
    fisOptions.Exponent = position(2);

    options = anfisOptions;
    options.ValidationData = [Data.testInput Data.testTarget];
    options.EpochNumber = 100;
    data = [Data.trainInput Data.trainTarget];

    try
        options.InitialFIS = genfis(Data.trainInput, Data.trainTarget, fisOptions);
        [trainingFIS, trainingError, ~, validationFIS, validationError] = anfis(data, options);
    catch
        fisOptions.NumClusters = 10;
        fisOptions.Exponent = 2;
        options.InitialFIS = genfis(Data.trainInput, Data.trainTarget, fisOptions);
        [trainingFIS, trainingError, ~, validationFIS, validationError] = anfis(data, options);
    end

    % evalute the training and testing datasets to check the accuracy of the model
    train = evalfis(trainingFIS, Data.trainInput);
    test = evalfis(trainingFIS, Data.testInput);
    prediction = evalfis(trainingFIS, Data.checkInput);
    ANFIS.trainingError = trainingError;
    ANFIS.validationError = validationError;
    ANFIS.trainingFIS = trainingFIS;
    ANFIS.validationFIS = validationFIS;
    rmse = min(trainingError) + min(validationError);
end