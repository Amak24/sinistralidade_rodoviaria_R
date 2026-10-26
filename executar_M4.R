# M4: análise completa e avaliação do modelo, depois de M3.
source("executar_M3.R", encoding = "UTF-8")
source("R/04_modelacao.R", encoding = "UTF-8")
writeLines(capture.output(sessionInfo()), "resultados/sessionInfo.txt")
message("M4 concluído: modelo, avaliação temporal e sexto gráfico disponíveis.")
