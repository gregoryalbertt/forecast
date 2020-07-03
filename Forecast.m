%% Trabalho de Conclus�o de Curso
% Gregory Albertt Santos Carvalho 
% Instituto de Computa��o - IC
% Universidade Federal de Alagoas - UFAL
% 05/2020
%% Load variables
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
TEMPERATURA = dataArray{:, 1};
TEMP_PAINEL = dataArray{:, 2};
IRRADIANCIA = dataArray{:, 3};
UMIDADE = dataArray{:, 4};
PRESSAO = dataArray{:, 5};
VELOCIDADE = dataArray{:, 6};

% Length
T = length(IRRADIANCIA);
% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

%% Box-Jenkins Method
%% 1. Identification:

% primeira diff
IRRADIANCIA_d1 = diff(IRRADIANCIA);

% segunda diff
IRRADIANCIA_d2 = diff(IRRADIANCIA_d1);

%% plots
figure;
plot(IRRADIANCIA,k);
hold on
plot(IRRADIANCIA_d1,b);
hold on
plot(IRRADIANCIA_d2,c);
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

%% Testes

% Testes raiz unit�ria:

% dick-fulley test
[h,pValue,stat,cValue,reg] = adftest(IRRADIANCIA);
[h_d1,pValue_d1,stat_d1,cValue_d1,reg_d1] = adftest(IRRADIANCIA_d1);
[h_d2,pValue_d2,stat_d2,cValue_d2,reg_d2] = adftest(IRRADIANCIA_d2);

% Philip Perron test
[h_pp,pValue_pp,stat_pp,cValue_pp,reg_pp] = pptest(IRRADIANCIA);
[h_ppd1,pValue_ppd1,stat_ppd1,cValue_ppd1,reg_ppd1] = pptest(IRRADIANCIA_d1);
[h_ppd2,pValue_ppd2,stat_ppd2,cValue_ppd2,reg_ppd2] = pptest(IRRADIANCIA_d2);

% Testes estacionariedade

% KPPS test
[h_kp,pValue_kp,stat_kp,cValue_kp,reg_kp] = kpsstest(IRRADIANCIA);
[h_kpd1,pValue_kpd1,stat_kpd1,cValue_kpd1,reg_kpd1] = kpsstest(IRRADIANCIA_d1);
[h_kpd2,pValue_kpd2,stat_kpd2,cValue_kpd2,reg_kpd2] = kpsstest(IRRADIANCIA_d2);

% Leybourne-McCabe test
[h_lm,pValue_lm,stat_lm,cValue_lm,reg1] = lmctest(IRRADIANCIA);
[h_lmd1,pValue_lmd1,stat_lmd1,cValue_lmd1,reg1d1] = lmctest(IRRADIANCIA_d1);
[h_lmd2,pValue_lmd2,stat_lmd2,cValue_lmd2,reg1d2] = lmctest(IRRADIANCIA_d2);

%% 2: Estimacao

%Selecionando ordens a partir do resultado dos testes
p = 3;
q = 3;
d = 2;

%ARIMA_IRRADIANCIA = arima('Constant',NaN,'ARLags',1:1,'D',1,'MALags',1:1,'Distribution','Gaussian');

%counter
m = 1;

for i = 0:p
    for j = 0:d
        for k = 0:q
            ARIMA_IRRADIANCIA{m} = arima(i,j,k);
            [ARIMA_IRRADIANCIA_EST{m},EstParamCov{m},logL{m},info{m}] = estimate(ARIMA_IRRADIANCIA{m},IRRADIANCIA,'Display','off');
            PDQ(m) = p + d + q;
            %counter4
            m = m + 1 ;
        end
    end
end

%% 3. Diagnostico
% AIC e BIC

 for n = 1:(m-1)
    [aic(n),bic(n)] = aicbic(logL{n},PDQ(n),T);
 end

% escolhendo modelo com menor AIC

[aic_min,Ia] = min(aic); 
[bic_min,Ib] = min(bic); 

ARIMA_IRRADIANCIA_SEL = ARIMA_IRRADIANCIA_EST{Ia}


% Propriedades do modelo selecionado
%ARIMA_IRRADIANCIA_SEL.Report.Fit

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
k = 10000;
% 
% [yF,yMSE] = forecast(ARIMA_IRRADIANCIA_EST{i},k,IRRADIANCIA);
% UB = yF + 1.96*sqrt(yMSE);
% LB = yF - 1.96*sqrt(yMSE);
% 
% figure;
% for i = 1:(m-1)
%     plot(forecast(ARIMA_IRRADIANCIA_EST{i},k),'r');
%     hold on
% end
%p = forecast(ARIMA_IRRADIANCIA_EST,k);
%plot(IRRADIANCIA,'b');
%legend('measured','forecasted');

[YF,YMSE] = forecast(ARIMA_IRRADIANCIA_EST{7},k,'Y0',IRRADIANCIA(1:(T-k)));
%% plot
figure
h1 = plot(IRRADIANCIA(T-k:T),'Color',[.7,.7,.7]);
hold on
h2 = plot((T-k+1):T,YF,'b','LineWidth',2);
h3 = plot((T-k+1):T,YF + 1.96*sqrt(YMSE),'r:',...
		'LineWidth',2);
plot((T-k+1):T,YF - 1.96*sqrt(YMSE),'r:','LineWidth',2);
legend([h1 h2 h3],'Observed','Forecast',...
		'95% Confidence Interval','Location','NorthWest');
title(['30-Period Forecasts and Approximate 95% '...
			'Confidence Intervals'])
hold off

%%
%[Y,YMSE] = forecast(SARIMA_IRRADIANCIA1,1000,'Y0',IRRADIANCIA);
[YF,YMSE] = forecast(SARIMA_IRRADIANCIA1,1000,IRRADIANCIA);
