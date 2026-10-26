# Abra o projeto no RStudio. Substitua o texto pela URL copiada do GitHub.
definir_repositorio <- function(url) {
  url <- sub("/$", "", trimws(url))
  if (!grepl("^https://github[.]com/[^/ ]+/[^/ ]+$", url)) stop("Copie a URL verdadeira do repositório GitHub.")
  dir.create("config", showWarnings = FALSE)
  writeLines(url, "config/repositorio.txt", useBytes = TRUE)
  message("URL registada. Use gerar_documentos.R para atualizar os documentos HTML.")
}
