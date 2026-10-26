# Os ficheiros originais já estão incluídos: a análise não exige Internet.
sns_raw <- readr::read_delim("data/raw/sns_lesoes_2023_2024.csv",
  delim = ";", show_col_types = FALSE, trim_ws = TRUE)
exigidas <- c("periodo", "regiao", "instituicao", "cod_capitulo", "desc_capitulo",
              "faixa_etaria", "sexo", "internamentos", "dias_internamentos", "ambulatorios", "obitos")
stopifnot(all(exigidas %in% names(sns_raw)), nrow(sns_raw) >= 1000)

# Os anexos ANSR têm títulos, células unidas e várias tabelas por folha.
# Lemos como texto e extraímos só o primeiro quadro de contagens.
xlsx <- "data/raw/ansr_2024.xlsx"
ler_folha <- function(folha) {
  readxl::read_excel(xlsx, sheet = folha, range = readxl::cell_limits(c(1, 1), c(NA, NA)), col_names = FALSE,
                    col_types = "text", .name_repair = "minimal")
}
numero <- function(x) as.numeric(x)
meses <- c("Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
           "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro")
mensal_x <- ler_folha("4 e 5")[6:17, ]
stopifnot(identical(as.character(mensal_x[[1]]), meses))
ansr_mensal <- bind_rows(lapply(2023:2024, function(a) {
  c0 <- if (a == 2023) 3 else 4
  tibble(ano = a, mes = 1:12,
         periodo = as.Date(sprintf("%d-%02d-01", a, 1:12)),
         acidentes = numero(mensal_x[[c0]]),
         mortos = numero(mensal_x[[c0 + 3]]),
         feridos_graves = numero(mensal_x[[c0 + 6]]),
         feridos_leves = numero(mensal_x[[c0 + 9]]))
}))

veiculos_x <- ler_folha("19 e 20")[6:13, ]
ansr_veiculos <- bind_rows(lapply(2023:2024, function(a) {
  c0 <- if (a == 2023) 3 else 4
  tibble(ano = a, veiculo = as.character(veiculos_x[[1]]),
         mortos = numero(veiculos_x[[c0]]),
         feridos_graves = numero(veiculos_x[[c0 + 3]]),
         feridos_leves = numero(veiculos_x[[c0 + 6]]),
         total_vitimas = numero(veiculos_x[[c0 + 9]]))
}))

vias_x <- ler_folha("13 e 14")[6:13, ]
ansr_vias <- bind_rows(lapply(2023:2024, function(a) {
  c0 <- if (a == 2023) 3 else 4
  tibble(ano = a, via = as.character(vias_x[[1]]),
         acidentes = numero(vias_x[[c0]]), mortos = numero(vias_x[[c0 + 3]]),
         feridos_graves = numero(vias_x[[c0 + 6]]),
         feridos_leves = numero(vias_x[[c0 + 9]]))
}))
# Não juntamos veículo e via: são quadros marginais, sem informação conjunta.
# As taxas de variação do Excel são recalculadas a partir das contagens.
