# Confere os resultados calculados com os valores da edição do relatório enviada.
# Execute depois de executar.R. A comparação é numérica, com tolerância para
# diferenças muito pequenas de arredondamento entre versões de R e pacotes.

ficheiros_conferencia <- list.files("verificacao/referencia", pattern = "[.]csv$",
                                   full.names = TRUE)
if (!length(ficheiros_conferencia)) stop("Faltam os ficheiros de referência.")
for (ref in ficheiros_conferencia) {
  nome <- basename(ref)
  atual <- file.path("resultados", nome)
  if (!file.exists(atual)) stop("Falta ", atual, ". Execute primeiro executar.R.")
  ler <- function(f) read.csv(f, check.names = FALSE, stringsAsFactors = FALSE,
                              fileEncoding = "UTF-8")
  esperado <- ler(ref)
  obtido <- ler(atual)
  confere <- all.equal(esperado, obtido, tolerance = 1e-7,
                       check.attributes = FALSE)
  if (!isTRUE(confere)) {
    stop("Resultado diferente da edição de referência em ", nome, ": ",
         paste(confere, collapse = "; "))
  }
  message("CONFERE: ", nome)
}
message("Os ", length(ficheiros_conferencia),
        " ficheiros conferem com os resultados usados no relatório.")
