# COMO USAR NO RSTUDIO
# 1. Abra projeto_sinistralidade.Rproj.
# 2. Na Console, execute: source("INICIAR_AQUI.R", encoding = "UTF-8")
# Na primeira utilização, a instalação dos pacotes precisa de Internet.
# Os dados originais já estão na pasta data/raw.

source("R/00_instalar.R", encoding = "UTF-8")
source("executar.R", encoding = "UTF-8")
source("verificar_resultados.R", encoding = "UTF-8")

print(avaliacao)
print(g6)
message("Concluído. Consulte resultados/ e resultados/graficos/.")
