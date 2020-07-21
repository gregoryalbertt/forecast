%% Trabalho de Conclusão de Curso
% Gregory Albertt Santos Carvalho 
% Instituto de Computação - IC
% Universidade Federal de Alagoas - UFAL
% 05/2020
%% Load variables
clear; clc;
filename = 'Dados-Completos\saidas\trainingInput.csv';
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

% TEMPERATURA = dataArray{:, 1};
% TEMP_PAINEL = dataArray{:, 2};
IRRADIANCIA = dataArray{:, 3};
% UMIDADE = dataArray{:, 4};
% PRESSAO = dataArray{:, 5};
% VELOCIDADE = dataArray{:, 6};

% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

%% seconds to minutes

n = 60; % average every n values
IRRADIANCIA = arrayfun(@(i) mean(IRRADIANCIA(i:i+n-1)),1:n:length(IRRADIANCIA)-n+1)'; % the averaged vector
T = length(IRRADIANCIA);
%% Box-Jenkins Method
%% 1. Identification:

% primeira diff
IRRADIANCIA_d1 = diff(IRRADIANCIA);

% segunda diff
IRRADIANCIA_d2 = diff(IRRADIANCIA_d1);

% diff sazonal
D = LagOp({1 -1},'Lags',[0,1440]);
IRRADIANCIA_ds = filter(D,IRRADIANCIA);

%% plots
figure;
plot(IRRADIANCIA,'k');
hold on

plot(IRRADIANCIA_d1,'b');

plot(IRRADIANCIA_d2,'r');

plot(IRRADIANCIA_ds,'r');

hold off

figure
subplot(2,1,1)
autocorr(IRRADIANCIA)
subplot(2,1,2)
parcorr(IRRADIANCIA)

figure
subplot(2,1,1)
autocorr(IRRADIANCIA_d1)
subplot(2,1,2)
parcorr(IRRADIANCIA_d1)

figure
subplot(2,1,1)
autocorr(IRRADIANCIA_d2)
subplot(2,1,2)
parcorr(IRRADIANCIA_d2)

figure
subplot(2,1,1)
autocorr(IRRADIANCIA_ds)
subplot(2,1,2)
parcorr(IRRADIANCIA_ds)

%% Testes

% Testes raiz unitária:
% hipotese nula de raiz unitaria
% h = 0 indica que o teste falhou em rejeitar  hipótese nula. Logo não há
% evidência que possa sugerir a estacionariedade da série.

% Dickey-Fuller test
[h,pValue,stat,cValue,reg] = adftest(IRRADIANCIA);
[h_d1,pValue_d1,stat_d1,cValue_d1,reg_d1] = adftest(IRRADIANCIA_d1);
[h_d2,pValue_d2,stat_d2,cValue_d2,reg_d2] = adftest(IRRADIANCIA_d2);
[h_ds,pValue_ds,stat_ds,cValue_ds,reg_ds] = adftest(IRRADIANCIA_ds);

% Phillips-Perron test

[h_pp,pValue_pp,stat_pp,cValue_pp,reg_pp] = pptest(IRRADIANCIA);
[h_ppd1,pValue_ppd1,stat_ppd1,cValue_ppd1,reg_ppd1] = pptest(IRRADIANCIA_d1);
[h_ppd2,pValue_ppd2,stat_ppd2,cValue_ppd2,reg_ppd2] = pptest(IRRADIANCIA_d2);
[h_ppds,pValue_ppds,stat_ppds,cValue_ppds,reg_ppds] = pptest(IRRADIANCIA_ds);

% Testes estacionariedade

% KPPS test
% h = 1 indica a rejeição da hipótese nula de estacionariedade. Logo não há
% evidência que possa sugerir a estacionariedade da série.
[h_kp,pValue_kp,stat_kp,cValue_kp,reg_kp] = kpsstest(IRRADIANCIA);
[h_kpd1,pValue_kpd1,stat_kpd1,cValue_kpd1,reg_kpd1] = kpsstest(IRRADIANCIA_d1);
[h_kpd2,pValue_kpd2,stat_kpd2,cValue_kpd2,reg_kpd2] = kpsstest(IRRADIANCIA_d2);
[h_kpds,pValue_kpds,stat_kpds,cValue_kpds,reg_kpds] = kpsstest(IRRADIANCIA_ds);

