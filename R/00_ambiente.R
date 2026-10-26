# Ponto único de entrada. Abra primeiro projeto_sinistralidade.Rproj.
# Os caminhos são relativos à pasta do projeto, como exige o guião.
if (!file.exists("projeto_sinistralidade.Rproj")) {
  stop("Abra projeto_sinistralidade.Rproj no RStudio antes de executar.")
}
dados_exigidos <- c("data/raw/sns_lesoes_2023_2024.csv", "data/raw/ansr_2024.xlsx")
if (!all(file.exists(dados_exigidos))) {
  stop("Faltam os dados originais. Extraia o ZIP completo e mantenha data/raw junto do .Rproj.")
}
pacotes <- c("dplyr", "tidyr", "readr", "readxl", "ggplot2")
for (p in pacotes) {
  if (!requireNamespace(p, quietly = TRUE)) stop(paste("Falta o pacote", p, ": execute R/00_instalar.R"))
  library(p, character.only = TRUE)
}
options(scipen = 999)
# Durante Knit, os gráficos são guardados pelo próprio relatório.
gravar_graficos <- !isTRUE(getOption("knitr.in.progress"))
set.seed(2026)
for (pasta in c("data/processed", "resultados", "resultados/graficos")) {
  dir.create(pasta, recursive = TRUE, showWarnings = FALSE)
}
