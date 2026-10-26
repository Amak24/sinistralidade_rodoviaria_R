# Exportação atómica: só substitui o PNG final depois de fechar o dispositivo.
exportar_graficos <- function(n = 5L) {
  for (i in seq_len(n)) {
    tmp <- tempfile(pattern = "grafico_", fileext = ".png")
    ggplot2::ggsave(tmp, get(paste0("g", i), envir = .GlobalEnv),
                    width = 9, height = 5, dpi = 180, device = grDevices::png, bg = "white")
    file.copy(tmp, paste0("resultados/graficos/g", i, ".png"), overwrite = TRUE)
    unlink(tmp)
  }
}
