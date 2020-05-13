#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Nov  2 17:17:33 2019

@author: icaro
"""

#%%
import numpy as np
from keras.models import model_from_json
from keras.models import Sequential
from keras.layers import Dense, Dropout, LSTM
from sklearn.preprocessing import  MinMaxScaler
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from keras.callbacks import EarlyStopping, ReduceLROnPlateau, ModelCheckpoint
from sklearn.externals import joblib
import json
#%% Lendo a base de treinamento
base_input = pd.read_csv("saidas/trainingInput.csv")
# pegando todas as colunas
base_input_treinamento = base_input.iloc[:,0:6].values
# normalizando os valores
normalizador = MinMaxScaler(feature_range=(0,1))
base_input_normalizada = normalizador.fit(base_input_treinamento)
base_input_normalizada = normalizador.transform(base_input_treinamento)
#salvando o normalizador
joblib.dump(normalizador, "saidas/normalizadorTrainingInput.save")
# Lendo a base de saída
base_output = pd.read_csv("saidas/trainingOutput.csv")
# Pegando todas as colunas
base_output_treinamento = base_output.iloc[:,0:2].values
# normalizando os valores
normalizador_output = MinMaxScaler(feature_range=(0,1))
base_output_normalizada = normalizador_output.fit(base_output_treinamento)
base_output_normalizada = normalizador_output.transform(base_output_treinamento)
joblib.dump(normalizador_output, "saidas/normalizadorTrainingOutput.save")
#%%
# vamos gerar os numpy array. o primeiro vai conter as 20 leituras das seis variáveis  
# de dimensão base_input_normalizada. e o segundo vai contar as tensões de saídas 
previsores = []
valor_real = []

for i in range(20, np.size(base_input_normalizada[:,0])):
    # pega os 90 anteriores
    previsores.append(base_input_normalizada[i-20:i,:])
    # pega o 91 para ser a saída correspondente as 90 leituras anteriores 
    valor_real.append(base_output_normalizada[i,:])

# É necessários transformar em numpy arrays pois a rede so aceita esse tipo de entrada
previsores, valor_real = np.array(previsores), np.array(valor_real)
#%% Criação da rede neural
# A rede vai ser do tipo sequencial. alimentada para frente
regressor = Sequential()
# Vamos acrescentar uma primeira camada LSTM com 30 camadas "enroladas" na camada escondida
# o parâmetro return_sequences significa que ele vai passar o resultado para frente  para as próximas camadas
# no input_shape dizemos como é a nossa entrada. temos seis entradas atrasadas ou amostrada em 20 segundos
# return_sequences retornam a saída do estado oculto para cada etapa do tempo de entrada.
regressor.add(LSTM(units = 30, input_shape = (previsores.shape[1],6)))
# Vamos criar a camada de saída 
regressor.add(Dense(units = 2, activation = 'linear'))
# Vamos compilar a rede
regressor.compile(optimizer = 'adam', loss = 'mean_squared_error', metrics = ['mean_absolute_error', 'mean_squared_logarithmic_error'])
# função early stop vai para de treinar a rede se algum parâmetro monitorado parou de melhorar
es = EarlyStopping(monitor ='loss', min_delta = 1e-10, patience = 10, verbose = 1)
# ele vai reduzir a taxa de aprendizagem quando uma metrica parou de melhorar
rlr = ReduceLROnPlateau(monitor = 'loss', factor = 0.2, patience = 5, verbose = 1)
mcp =  ModelCheckpoint(filepath='saidas/pesos_lstm.h5', monitor = 'loss', save_best_only= True)
history = regressor.fit(previsores, valor_real, epochs = 100, batch_size = 500, callbacks = [es,rlr,mcp])
regressor_json = regressor.to_json()
with open('saidas/regressor_lstm.json', 'w') as json_file:
    json_file.write(regressor_json)
#%% Saving fit history
def saveHist(path,history):

    new_hist = {}
    for key in list(history.history.keys()):
        if type(history.history[key]) == np.ndarray:
            new_hist[key] == history.history[key].tolist()
        elif type(history.history[key]) == list:
           if  type(history.history[key][0]) == np.float64:
               new_hist[key] = list(map(float, history.history[key]))

    print(new_hist)
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(new_hist, f, separators=(',', ':'), sort_keys=True, indent=4) 

saveHist('saidas/history_lstm', history)