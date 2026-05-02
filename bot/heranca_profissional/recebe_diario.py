#!opt/alt/python311/bin/python3

print ("Content-type: text/html\n\n")

import sys
para1 = sys.argv[1] # email
para2 = sys.argv[2] # cpf

#para1 = 'anapaolabrasil@gmail.com'
#para2 = 36745995387

'''
#criação do html
Func = open("recebe_diario.html","w")

# Adding input data to the HTML file

Func.write("<html>\n<head>\n<title></title></head><body>\
<p style=\"position:relative; left:500px;font-size:26px;color: red\">LEGENDA</p>\
<p>"+para1+"</p><p>"+para2+"</p></body></html>")

#Func.close()
'''

import pymysql
import pandas as pd
#pd.set_option('display.max_colwidth', None)
import matplotlib.pyplot as plt
from datetime import datetime
import numpy as np
from sklearn.metrics import r2_score
from statsmodels.tsa.seasonal import seasonal_decompose
import base64
import json
import html
from json2html import *
import sys
import nltk

import googletrans
from googletrans import Translator
translator = Translator()

from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer as sia

import itertools


################
#BANCO DE DADOS
################


import os
import sys

# Adiciona o diretório pai ao sys.path para importar db_config
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
try:
    import db_config
except ImportError:
    print("Erro: db_config.py não encontrado")
    sys.exit(1)

# Abrimos uma conexão com o banco de dados:
try:
    conexao = pymysql.connect(host=db_config.DB_HOST,
                                 user=db_config.DB_USER,
                                 password=db_config.DB_PASS,
                                 database=db_config.DB_NAME,
                                 cursorclass=pymysql.cursors.DictCursor)
except Exception as e:
    print(f"Erro ao conectar ao banco de dados: {e}")
    sys.exit(1)


with conexao.cursor() as cursor:
    # Cria um cursor:
    cursor = conexao.cursor()
    sql = "SELECT * FROM `atendimentos_diario` WHERE `CPF` = %s order by ID_ATENDIMENTOS ASC"
    cursor.execute(sql,(para2))
    # Recupera o resultado:
    resultado = cursor.fetchall()
    #print(resultado)

    '''
    #cria um arquivo json
    #with open("lalal2.json", 'w', encoding='utf-8') as f:
     #   json.dump(resultado, f, ensure_ascii=False, indent=4)

    #converte json para html
    #dados_convertidos = json2html.convert(json = resultado)

    #criação de um arquivo html para receber o conteúdo da variável dados_convertidos
    #cria_html = open("blau.html","w")

    # Adding input data from dados_convertidos to the HTML file
    #cria_html.write("<html>\n<head>\n<title></title></head><body><br>\
    <p style=\"position:relative; left:500px;font-size:26px;color: red\">LEGENDA</p><p>Planeta Terra</p></body></html>")

    #cria_html.close()

    # Opening JSON file
#f = open('lalal2.json')

# returns JSON object as a dictionary
#dados = json.load(f)
#df = pd.json_normalize(dados,record_path=['result'])
'''



df = pd.DataFrame(resultado)
#df = pd.json_normalize(dados)
#print (df)
#print (df.columns) #Index(['ID_ATENDIMENTOS', 'DATA_HORA', 'CPF', 'EMAIL', 'TEXTO'], dtype='object')


 #TRADUÇÃO
def safe_translate(text):
    try:
        translated = translator.translate(text, src='pt', dest='en')
        return translated.text
    except Exception as e:
        print(f"Erro na tradução: {e}")
        return text # Fallback para o texto original se falhar

df['TEXTO'] = df['TEXTO'].apply(safe_translate)

#TOKENIZAÇÃO
df['tokenized'] = df.apply(lambda row: nltk.word_tokenize(row['TEXTO']), axis=1)
#print(df['tokenized'])

#POS-TAG
df['grupo'] = df.apply(lambda row: nltk.pos_tag(row['tokenized']), axis=1)
#print(df['grupo'])

#FILTRAGEM
df['filtragem'] = df['grupo'].apply(lambda x: [palavra for palavra, pos in x if pos in ['NN', 'VB', 'JJ']])

#INICIA VADER
vader = sia()

#CALCULO DA POLARIDADES
df['Sentiment Values'] = df['TEXTO'].apply(lambda row: vader.polarity_scores(row))
#df['Sentiment Values'] = df['filtragem'].apply(lambda row: vader.polarity_scores(row))
#print(df['Sentiment Values'])

df['negative'] = df['Sentiment Values'].apply(lambda x: x['neg'])
df['neutral'] = df['Sentiment Values'].apply(lambda x: x['neu'])
df['positive'] = df['Sentiment Values'].apply(lambda x: x['pos'])
df['compound'] = df['Sentiment Values'].apply(lambda x: x['compound'])

#CONVERTER PARA NUMERO
df['compound'] = pd.to_numeric(df['compound'], errors='coerce')

#print(df[['CPF','TEXTO','compound']])

df2 = df[['CPF','TEXTO','compound' ]]
print(df2)



################
# REGRESSÃO POLINOMIAL
################


#Formação dos pares x,y para regressão polinomial e cálculo de R2

#VALORES DE df['compound']
y = []
for i in df2['compound']:
    y.append(i)
#print(y)

#valores para index no eixo x
x=[]
for j in range(len(y)):
    x.append(j)
#print(x)


