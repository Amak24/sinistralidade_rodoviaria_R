# Sinistralidade rodoviária e internamentos por lesões

**Autor:** Amak Adriano Evaristo Machava  
**Instituição:** Universidade Fernando Pessoa  
**Unidade curricular:** Seminário de Sistemas e Aplicações — 2026/2027

Projeto em R correspondente aos momentos M1 a M4. Compara vítimas de motociclos e veículos ligeiros, explora os dados hospitalares por lesões e avalia uma regressão para médias hospitalares por grupos.

## Começar no Mac / RStudio

1. Instale **R** e **RStudio Desktop**, se ainda não os tiver. São programas diferentes: R executa os cálculos; RStudio é a aplicação onde trabalha.
2. Extraia o ZIP. Guarde a pasta `projeto_sinistralidade` numa localização estável, por exemplo `Documentos`.
3. Abra o ficheiro **`projeto_sinistralidade.Rproj`** no RStudio. Não abra apenas um script isolado.
4. No separador **Console**, execute:

```r
source("INICIAR_AQUI.R", encoding = "UTF-8")
```

Na primeira execução, são instalados os pacotes que faltarem, o que exige Internet. A análise usa os dados já incluídos no ZIP. Aguarde até a Console voltar a apresentar `>`.

O projeto calcula as tabelas, os seis gráficos e os modelos, compara nove ficheiros de resultados com a edição do relatório e mostra a tabela de avaliação e o gráfico de previsões.

Depois da primeira instalação, pode executar apenas:

```r
source("executar.R", encoding = "UTF-8")
```

## Organização por momento

| Momento | O que representa | Ficheiro principal |
|---|---|---|
| M1 | Tema, motivação e objetivos; etapa de enquadramento | `M1_uma_pagina.Rmd` |
| M2 | Importação e identificação dos dados | `executar_M2.R` |
| M3 | Auditoria, preparação, análise exploratória e gráficos | `executar_M3.R` |
| M4 | Regressão, comparação com a referência e avaliação | `executar_M4.R` |

Os scripts executam automaticamente as etapas anteriores necessárias. Por exemplo, executar M4 também executa M2 e M3. M1 é o enquadramento do estudo, sem um modelo próprio para calcular.

Para executar separadamente, escolha uma destas instruções:

```r
source("executar_M2.R", encoding = "UTF-8")
source("executar_M3.R", encoding = "UTF-8")
source("executar_M4.R", encoding = "UTF-8")
```

## Pastas e saídas

| Pasta ou ficheiro | Conteúdo |
|---|---|
| `data/raw/` | Dados originais ANSR e SNS, metadados, URLs e manifesto SHA-256 |
| `data/processed/` | Dados preparados e cruzamento mensal, recalculados pelo programa |
| `R/` | Código de importação, limpeza, análise e modelação |
| `resultados/` | Auditorias, tabelas CSV, previsões, coeficientes, modelo RDS e informação da sessão |
| `resultados/graficos/` | Seis gráficos PNG, `g1.png` a `g6.png` |
| `verificacao/referencia/` | Valores da edição do estudo, para conferir a reprodução dos cálculos |
| `apoio/` | Guia de RStudio/GitHub e explicação dos scripts |
| `config/` | Ligação do repositório, a preencher depois de o criar |
| `entregas/` | Relatórios HTML gerados opcionalmente a partir dos R Markdown |

Exemplos para consultar os resultados na Console:

```r
View(readr::read_csv("resultados/avaliacao_modelo.csv", show_col_types = FALSE))
View(readr::read_csv("resultados/auditoria.csv", show_col_types = FALSE))
print(g1)  # Comparação entre veículos, no separador Plots
print(g6)  # Médias previstas e observadas
```

## Resultados de referência

