# Gera versões atualizadas com a URL de config/repositorio.txt.
# Instalar primeiro os pacotes com R/00_instalar.R.
dir.create("entregas", showWarnings = FALSE)
for (f in c("M1_uma_pagina.Rmd", "M2.Rmd", "M3.Rmd", "M4.Rmd", "relatorio.Rmd")) {
  rmarkdown::render(f, output_format = "html_document", output_dir = "entregas", encoding = "UTF-8")
}
message("Abra os HTML em entregas/ e use Imprimir > Guardar como PDF para exportar sem LaTeX.")
