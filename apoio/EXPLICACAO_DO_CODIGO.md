# O que faz o código — explicação

## O caminho dos dados

1. **M2 — importar:** ler o CSV do SNS e os quadros do Excel da ANSR.
2. **M3 — conferir:** procurar omissões, chaves repetidas e contagens impossíveis.
3. **M3 — preparar:** selecionar o painel de instituições e calcular indicadores.
4. **M3 — explorar:** construir tabelas e gráficos para perceber padrões.
5. **M4 — modelar:** usar 2023 para ajustar uma regressão e prever as médias de 2024.
6. **M4 — avaliar:** comparar os erros da regressão com uma previsão simples de referência.

## Ficheiro a ficheiro

| Ficheiro | Função |
|---|---|
| `INICIAR_AQUI.R` | Instala o que faltar, executa o estudo, confere os resultados e mostra um gráfico |
| `R/00_instalar.R` | Instala os pacotes usados pelo projeto |
| `R/00_ambiente.R` | Confirma a pasta de trabalho, carrega os pacotes e cria as pastas de saída |
| `R/01_importacao.R` | Lê os dados originais. No Excel, escolhe folhas, linhas e colunas das contagens |
| `R/02_limpeza.R` | Audita os dados, identifica chaves ambíguas e cria o painel fixo |
| `R/03_analise.R` | Calcula os resumos, cruza os meses e cria cinco gráficos exploratórios |
| `R/04_modelacao.R` | Ajusta modelos, calcula MAE/RMSE e cria o gráfico de previsões |
| `R/05_atualizar_fontes.R` | Aquisição opcional de outra versão; não é necessário para reproduzir o estudo |
| `R/06_exportar_graficos.R` | Exporta os gráficos para os relatórios R Markdown |
| `verificar_resultados.R` | Compara os cálculos novos com os valores de referência |

## Como explicar a extração

«Usei dados públicos já agregados. No SNS, preservei um CSV filtrado para 2023–2024 e capítulo 19. Na ANSR, preservei o anexo Excel e selecionei os quadros mensais, por veículo e por via. O R lê esses ficheiros, valida as contagens e prepara os indicadores.»

A leitura é uma extração estruturada de tabelas; não utiliza um modelo de aprendizagem automática para extrair os dados. A regressão só é usada mais tarde, em M4.

## Chave hospitalar

A chave é a combinação de **mês + região + instituição + capítulo + faixa etária + sexo**. Serve para identificar um grupo que deveria ter uma única linha. Há 488 chaves repetidas e 585 linhas excedentes, mas nenhuma linha inteira é idêntica. Como não está esclarecido se essas linhas podem ser somadas, o estudo exclui as instituições com ambiguidades e mantém um painel fixo de 23 instituições.

## Indicadores

**Proporção grave:** `(mortos + feridos graves) / total de vítimas`. O denominador são as vítimas, não todos os condutores. Não é o índice oficial de gravidade da ANSR.

**Duração média:** `dias de internamento / número de internamentos`. Ao reunir grupos, divide-se a soma dos dias pela soma dos internamentos. Não se faz a média simples das médias. Se não houve internamentos numa célula, a duração média fica indefinida (`NA`).

**Valores extremos:** o código assinala médias muito elevadas por uma regra baseada na distribuição. Mantém-as na análise principal. Na análise de sensibilidade, retira esses valores só do treino e conserva o mesmo teste completo.

## Modelo principal de M4

```r
modelo <- lm(
  duracao_media ~ faixa_etaria + sexo + regiao + sin_mes + cos_mes,
  data = treino,
  weights = internamentos
)
```

- `lm`: ajusta uma regressão linear.
- `duracao_media`: o resultado numérico que se pretende prever.
- `~`: lê-se «em função de».
- `faixa_etaria`, `sexo`, `regiao`: características dos grupos, usadas como preditores.
- `sin_mes` e `cos_mes`: representam o ciclo anual dos meses, isto é, a sazonalidade.
- `data = treino`: utiliza apenas os grupos elegíveis de 2023 para ajustar o modelo.
- `weights = internamentos`: dá mais peso a grupos com mais episódios.

O código usa `predict(modelo, newdata = teste)` para obter as previsões dos grupos de 2024. São as mesmas instituições nos dois anos. O teste não mede o desempenho em hospitais novos.

## Referência, MAE e RMSE

A referência prevê sempre a média ponderada de 2023, cerca de **10,63 dias**. A regressão pode prever valores diferentes consoante as características de cada grupo.

**MAE** mede o tamanho médio dos erros sem considerar o sinal. **RMSE** dá mais importância aos erros grandes. Neste estudo, ambos são ponderados pelo número de internamentos e medidos em dias. Quanto menores, melhor.

Exemplo inventado: a média real de um grupo é 10 dias e a previsão é 12. A diferença absoluta é 2 dias. Este exemplo apenas ilustra o erro; o programa calcula as métricas em todos os 2424 grupos elegíveis do teste.

O MAE principal é 2,950 dias, contra 3,729 na referência. A redução é cerca de 20,88%. Isto é uma **redução do erro**, não uma percentagem de previsões certas.

## Spearman e a segunda regressão

O Spearman compara a ordenação de duas séries. Aqui compara 24 meses de feridos graves ANSR com dias hospitalares no painel SNS. O valor de aproximadamente 0,095 indica uma associação global muito fraca nessa comparação.

O ficheiro M4 também ajusta uma regressão **descritiva mensal**, com tendência e sazonalidade. Esta é diferente do modelo de previsão das médias hospitalares. Nenhuma das análises mensais liga uma pessoa acidentada a um episódio hospitalar, nem demonstra causalidade.

## Conclusão

«O modelo reduziu o erro face a uma previsão simples, no teste de 2024 e no painel analisado. Os dados permitem comparar grupos e explorar padrões. Não permitem atribuir a duração de um internamento a um veículo nem prever a recuperação individual.»