- SNS original: **10 546 linhas e 11 colunas**.
- Chaves repetidas: **488**, com **585 linhas excedentes**; nenhuma linha inteiramente idêntica.
- Painel analisado: **23 instituições**, **24 meses**, **4980 linhas**, em quatro regiões.
- Modelo: **2407 grupos de treino de 2023** e **2424 grupos de teste de 2024**.
- Regressão principal: **MAE 2,950 dias** e **RMSE 4,785 dias**.
- Referência simples: **MAE 3,729 dias** e **RMSE 5,406 dias**.

Os erros são ponderados pelo número de internamentos. Referem-se a médias de grupos, não ao tempo de recuperação de cada doente. Os dados hospitalares incluem lesões de várias causas e não identificam o veículo associado. A associação entre fontes é mensal e não demonstra causalidade.

## Colocar no GitHub

O projeto está pronto para iniciar um repositório novo. O ZIP não inclui histórico `.git` nem uma ligação inventada. Siga **`apoio/GUIA_RSTUDIO_GIT_MAC.md`**. Publique os ficheiros extraídos, incluindo o código e os dados, para que o professor possa executar o projeto; o ZIP isolado é menos fácil de consultar.

Depois de criar o repositório, copie a URL verdadeira e registe-a assim, substituindo o exemplo:

```r
source("definir_repositorio.R", encoding = "UTF-8")
definir_repositorio("https://github.com/SEU_UTILIZADOR/SEU_REPOSITORIO")
```

Este comando apenas guarda a ligação em `config/repositorio.txt`; não cria nem publica um repositório.

## Relatórios R Markdown — opcional

Os ficheiros `.Rmd` permitem gerar novamente o texto, as tabelas e os gráficos a partir dos cálculos. Não são necessários para executar a análise. Para gerar os cinco documentos HTML, execute:

```r
source("gerar_documentos.R", encoding = "UTF-8")
```

O RStudio inclui Pandoc, necessário para esta conversão. Os HTML ficam em `entregas/` e podem ser abertos no navegador e impressos para PDF. A sua formatação é a do R Markdown; as alterações visuais feitas manualmente no Pages, Word e PowerPoint não são importadas automaticamente para estes ficheiros.

## Fontes dos dados preservados

- ANSR: anexo ao Relatório Anual de Sinistralidade a 24 horas de 2024, com valores de 2023–2024. Dados de 2024 provisórios na edição utilizada.
- ACSS / Portal Transparência SNS: Morbilidade e Mortalidade Hospitalar, capítulo 19, janeiro de 2023 a dezembro de 2024.
- Aquisição indicada no manifesto original: **6 de outubro de 2026**. URLs completas e hashes estão em `data/raw/`.

O script opcional `R/05_atualizar_fontes.R` guarda uma nova aquisição numa pasta separada. Não o execute para reproduzir a edição do relatório, pois as fontes online podem ser revistas.

## Se aparecer um erro

| Mensagem ou situação | O que fazer |
|---|---|
| «Abra projeto_sinistralidade.Rproj» | Abra o `.Rproj` e repita a execução na Console |
| «Falta o pacote…» | Execute `source("R/00_instalar.R", encoding = "UTF-8")` |
| Instalação falha por falta de ligação | Restabeleça a Internet e repita a instalação |
| «cannot open file» | Confirme que extraiu todo o ZIP e que as pastas `R/` e `data/raw/` estão junto do `.Rproj` |
| Não aparece um gráfico | Escreva `print(g1)` ou `print(g6)` na Console; os PNG também ficam em `resultados/graficos/` |
| «pandoc is required» | Execute a geração de documentos dentro do RStudio; a análise numérica pode correr sem Pandoc |
| Resultados diferentes da referência | Preserve a mensagem e consulte `resultados/sessionInfo.txt`; confirme que não substituiu os dados originais |

Documentação oficial: [R para macOS](https://cran.r-project.org/bin/macosx/), [RStudio Desktop](https://posit.co/download/rstudio-desktop/), [projetos no RStudio](https://docs.posit.co/ide/user/ide/guide/code/projects.html), [GitHub: publicar código local](https://docs.github.com/en/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github).
