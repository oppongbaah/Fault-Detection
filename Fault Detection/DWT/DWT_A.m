function [reA4_Ia,reD4_Ia,reD3_Ia,reD2_Ia,reD1_Ia,stdA4_Ia,stdD4_Ia,stdD3_Ia,stdD2_Ia,stdD1_Ia] = DWT(ia, action)
%% CONVERT INPUT DISCRETE SAMPLES TO a 1-D SIGNAL
persistent Ia;
if isempty(Ia)
    Ia = ia;
else
    Ia = [Ia; ia];
end
%%
%% GET 1-D DISCRETE SIGNAL DIRECTLY FROM SAVED FAULTS
[CIa,LIa] = wavedec(Ia,4,'db4');
A4_Ia = appcoef(CIa,LIa,'db4',4);
D4_Ia = detcoef(CIa,LIa,4);
D3_Ia = detcoef(CIa,LIa,3);
D2_Ia = detcoef(CIa,LIa,2);
D1_Ia = detcoef(CIa,LIa,1);
%
if action == 1
    figure('Name','Discrete Wavelet Transform (Ia)','NumberTitle','off');
    subplot(3,2,1);
    plot(Ia);
    title('Original Signal (Ia)');
    subplot(3,2,2);
    plot(A4_Ia);
    title('Approximation (A4)');
    subplot(3,2,3);
    plot(D1_Ia);
    title('Detail (D1)');
    subplot(3,2,4);
    plot(D2_Ia);
    title('Detail (D2)');
    subplot(3,2,5);
    plot(D3_Ia);
    title('Detail (D3)');
    subplot(3,2,6);
    plot(D4_Ia);
    title('Detail (D4)');
end
%% STATISTICAL AND RMS CALCULATIONS
Ej_A4_Ia = sum(A4_Ia.^2);
Ej_D4_Ia = sum(D4_Ia.^2);
Ej_D3_Ia = sum(D3_Ia.^2);
Ej_D2_Ia = sum(D2_Ia.^2);
Ej_D1_Ia = sum(D1_Ia.^2);
E_total_Ia = Ej_A4_Ia + Ej_D4_Ia + Ej_D3_Ia + Ej_D2_Ia + Ej_D1_Ia;
reA4_Ia = Ej_A4_Ia / E_total_Ia;
reD4_Ia = Ej_D4_Ia / E_total_Ia;
reD3_Ia = Ej_D3_Ia / E_total_Ia;
reD2_Ia = Ej_D2_Ia / E_total_Ia;
reD1_Ia = Ej_D1_Ia / E_total_Ia;
stdA4_Ia = std(A4_Ia);
stdD4_Ia = std(D4_Ia);
stdD3_Ia = std(D3_Ia);
stdD2_Ia = std(D2_Ia);
stdD1_Ia = std(D1_Ia);
end