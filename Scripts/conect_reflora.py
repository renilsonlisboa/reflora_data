import requests
import pandas as pd
import sys
import json
from time import sleep

request_familias = requests.get("https://servicos.jbrj.gov.br/v2/flora/families")

lista_familias = request_familias.json()

resultados = []

for i in lista_familias:
    url = f"https://servicos.jbrj.gov.br/v2/flora/species/{i}"
    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        
        if isinstance(data, list) and len(data) > 0:
            
            for j in range(0, len(data)):
              primeiro_registro = data[j]
              registro = {
                  'Familia': primeiro_registro.get('family'),
                  'Nome_Cientifico': primeiro_registro.get('scientificname'),
                  'Status': primeiro_registro.get('taxonomicstatus')
              }
            
              resultados.append(registro)

        print(i)
        sleep(0.5)
        
    except requests.exceptions.RequestException as e:
        print(f"Erro ao processar ID {e}")
        continue

df_resultados = pd.DataFrame(resultados)
df_resultados.to_csv('resultados_flora.csv', index=False)
