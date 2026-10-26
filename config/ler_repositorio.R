ler_repositorio <- function() {
  f <- "config/repositorio.txt"
  if (!file.exists(f)) return("")
  x <- trimws(paste(readLines(f, warn = FALSE, encoding = "UTF-8"), collapse = ""))
  if (nzchar(x) && !grepl("^https://github[.]com/[^/ ]+/[^/ ]+/?$", x)) {
    stop("A URL deve ser a ligação verdadeira de um repositório GitHub.")
  }
  sub("/$", "", x)
}
