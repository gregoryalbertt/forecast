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
set(gca,'XTick',0:1440:33119)
set(gca,'XTickLabel',1:1:12)
xlabel('Dia');
ylabel('Irradiância 1º diff')

figure;
plot(IRRADIANCIA_d1,'b');

figure;
plot(IRRADIANCIA_d2,'r');

figure;
plot(IRRADIANCIA_ds,'r');

figure
subplot(2,1,1)
autocorr(IRRADIANCIA)
title('Função de Autocorrelação (ACF)')
xlabel('Atraso')
ylabel('Autocorrelação')
subplot(2,1,2)
parcorr(IRRADIANCIA)
title('Função de Autocorrelação Parcial (PACF)')
xlabel('Atraso')
ylabel('Autocorrelação Parcial')

figure
subplot(2,1,1)
autocorr(IRRADIANCIA_d1)
title('Função de Autocorrelação (ACF)')
xlabel('Atraso')
ylabel('Autocorrelação')
subplot(2,1,2)
parcorr(IRRADIANCIA_d1)
title('Função de Autocorrelação Parcial (PACF)')
xlabel('Atraso')
ylabel('Autocorrelação Parcial')

figure
subplot(2,1,1)
autocorr(IRRADIANCIA_d2)
title('Função de Autocorrelação (ACF)')
xlabel('Atraso')
ylabel('Autocorrelação')
subplot(2,1,2)
parcorr(IRRADIANCIA_d2)
title('Função de Autocorrelação Parcial (PACF)')
xlabel('Atraso')
ylabel('Autocorrelação Parcial')

figure
subplot(2,1,1)
autocorr(IRRADIANCIA_ds)
title('Função de Autocorrelação (ACF)')
xlabel('Atraso')
ylabel('Autocorrelação')
subplot(2,1,2)
parcorr(IRRADIANCIA_ds)
title('Função de Autocorrelação Parcial (PACF)')
xlabel('Atraso')
ylabel('Autocorrelação Parcial')


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

% SARIMA (1,1,1)(1,1,1)1440
SARIMA_b11 = arima('Constant',NaN,'ARLags',1,'D',1,'MALags',1,'SARLags',seasonality,'Seasonality',1440,'SMALags',seasonality,'Distribution','Gaussian');
[SARIMA_b11,EstParamCov1,logL1,info1] = estimate(SARIMA_b11,IRRADIANCIA,'Display','off');

% SARIMA (2,1,2)(1,1,1)1440
SARIMA_b12 = arima('Constant',NaN,'ARLags',1:2,'D',1,'MALags',1:2,'SARLags',seasonality,'Seasonality',1440,'SMALags',seasonality,'Distribution','Gaussian');
[SARIMA_b12,EstParamCov2,logL2,info2] = estimate(SARIMA_b12,IRRADIANCIA,'Display','off');

% SARIMA (3,1,3)(1,1,1)1440
SARIMA_b13 = arima('Constant',NaN,'ARLags',1:3,'D',1,'MALags',1:3,'SARLags',seasonality,'Seasonality',1440,'SMALags',seasonality,'Distribution','Gaussian');
[SARIMA_b13,EstParamCov3,logL3,info3] = estimate(SARIMA_b13,IRRADIANCIA,'Display','off');

% SARIMA (4,1,4)(1,1,1)1440
SARIMA_b14 = arima('Constant',NaN,'ARLags',1:4,'D',1,'MALags',1:4,'SARLags',seasonality,'Seasonality',1440,'SMALags',seasonality,'Distribution','Gaussian');
[SARIMA_b14,EstParamCov4,logL4,info4] = estimate(SARIMA_b14,IRRADIANCIA,'Display','off');

% SARIMA (5,1,5)(1,1,1)1440
SARIMA_b15 = arima('Constant',NaN,'ARLags',1:5,'D',1,'MALags',1:5,'SARLags',seasonality,'Seasonality',1440,'SMALags',seasonality,'Distribution','Gaussian');
[SARIMA_b15,EstParamCov5,logL5,info5] = estimate(SARIMA_b15,IRRADIANCIA,'Display','off');


%%
ARIMA_IRRADIANCIA_SEL = SARIMA_b13;

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
residuals_21 = infer(SARIMA_b1, IRRADIANCIA);
residuals_22 = infer(SARIMA_b12, IRRADIANCIA);
residuals_23 = infer(SARIMA_b13, IRRADIANCIA);
residuals_24 = infer(SARIMA_b14,IRRADIANCIA);
residuals_25 = infer(SARIMA_b15, IRRADIANCIA);

%% histograma dos residuos
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

%% day plot 

figure;
plot(IRRADIANCIA((t-k):t))
hold on
plot(YF,'r')

%%
SARIMA_b14 = arima('Constant',NaN,'ARLags',1:3,'D',1,'MALags',1:3,'SARLags',1440,'Seasonality',1440,'SMALags',1440,'Distribution','Gaussian');
[SARIMA_b14,EstParamCov3,logL3,info3] = estimate(SARIMA_b14,IRRADIANCIA,'Display','off');

ARIMA_IRRADIANCIA_SEL = SARIMA_b14;

