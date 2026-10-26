# M2: dados disponíveis, importação e identificação das variáveis.
source("R/00_ambiente.R", encoding = "UTF-8")
source("R/01_importacao.R", encoding = "UTF-8")
# O dicionário inclui as variáveis originais e os indicadores derivados.
readr::write_csv(tibble(variavel = names(sns_raw),
  classe_R = vapply(sns_raw, function(x) class(x)[1], character(1))),
  "resultados/M2_estrutura_dados.csv")
readr::write_csv(tibble(fonte = c("SNS capítulo 19", "ANSR mensal", "ANSR veículo", "ANSR via"),
  linhas = c(nrow(sns_raw), nrow(ansr_mensal), nrow(ansr_veiculos), nrow(ansr_vias)),
  colunas = c(ncol(sns_raw), ncol(ansr_mensal), ncol(ansr_veiculos), ncol(ansr_vias))),
  "resultados/M2_dimensoes.csv")
message("M2 concluído: dados importados; veja resultados/M2_estrutura_dados.csv.")
