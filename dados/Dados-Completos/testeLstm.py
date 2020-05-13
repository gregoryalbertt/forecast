#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Nov  2 18:18:57 2019

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
#%%
# Abrindo o arquivo que contém a estrutura da rede
arquivo = open('saidas/regressor_lstm.json', 'r')
estrutura_rede = arquivo.read()
# Fechando o arquivo
arquivo.close()
# Pegando a estrutura da rede
classificador = model_from_json(estrutura_rede)
# Lendo os pesos salvos e colocando na rede neural
classificador.load_weights('saidas/pesos_lstm.h5.h5')
#%%
# Lendo o arquivo de entrada de teste
base_teste = pd.read_csv('saidas/testeInput.csv')
# Pegando todas as variáveis de entrada
base_teste = base_teste.iloc[:,0:6].values
# Carregando o normalizador dos dados de entrada da base de treinamento. 
# Será usada para normalizar nossos dados de entrada do teste
normalizador = joblib.load("saidas/normalizadorTrainingInput.save")
base_teste_normalizada = normalizador.transform(base_teste)

# Carregando o normalizador dos dados de saída da base de treinamento.
# Será utilizado para inverter as previsoes geradas para os valores reais de leitura.
normalizador_output = joblib.load("saidas/normalizadorTrainingOutput.save")

# Lendo a base de saída
base_teste_output = pd.read_csv('saidas/testeOutput.csv')
#Pegando todos os valores de saídas
base_teste_output_treinamento = base_teste_output.iloc[:,0:2].values
#%%
entradas = []
saidas   = []
# esse for vai criar as matrizes de três dimensões. Dos dados de entrada de teste
# E os valores reais dos dados de saída para ser comparado com os valores previstos pela rede
for i in range(20, np.size(base_teste_normalizada[:,0])):
    # pega os 20 anteriores
    entradas.append(base_teste_normalizada[i-20:i,:])
    # pega o 21 para ser a saída correspondente as 90 leituras anteriores 
    saidas.append(base_teste_output_treinamento[i,:])

entradas, saidas = np.array(entradas), np.array(saidas)
# Fazendo a predição dos valores
previsoes = classificador.predict(entradas)
print(previsoes)
previsoes = normalizador_output.inverse_transform(previsoes)
saidas = np.reshape(saidas,(saidas.shape[0], 2))
#%%
np.savetxt('saidas/previsores.txt', previsoes[:,0], fmt='%f')  # É salvo os valores para ser usado por outro script 
np.savetxt('saidas/saida.txt', saidas[:,0], fmt='%f')          # É salvo os valores para ser usado por outro script
plt.subplot(2,1,1); plt.title("Tensão"); plt.plot(saidas[:,0], color= 'red', label = 'Tensão Real')
plt.subplot(2,1,1); plt.plot(previsoes[:,0], color= 'blue', label = 'Tensão Prevista')
plt.legend()
plt.subplot(2,1,2); plt.title("Corrente"); plt.plot(saidas[:,1], color= 'red', label = 'Corrente Real')
plt.subplot(2,1,2); plt.plot(previsoes[:,1], color= 'blue', label = 'Corrente Prevista')
plt.legend()
plt.xlabel('Tempo')
plt.show()