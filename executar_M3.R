# M3: importar, auditar, preparar e explorar os dados. Não ajusta o modelo final.
source("executar_M2.R", encoding = "UTF-8")
source("R/02_limpeza.R", encoding = "UTF-8")
source("R/03_analise.R", encoding = "UTF-8")
writeLines(capture.output(sessionInfo()), "resultados/sessionInfo_M3.txt")
message("M3 concluído: dados preparados, tabelas e cinco gráficos de exploração.")
