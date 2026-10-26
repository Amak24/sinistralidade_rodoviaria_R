# OPCIONAL: só execute para obter uma NOVA versão dos dados.
# Os originais do trabalho não são substituídos; ficam em data/raw/.
dir.create("data/nova_versao", recursive = TRUE, showWarnings = FALSE)
options(timeout = 180)
base <- "https://transparencia.sns.gov.pt/api/explore/v2.1/catalog/datasets/morbilidade_mortalidade_hospit"
filtro <- "periodo >= '2023-01' and periodo <= '2024-12' and cod_capitulo = 19"
url <- paste0(base, "/exports/csv?where=", URLencode(filtro, reserved = TRUE),
              "&use_labels=false&delimiter=%3B")
download.file(url, "data/nova_versao/sns_lesoes_2023_2024.csv", mode = "wb")
download.file("https://observatorioansr.pt/wp-content/uploads/2025/08/Anexo-ao-Relatorio-Anual-de-Sinistralidade-24h-e-fiscalizacao-rodoviaria-2024.xlsx",
              "data/nova_versao/ansr_2024.xlsx", mode = "wb")
message("Compare a nova versão e refaça a auditoria antes de substituir os originais.")
