#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 29 15:46:00 2019

@author: icaro
"""
#%% Importando Bibliotecas
import numpy as np
import pandas as pd
import glob
import matplotlib.pyplot as plt
#%%
# Funcionalidade: - Retirar valores negativos dos parâmetros
#                 - Criar dois arquivos .csv. No primeiro ficará
#                 - as variáveis de entrada e no segundo as variáveis de saída
# Argumentos:     - Caminho da pasta que se encontra os arquivos .csv
#                 - Uma lista de String indicando quais variáveis de entrada
#                   estarão no único arquivo .csv final
#                 - Nome dos arquivos finais das variáveis de entrada e saída
# Retorno:        Null
def creatDataBase(path, variables, save_input, save_output):
    all_file = glob.glob(path + "/*.csv")
    # Criando uma lista que vai contar todos os csv
    all_csv = []
    # Pecorrendo todos os arquivos .csv
    for filename in all_file:
        # Pega o arquivo atual
        csv_file = pd.read_csv(filename)
        # Retirando as colunas com valores nulos
        csv_file = csv_file.dropna()
        # Verificando se existe algum valor nulo
        print("passando aqui,", csv_file.isnull().any())
        # Vai retirar valores negativos de todas as variáveis e setar para 0
        indexAux = csv_file[(csv_file['TENSAO'] < 0)].index
        csv_file['TENSAO'][indexAux] = 0
    
        indexAux = csv_file[(csv_file['CORRENTE'] < 0)].index
        csv_file['CORRENTE'][indexAux] = 0
        
        indexAux = csv_file[(csv_file['TEMPERATURA'] < 0)].index
        csv_file['TEMPERATURA'][indexAux] = 0
    
        indexAux = csv_file[(csv_file['PRESSAO'] < 0)].index  
        csv_file['PRESSAO'][indexAux] = 0 

        indexAux = csv_file[(csv_file['IRRADIANCIA'] < 0)].index
        csv_file['IRRADIANCIA'][indexAux] = 0 
    
        indexAux = csv_file[(csv_file['TEMP_PAINEL'] < 0)].index 
        csv_file['TEMP_PAINEL'][indexAux] = 0
    
        indexAux = csv_file[(csv_file['VELOCIDADE'] < 0)].index 
        csv_file['VELOCIDADE'][indexAux] = 0
        
        indexAux = csv_file[(csv_file['UMIDADE'] < 0)].index 
        csv_file['UMIDADE'][indexAux] = 0
        # Coloco o csv tratado em uma fila
        all_csv.append(csv_file)
    # Junto todos os csv em um único csv
    
    frame = pd.concat(all_csv, axis=0, ignore_index = True)
    # Salvo o arquivo das variáveis de entrada
    frame.to_csv(save_input,columns = variables ,index = False)
    # Salvo o arquivo das variáveis de saída
    frame.to_csv(save_output,columns = ['TENSAO', 'CORRENTE'] ,index = False)
    return 0
        
creatDataBase(r'.', ["TEMPERATURA", "TEMP_PAINEL", "IRRADIANCIA", "UMIDADE", "PRESSAO", "VELOCIDADE"], "saidas/input.csv", "saidas/output.csv")


#%%
def analyzeDataBase():
    base_input = pd.read_csv("saidas/input.csv")
    # Printando todo sumário do banco de dados
    print(base_input)
    print(base_input.describe())

analyzeDataBase()
#%%

# Funcionalidade: - Criar a base de treinamento e a de teste
# Argumentos:     - 
# Retorno:        - Null
def creatDataSet():
    base_input = pd.read_csv("saidas/input.csv")
    base_output = pd.read_csv("saidas/output.csv")
    base_test_input = base_input[:86402]
    base_test_output = base_output[:86402]
    base_training_input = base_input[86402:]
    base_training_output = base_output[86402:]
    base_test_output.to_csv("saidas/testeOutput.csv", index = False)
    base_test_input.to_csv("saidas/testeInput.csv", index = False)
    base_training_output.to_csv("saidas/trainingOutput.csv", index = False)
    base_training_input.to_csv("saidas/trainingInput.csv", index = False)
    print(base_training_output.describe())
creatDataSet()
#%%
# Funcionalidade: - Função responsável por criar os gráficos boxplots  de tensão ou corrente durante o período de um dia em intervalos de uma hora. 
# Argumentos: - Nome da variável
def creatBoxPlots(param):
    csv_file = pd.read_csv("saidas/output.csv")
    voltage = csv_file[param]
    timer = 0
    all_hour = []
    all_timer = []
    i = 0
    while i < 86400:
        all_hour.append(voltage[i:i+3600])
        all_timer.append(timer)
        i = i+3600
        timer +=1
    fig=plt.figure(1,figsize=(9,6))
    ax=fig.add_subplot(111)
    flierprops = dict(marker='', markersize=1)
    bp=ax.boxplot(all_hour,flierprops=flierprops)
    plt.xlabel('HORA')
    plt.ylabel(para,)
    plt.show()
creatBoxPlots("TENSAO")
#%%
# Funcionalidade: - Função responsável por criar os gráficos de linha  de tensão e corrente durante o período de um dia.
def creatLineGraph():
    csv_file = pd.read_csv("saidas/output.csv")
    voltage = csv_file["TENSAO"]
    current = csv_file["CORRENTE"]
    plt.subplot(2,1,1); plt.ylabel("TENSÃO"); plt.plot(voltage,     color= 'teal')
    plt.subplot(2,1,2); plt.ylabel("CORRENTE"); plt.plot(current,     color= 'teal')
    plt.xlabel('SEGUNDOS')
    plt.show() 
creatLineGraph()

#%%
# Funcionalidade: Função responsável por analisar todas as variáveis de todos os dias e verificar se apresenta alguma
# anomalia
def verifyData(path):
    all_file = glob.glob(path + "/*.csv")
    # Pecorrendo todos os arquivos .csv
    aux = 1
    for filename in all_file:
        csv_file = pd.read_csv(filename)
        fig=plt.figure(aux,figsize=(9,6))
        ax=fig.add_subplot(111)
        ax.plot(csv_file["PRESSAO"], label = filename)   
        plt.legend()     
        aux +=1
verifyData(r'.')
#%%
# Função criada para descobrir linhas que não possuem valores 
def exceptions():
    try:
        indexAux = csv_file[(csv_file['TEMPERATURA'] < 0)].index
        csv_file['TEMPERATURA'][indexAux] = 0
    except:
        print('############################### FUDEU #$####')
        for index, row in csv_file.iterrows():
            try:
                float(row['TEMPERATURA'])
            except ValueError:
                print("Not a float", index)
    
