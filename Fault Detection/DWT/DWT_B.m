function [E_A6, E_D1, E_D2, E_D3, E_D4, E_D5, E_D6] = DWT(ib, action)
%% CONVERT INPUT DISCRETE SAMPLES TO a 1-D SIGNAL
persistent Ib;
if isempty(Ib)
    Ib = ib;
else
    Ib = [Ib; ib];
end
%%
%% GET 1-D DISCRETE SIGNAL DIRECTLY FROM SAVED FAULTS
%%  Perform 1-D DWT
[CI,LI] = wavedec(Ib,6,'db2');
cA6 = appcoef(CI,LI,'db2',6);
cD6 = detcoef(CI,LI,6);
cD5 = detcoef(CI,LI,5);
cD4 = detcoef(CI,LI,4);
cD3 = detcoef(CI,LI,3);
cD2 = detcoef(CI,LI,2);
cD1 = detcoef(CI,LI,1);
% Plot the detail and approximate coefficients
if action == 1
    figure('Name','Discrete Wavelet Transform (Ib)','NumberTitle','off');
    subplot(4,2,1);
    plot(Ib);
    title('Original Signal (Ia)');
    subplot(4,2,2);
    plot(cA6);
    title('Approximation (A6)');
    subplot(4,2,3);
    plot(cD1);
    title('Detail (D1)');
    subplot(4,2,4);
    plot(cD2);
    title('Detail (D2)');
    subplot(4,2,5);
    plot(cD3);
    title('Detail (D3)');
    subplot(4,2,6);
    plot(cD4);
    title('Detail (D4)');
    subplot(4,2,7);
    plot(cD5);
    title('Detail (D5)');
    subplot(4,2,8);
    plot(cD6);
    title('Detail (D6)');
else
    % do nothing. The time is not up for plotting
end
%% STATISTICAL AND RMS CALCULATIONS
%{
    Statistics calculations are limited to average and variance
    RMS calculation is also done
    The statistics of only A6 and D6 coefficients will be analysed.
%}
%% Standardise the A6 and D1 - D6 coefficients
% sA6 = zscore(cA6);
% sD1 = zscore(cD1);
% sD2 = zscore(cD2);
% sD3 = zscore(cD3);
% sD4 = zscore(cD4);
% sD5 = zscore(cD5);
% sD6 = zscore(cD6);

%% Standardise the A6 and D1 - D6 coefficients
sA6 = zscore(cA6);
sD1 = zscore(cD1);
sD2 = zscore(cD2);
sD3 = zscore(cD3);
sD4 = zscore(cD4);
sD5 = zscore(cD5);
sD6 = zscore(cD6);
%Calculate the statistical parameters of all coefficients
E_A6 = (max(sA6) - min(sA6))^2;
E_D1 = (max(sD1) - min(sD1))^2;
E_D2 = (max(sD2) - min(sD2))^2;
E_D3 = (max(sD3) - min(sD3))^2;
E_D4 = (max(sD4) - min(sD4))^2;
E_D5 = (max(sD5) - min(sD5))^2;
E_D6 = (max(sD6) - min(sD6))^2;
end