#CALCULO REGRESSÃO POLINOMIAL
degrees = 3
mymodel = np.polyfit(x, y, degrees)#degree=3
#print(mymodel)
#[-3.03208795e-02  1.34333191e+00 -1.55383039e+01  1.13768037e+02]
#y = -3.03208795e-02x**3 + 1.34333191e+00x**2 + -1.55383039e+01x + 1.13768037e+02

#PREDICAO
prediction = np.poly1d(mymodel)

#CALCULO DE R2
r2 = r2_score(y, prediction(x))
#print(r2)

#GRAFICO APENAS DA REGRESSÃO POLINOMIAL
myline = np.linspace(1, len(x), 100) #start at position 1, and end at position 22
plt.scatter(x, y)
plt.plot(myline, prediction(myline))
#plt.show()
#plt.savefig(f"{param2}.png")


################
# FUNÇÕES AUXILIARES DO GRÁFICO
################

################
# media movel
################


def get_sma(prices, rate):
    return prices.rolling(rate).mean()
    #return np.log(np.power(prices.rolling(rate).mean(),2))


################
# bandas de bollinger
################


def get_bollinger_bands(prices, rate = 4):
    sma = get_sma(prices, rate) # <-- Get SMA for 20 days
    std = prices.rolling(rate).std() # <-- Get rolling standard deviation for 20 days
    bollinger_up = sma + std * 2 # Calculate top band
    bollinger_down = sma - std * 2 # Calculate bottom band

    #sma = np.log(np.power(get_sma(prices, rate),2)) # <-- Get SMA for 20 days
    #std = np.log(np.power(prices.rolling(rate).std(),2)) # <-- Get rolling standard deviation for 20 days
    #bollinger_up = sma + std * 2 # Calculate top band
    #bollinger_down = sma - std * 2 # Calculate bottom band

    return bollinger_up, bollinger_down,sma

bollinger_up, bollinger_down, sma = get_bollinger_bands(df['compound'])

################
# GRÁFICO PRINCIPAL
################

fig, ax = plt.subplots()
#ax = plt.axes()
ax.set_facecolor('WhiteSmoke')
#ax.set_facecolor('white')
ax.grid(True)

#s = df[['DATA_HORA','K','VS']].to_string(index=False)
#print(s)
#ax.text(8,13,s = df[['DATA_HORA','K','VS']].to_string(index=False))


#rótulos
plt.title('MoVALex')
plt.xlabel('Registro')
plt.ylabel('Valencia')

#valores brutos
plt.plot(y, label='Valências Brutas',c='DimGray')
#plt.scatter(x, y) #mesma coisa acima, mas calculado de outra forma


#valores para regressão polinomial
myline = np.linspace(1, len(x), 100) #start at position 1, and end at position 22
plt.scatter(x, y)
plt.plot(myline,
         prediction(myline),
         #label='Reg. Polinomial (R2 = %.2f)' % (r2),
         label='Linha de Tendência (R2 = %.2f)' % (r2),
         linewidth=0.8,c='b')


#valores para média móvel e bandas de bollinger
#plt.plot(sma, label='Média Móvel(N=4)',linestyle='dashed',linewidth=1.0, c='g')
plt.plot(sma, label='Linha Média',linestyle='dashed',linewidth=1.0, c='g')
plt.plot(bollinger_up, label='Limite Superior (+2DP)', linestyle='dotted',linewidth=0.8,c='b')
plt.plot(bollinger_down, label='Limite Inferior (-2DP)',linestyle='dotted', linewidth=0.8,c='r')


#legendas
plt.legend()

#salvamento do gráfico
plt.savefig(f"../imagem/{para2}.png")


################
# HTML PARA EXIBIÇÃO
################


try:
    with open(f"../imagem/{para2}.png", 'rb') as img_file:
        data_uri = base64.b64encode(img_file.read()).decode('utf-8')
except Exception as e:
    print(f"Erro ao ler imagem: {e}")
    data_uri = ""

img_tag = '<img src="data:image/png;charset=utf-8;base64,{0}" >'.format(data_uri)

# Escapamento para segurança
safe_para2 = html.escape(str(para2))

#criação do html
try:
    with open(f"../imagem/{para2}.html","w") as Func_html:
        Func_html.write("<html>\n<head>\n<title></title></head><body>\
<div style=\"position: absolute;width:100px;height:100px; left: 0px; top: 150px;\"><p style=\"position:relative;left:10px;\">"+img_tag+"</p></div></body></html>")
except Exception as e:
    print(f"Erro ao criar HTML: {e}")

#criação do php
try:
    with open(f"../imagem/{para2}.php","w") as Func_php:
        # Note: Using heredoc or separate lines would be cleaner, but keeping it similar to original
        php_content = f"""<html lang="en">
<?php session_start(); $email = $_SESSION['email'];$senha = $_SESSION['senha'];$cpf_usuario3 = $_SESSION['cpf_usuario3'];?>
<head>
<meta charset="utf-8"><meta http-equiv="X-UA-Compatible" content="IE=edge"><meta name="viewport" content="width=device-width, initial-scale=1"><meta name="description" content=""><meta name="author" content=""><title>MoVALex</title><link href="../css/bootstrap.min.css" rel="stylesheet">
<style>body {{padding-top: 70px;}}</style></head><body>
<?php include ("../protecao3.php");include("menu_prof.html"); ?>
<p>{img_tag}</p></body></html>"""
        Func_php.write(php_content)
except Exception as e:
    print(f"Erro ao criar PHP: {e}")


#<?php include(\"../imagem/inclui_tabela2.php\"); ?>
