# Auditoria de valores ausentes: ausência nunca é automaticamente zero.
omissos <- tibble(variavel = names(sns_raw),
                 n_omissos = vapply(sns_raw, function(x) sum(is.na(x)), numeric(1)))
write_csv(omissos, "resultados/auditoria_omissos.csv")
contagens <- c("internamentos", "dias_internamentos", "ambulatorios", "obitos")
stopifnot(all(vapply(sns_raw[contagens], is.numeric, logical(1))))
# Se uma atualização tiver omissos ou contagens impossíveis, paramos para revisão.
stopifnot(!anyNA(sns_raw), all(as.matrix(sns_raw[contagens]) >= 0),
          all(as.matrix(sns_raw[contagens]) %% 1 == 0),
          all(sns_raw$obitos <= sns_raw$internamentos),
          !any(sns_raw$internamentos == 0 & sns_raw$dias_internamentos > 0))

sns <- sns_raw %>% mutate(across(where(is.character), trimws),
  periodo = as.Date(paste0(periodo, "-01")),
  ano = as.integer(format(periodo, "%Y")), mes = as.integer(format(periodo, "%m")),
  regiao = sub("Região de Saúde (do |de )?", "", regiao))
stopifnot(!anyNA(sns$periodo), all(sns$ano %in% 2023:2024), all(sns$cod_capitulo == 19))

chave <- c("periodo", "regiao", "instituicao", "cod_capitulo", "faixa_etaria", "sexo")
chaves_repetidas <- sns %>% group_by(across(all_of(chave))) %>%
  summarise(n_registos = n(), .groups = "drop") %>% filter(n_registos > 1)
# Não sabemos se as linhas repetidas são parcelas ou versões sobrepostas.
# Por isso não somamos nem escolhemos arbitrariamente a primeira linha.
instituicoes_ambiguas <- unique(chaves_repetidas$instituicao)
write_csv(chaves_repetidas, "resultados/chaves_ambiguas.csv")
write_csv(sns %>% filter(instituicao %in% instituicoes_ambiguas),
          "resultados/registos_instituicoes_excluidas.csv")

instituicoes_estaveis <- sns %>% filter(!instituicao %in% instituicoes_ambiguas) %>%
  group_by(instituicao) %>% summarise(n_meses = n_distinct(periodo), .groups = "drop") %>%
  filter(n_meses == 24) %>% pull(instituicao)
sns_painel <- sns %>% filter(instituicao %in% instituicoes_estaveis) %>%
  mutate(duracao_media = if_else(internamentos > 0,
                                 dias_internamentos / internamentos, NA_real_),
         sin_mes = sin(2 * pi * mes / 12), cos_mes = cos(2 * pi * mes / 12))
stopifnot(nrow(sns_painel) >= 1000, !any(duplicated(sns_painel[chave])))
# Sem registo publicado para uma célula não significa que houve zero casos.
write_csv(sns_painel, "data/processed/sns_painel.csv")
write_csv(tibble(instituicao = instituicoes_estaveis), "resultados/instituicoes_painel.csv")
auditoria <- tibble(indicador = c("linhas_originais", "colunas_originais",
  "linhas_identicas", "chaves_repetidas", "linhas_excedentes_por_chave",
  "instituicoes_excluidas", "instituicoes_painel", "linhas_painel", "regioes_painel",
  "celulas_sem_internamentos_painel"), valor = c(nrow(sns_raw), ncol(sns_raw),
  sum(duplicated(sns_raw)), nrow(chaves_repetidas), sum(chaves_repetidas$n_registos - 1),
  length(instituicoes_ambiguas), length(instituicoes_estaveis), nrow(sns_painel),
  n_distinct(sns_painel$regiao), sum(sns_painel$internamentos == 0)))
write_csv(auditoria, "resultados/auditoria.csv")

# Valores extremos: sinalizamos médias elevadas, sem eliminar casos clínicos reais.
q <- quantile(sns_painel$duracao_media, c(.25, .75), na.rm = TRUE)
limite_iqr <- unname(q[2] + 1.5 * (q[2] - q[1]))
extremos <- sns_painel %>% filter(!is.na(duracao_media), duracao_media > limite_iqr)
write_csv(extremos, "resultados/medias_extremas.csv")

ansr_veiculos <- ansr_veiculos %>% mutate(graves_mortos = feridos_graves + mortos,
  proporcao_grave = graves_mortos / total_vitimas)
stopifnot(all(ansr_veiculos$total_vitimas ==
  ansr_veiculos$mortos + ansr_veiculos$feridos_graves + ansr_veiculos$feridos_leves))
ansr_vias <- ansr_vias %>% mutate(total_vitimas = mortos + feridos_graves + feridos_leves,
  proporcao_grave = (mortos + feridos_graves) / total_vitimas)
# Conferência com os totais oficiais do Continente no quadro 2.
stopifnot(sum(ansr_mensal$feridos_graves[ansr_mensal$ano == 2023]) == 2437,
          sum(ansr_mensal$feridos_graves[ansr_mensal$ano == 2024]) == 2576,
          sum(ansr_mensal$acidentes[ansr_mensal$ano == 2024]) == 36338)
write_csv(ansr_mensal, "data/processed/ansr_mensal.csv")
write_csv(ansr_veiculos, "data/processed/ansr_veiculos.csv")
write_csv(ansr_vias, "data/processed/ansr_vias.csv")