% Leybourne-McCabe test
[h_lm,pValue_lm,stat_lm,cValue_lm,reg1] = lmctest(IRRADIANCIA);
[h_lmd1,pValue_lmd1,stat_lmd1,cValue_lmd1,reg1d1] = lmctest(IRRADIANCIA_d1);
[h_lmd2,pValue_lmd2,stat_lmd2,cValue_lmd2,reg1d2] = lmctest(IRRADIANCIA_d2);
[h_lmds,pValue_lmds,stat_lmds,cValue_lmds,reg1ds] = lmctest(IRRADIANCIA_ds);

%% 2: Estimacao

% %Selecionando ordens a partir do resultado dos testes
% p = 3;
% q = 3;
% d = 2;
% 
% %ARIMA_IRRADIANCIA = arima('Constant',NaN,'ARLags',1:1,'D',1,'MALags',1:1,'Distribution','Gaussian');
% 
% %counter
% m = 1;
% 
% for i = 0:p
%     for j = 0:d
%         for k = 0:q
%             ARIMA_IRRADIANCIA{m} = arima(i,j,k);
%             [ARIMA_IRRADIANCIA_EST{m},EstParamCov{m},logL{m},info{m}] = estimate(ARIMA_IRRADIANCIA{m},IRRADIANCIA,'Display','off');
%             PDQ(m) = p + d + q;
%             %counter4
%             m = m + 1 ;
%         end
%     end
% end

%% SARIMA
seasonality = 1440;

% SARIMA (1,1,1)(1,0,1)1440
SARIMA_b1 = arima('Constant',NaN,'ARLags',1,'D',1,'MALags',1,'SARLags',1440,'Seasonality',0,'SMALags',1440,'Distribution','Gaussian');
[SARIMA_b1,EstParamCov1,logL1,info1] = estimate(SARIMA_b1,IRRADIANCIA,'Display','off');

% SARIMA (2,1,2)(2,1,2)1440
SARIMA_b12 = arima('Constant',NaN,'ARLags',1:2,'D',1,'MALags',1:2,'SARLags',[1440,2880],'Seasonality',1440,'SMALags',[1440,2880],'Distribution','Gaussian');
[SARIMA_b12,EstParamCov2,logL2,info2] = estimate(SARIMA_b12,IRRADIANCIA,'Display','off');

ARIMA_IRRADIANCIA_SEL = SARIMA_b12;

% %% 3. Diagnostico
% % AIC e BIC
% % medidas de informação
% % qualidade em função da quantidade de termos
%  
%  for n = 1:(m-1) 
%     [aic(n),bic(n)] = aicbic(logL{n},PDQ(n),T);
%  end
% 
% % escolhendo modelo com menor AIC
% 
% [aic_min,Ia] = min(aic); 
% [bic_min,Ib] = min(bic); 
% 
% ARIMA_IRRADIANCIA_SEL = ARIMA_IRRADIANCIA_EST{Ia}
% 
% 
% % Propriedades do modelo selecionado
% %ARIMA_IRRADIANCIA_SEL.Report.Fit
%%
% residuos
residuals = infer(ARIMA_IRRADIANCIA_SEL,IRRADIANCIA);

% histograma dos residuos
figure;
histogram(residuals);

% Residuals Quantile-quantile plot 
figure;
qqplot(residuals);

% Residuals Sample autocorrelation plot and Sample Partial
figure;
subplot(2,1,1)
autocorr(residuals);
subplot(2,1,2)
parcorr(residuals);

% Ljung-Box Q-test for residual autocorrelation
h = lbqtest(residuals);

prediction = IRRADIANCIA+residuals;



%% 4. Previsao
k = 1440; % um dia
[YF,YMSE] = forecast(ARIMA_IRRADIANCIA_SEL,k,'Y0',IRRADIANCIA(1:(T-k)));
%% plot
figure
h1 = plot(IRRADIANCIA,'Color',[.7,.7,.7]);
hold on
h2 = plot((T-k+1):T,YF,'b','LineWidth',2);
h3 = plot((T-k+1):T,YF + 1.96*sqrt(YMSE),'r:',...
		'LineWidth',2);
plot((T-k+1):T,YF - 1.96*sqrt(YMSE),'r:','LineWidth',2);
legend([h1 h2 h3],'Observed','Forecast',...
		'95% Confidence Interval','Location','NorthWest');
title(['Day Ahead Forecasts and Approximate 95% '...
			'Confidence Intervals'])
hold off

