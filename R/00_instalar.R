# Execute este ficheiro uma única vez, no RStudio.
# Instala apenas os pacotes que ainda não existem no seu computador.
pacotes <- c("dplyr", "tidyr", "readr", "readxl", "ggplot2", "knitr", "rmarkdown")
faltam <- pacotes[!vapply(pacotes, requireNamespace, logical(1), quietly = TRUE)]
if (length(faltam) > 0) install.packages(faltam, repos = "https://cloud.r-project.org")
nao_instalados <- pacotes[!vapply(pacotes, requireNamespace, logical(1), quietly = TRUE)]
if (length(nao_instalados) > 0) {
  stop("A instalação não ficou concluída. Faltam: ",
       paste(nao_instalados, collapse = ", "),
       ". Confirme a ligação à Internet e repita este ficheiro.")
}
message("Pacotes disponíveis. Abra o projeto .Rproj e execute executar.R.")
