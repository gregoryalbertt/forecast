%% Trabalho de Conclus�o de Curso
% Gregory Albertt Santos Carvalho 
% Instituto de Computa��o - IC
% Universidade Federal de Alagoas - UFAL
% 05/2020
%% Load variables
filename = 'C:\Users\Grego\Downloads\Dados-Completos\Dados-Completos\saidas\trainingInput.csv';
delimiter = ',';
startRow = 2;
formatSpec = '%f%f%f%f%f%f%[^\n\r]';

% Open the text file.
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');

% Close the text file.
fclose(fileID);

% Post processing for unimportable data.
% Allocate imported array to column variable names
TEMPERATURA = dataArray{:, 1};
TEMP_PAINEL = dataArray{:, 2};
IRRADIANCIA = dataArray{:, 3};
UMIDADE = dataArray{:, 4};
PRESSAO = dataArray{:, 5};
VELOCIDADE = dataArray{:, 6};
% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

%% Creating models

ARIMA_IRRADIANCIA = arima('Constant',NaN,'ARLags',1:1,'D',1,'MALags',1:1,'Distribution','Gaussian');
%ARIMA_IRRADIANCIA = arima(2,1,2);
ARIMA_IRRADIANCIA_EST = estimate(ARIMA_IRRADIANCIA,IRRADIANCIA,'Display','off');

%% Forecasting Data
k = 100000;
p = forecast(ARIMA_IRRADIANCIA_EST,k);

figure;
%plot(IRRADIANCIA,'b');
%hold on
plot(p,'r');
%legend('measured','forecasted');

%%
%[Y,YMSE] = forecast(SARIMA_IRRADIANCIA1,1000,'Y0',IRRADIANCIA);
[YF,YMSE] = forecast(SARIMA_IRRADIANCIA1,1000,IRRADIANCIA);