k = 1440; % um dia
[YF,YMSE] = forecast(ARIMA_IRRADIANCIA_SEL,k,'Y0',IRRADIANCIA(1:(T-k)));

%% 
[YF_b1,YMSE_b1] = forecast(SARIMA_b1,k,'Y0',IRRADIANCIA(1:(T-k)));
[YF_b12,YMSE_b12] = forecast(SARIMA_b12,k,'Y0',IRRADIANCIA(1:(T-k)));
[YF_b13,YMSE_b13] = forecast(SARIMA_b13,k,'Y0',IRRADIANCIA(1:(T-k)));
%[YF_b14,YMSE_b14] = forecast(SARIMA_b14,k,'Y0',IRRADIANCIA(1:(T-k)));
[YF_b15,YMSE_b15] = forecast(SARIMA_b15,k,'Y0',IRRADIANCIA(1:(T-k)));

%% Plot resíduos
%SARIMA (1,1,1)(2,0,2)
% figure;
% hist_21 = histogram(residuals_21);
% title('Histograma SARIMA(1,1,1)(2,0,2)')
[hQQ_21,pValueQQ_21] = lbqtest(residuals_21,'lags',(1:20));
stdRes_21 = residuals_21/sqrt(SARIMA_b1.Variance);

figure;
subplot(3,2,[1,2]);
plot(stdRes_21)
title('Resíduos normalizados SARIMA(1,1,1)(2,0,2)')
subplot(3,2,3);
autocorr(residuals_21)
title('ACF dos Resíduos')
xlabel('Atraso')
ylabel('ACF')
subplot(3,2,4);
qqplot(residuals_21);
title('Gráfico QQ')
xlabel('Quantidades normais padrão')
ylabel('Quantidade de amostra de entrada')
ylabel('Amostra de entrada')
subplot(3,2,[5,6]);
plot(pValueQQ_21, 'bo');
title('Valores de p do teste Lung-Box')
xlabel('Atraso')
ylabel('p-valor')

%% SARIMA (2,1,2)(2,1,2)
% 
% figure;
% hist_22 = histogram(residuals_22);
% title('Histograma SARIMA(1,1,1)(2,0,2)')
[hQQ_22,pValueQQ_22] = lbqtest(residuals_22,'lags',(1:20));
stdRes_22 = residuals_22/sqrt(SARIMA_b12.Variance);

figure;
subplot(3,2,[1,2]);
plot(stdRes_22)
title('Resíduos normalizados SARIMA(2,1,2)(2,1,2)')
subplot(3,2,3);
autocorr(residuals_22)
title('ACF dos Resíduos')
xlabel('Atraso')
ylabel('ACF')
subplot(3,2,4);
qqplot(residuals_22);
title('Gráfico QQ')
xlabel('Quantidades normais padrão')
ylabel('Quantidade de amostra de entrada')
ylabel('Amostra de entrada')
subplot(3,2,[5,6]);
plot(pValueQQ_22, 'bo');
title('Valores de p do teste Lung-Box')
xlabel('Atraso')
ylabel('p-valor')

%% SARIMA (3,1,3)(2,1,2)
% 
% figure;
% hist_23 = histogram(residuals_23);
% title('Histograma SARIMA(3,1,3)(2,1,2)')
[hQQ_23,pValueQQ_23] = lbqtest(residuals_23,'lags',(1:20));
stdRes_23 = residuals_23/sqrt(SARIMA_b13.Variance);

figure;
subplot(3,2,[1,2]);
plot(stdRes_23)
title('Resíduos normalizados SARIMA(3,1,3)(2,1,2)')
subplot(3,2,3);
autocorr(residuals_23)
title('ACF dos Resíduos')
xlabel('Atraso')
ylabel('ACF')
subplot(3,2,4);
qqplot(residuals_23);
title('Gráfico QQ')
xlabel('Quantidades normais padrão')
ylabel('Quantidade de amostra de entrada')
ylabel('Amostra de entrada')
subplot(3,2,[5,6]);
plot(pValueQQ_23, 'bo');
title('Valores de p do teste Lung-Box')
xlabel('Atraso')
ylabel('p-valor')

%% SARIMA (5,1,5)(2,1,2)
% 
% figure;
% hist_23 = histogram(residuals_23);
% title('Histograma SARIMA(3,1,3)(2,1,2)')
[hQQ_25,pValueQQ_25] = lbqtest(residuals_25,'lags',(1:20));
stdRes_25 = residuals_25/sqrt(SARIMA_b15.Variance);

figure;
subplot(3,2,[1,2]);
plot(stdRes_25)
title('Resíduos normalizados SARIMA(5,1,5)(2,1,2)')
subplot(3,2,3);
autocorr(residuals_25)
title('ACF dos Resíduos')
xlabel('Atraso')
ylabel('ACF')
subplot(3,2,4);
qqplot(residuals_25);
title('Gráfico QQ')
xlabel('Quantidades normais padrão')
ylabel('Quantidade de amostra de entrada')
ylabel('Amostra de entrada')
subplot(3,2,[5,6]);
plot(pValueQQ_25, 'bo');
title('Valores de p do teste Lung-Box')
xlabel('Atraso')
ylabel('p-valor')

