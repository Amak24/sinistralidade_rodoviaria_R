# A média correta é a razão dos totais; não a média simples das médias.
resumo_hospitalar <- sns_painel %>% group_by(ano) %>% summarise(
  internamentos = sum(internamentos), dias = sum(dias_internamentos),
  obitos = sum(obitos), media_dias = dias / internamentos, .groups = "drop")
resumo_idade_sexo <- sns_painel %>% group_by(faixa_etaria, sexo) %>% summarise(
  internamentos = sum(internamentos), dias = sum(dias_internamentos),
  media_dias = dias / internamentos, .groups = "drop")
resumo_regiao <- sns_painel %>% group_by(regiao) %>% summarise(
  instituicoes = n_distinct(instituicao), internamentos = sum(internamentos),
  dias = sum(dias_internamentos), media_dias = dias / internamentos, .groups = "drop")
comparacao_veiculos <- ansr_veiculos %>%
  filter(veiculo %in% c("Motociclos", "Veículos ligeiros"))
comparacao_ratio <- comparacao_veiculos %>% select(ano, veiculo, proporcao_grave) %>%
  pivot_wider(names_from = veiculo, values_from = proporcao_grave) %>%
  mutate(razao_proporcoes = Motociclos / `Veículos ligeiros`,
         diferenca_pp = 100 * (Motociclos - `Veículos ligeiros`))
# Razão entre proporções de vítimas registadas: não risco por quilómetro ou condutor.

sns_mensal <- sns_painel %>% group_by(periodo) %>% summarise(
  internamentos = sum(internamentos), dias_internamentos = sum(dias_internamentos),
  n_instituicoes = n_distinct(instituicao), .groups = "drop")
stopifnot(!anyDuplicated(ansr_mensal$periodo), !anyDuplicated(sns_mensal$periodo),
          nrow(anti_join(ansr_mensal, sns_mensal, by = "periodo")) == 0,
          nrow(anti_join(sns_mensal, ansr_mensal, by = "periodo")) == 0,
          all(sns_mensal$n_instituicoes == length(instituicoes_estaveis)))
cruzamento <- inner_join(ansr_mensal, sns_mensal, by = "periodo") %>% arrange(periodo) %>%
  mutate(t = row_number(), sin_mes = sin(2 * pi * mes / 12), cos_mes = cos(2 * pi * mes / 12))
stopifnot(nrow(cruzamento) == 24)
# Só uma linha por mês: não duplicamos os dias hospitalares por tipo de veículo.
# A ANSR representa o Continente; o SNS representa apenas o painel selecionado.
associacoes <- bind_rows(lapply(c("Total", "2023", "2024"), function(a) {
  d <- if (a == "Total") cruzamento else filter(cruzamento, ano == as.integer(a))
  tibble(periodo_analise = a, n_meses = nrow(d),
    rho_internamentos = cor(d$feridos_graves, d$internamentos, method = "spearman"),
    rho_dias = cor(d$feridos_graves, d$dias_internamentos, method = "spearman"))
}))
# Correlações descritivas: séries sazonais dependentes não justificam testes ingénuos.
# Sensibilidade: somar todas as linhas é um cenário, não uma validação de duplicados.
sensibilidade_mensal <- sns %>% group_by(periodo) %>% summarise(
  dias_todas_linhas = sum(dias_internamentos), .groups = "drop") %>%
  inner_join(cruzamento, by = "periodo")
sensibilidade <- tibble(cenario = c("Painel sem ambiguidades", "Todas as linhas (possível sobrecontagem)"),
  rho_dias = c(cor(cruzamento$feridos_graves, cruzamento$dias_internamentos, method = "spearman"),
               cor(sensibilidade_mensal$feridos_graves, sensibilidade_mensal$dias_todas_linhas, method = "spearman")))

for (nome in c("resumo_hospitalar", "resumo_idade_sexo", "resumo_regiao", "comparacao_veiculos",
               "comparacao_ratio", "associacoes", "sensibilidade")) {
  write_csv(get(nome), paste0("resultados/", nome, ".csv"))
}
write_csv(cruzamento, "data/processed/cruzamento_mensal.csv")

# Gráficos com ggplot2. Os objetos g1...g6 também entram no relatório.
cores <- c("#087E8B", "#E08D39")
theme_set(theme_minimal(base_size = 12))
g1 <- ggplot(comparacao_veiculos, aes(factor(ano), 100 * proporcao_grave, fill = veiculo)) +
  geom_col(position = "dodge", width = .65) +
  geom_text(aes(label = sprintf("%.2f%%", 100 * proporcao_grave)),
            position = position_dodge(.65), vjust = -.5, size = 4) +
  scale_fill_manual(values = cores) +
  labs(title = "Consequências graves entre as vítimas registadas", x = "Ano",
       y = "Feridos graves + mortos / total de vítimas (%)", fill = "Veículo",
       caption = "ANSR: Portugal continental; critério de vítimas a 24h. Não mede exposição ao trânsito.") +
  expand_limits(y = 11)
g2 <- ggplot(filter(ansr_vias, ano == 2024), aes(reorder(via, proporcao_grave), 100 * proporcao_grave)) +
  geom_col(fill = "#087E8B", width = .65) + coord_flip() +
  labs(title = "Gravidade por tipo de via — todos os veículos (2024)",
       x = "Tipo de via", y = "Vítimas graves ou mortais (%)",
       caption = "Quadro marginal ANSR: não permite isolar motociclos em cada via.")
ordem_idades <- c("[0-1[", "[1-5[", "[5-15[", "[15-25[", "[25-45[", "[45-65[", "[65-120[")
resumo_idade_sexo <- resumo_idade_sexo %>% mutate(faixa_etaria = factor(faixa_etaria, levels = ordem_idades))
g3 <- ggplot(resumo_idade_sexo, aes(faixa_etaria, media_dias, fill = sexo)) +
  geom_col(position = "dodge", width = .7) + scale_fill_manual(values = cores) +
  labs(title = "Duração média dos internamentos por lesões", x = "Faixa etária (anos)",
       y = "Dias por internamento", fill = "Sexo",
       caption = "Painel fixo de instituições; 2023–2024. Inclui lesões de várias causas.")
series <- cruzamento %>% transmute(periodo,
  `Feridos graves — ANSR` = feridos_graves / mean(feridos_graves) * 100,
  `Dias de internamento — painel SNS` = dias_internamentos / mean(dias_internamentos) * 100) %>%
  pivot_longer(-periodo, names_to = "indicador", values_to = "indice")
g4 <- ggplot(series, aes(periodo, indice, color = indicador)) + geom_line(linewidth = .8) +
  geom_point(size = 1.8) + scale_color_manual(values = cores) +
  labs(title = "Evolução mensal: comparação de tendências", x = "Mês",
       y = "Índice (média dos 24 meses = 100)", color = NULL,
       caption = "Meses do acidente e da alta podem diferir. As duas séries têm coberturas distintas.") +
  theme(legend.position = "bottom")
g5 <- ggplot(cruzamento, aes(feridos_graves, dias_internamentos, color = factor(ano))) +
  geom_point(size = 3) + scale_color_manual(values = cores) +
  labs(title = "Associação temporal entre sinistralidade e dias hospitalares",
       x = "Feridos graves ANSR — Continente", y = "Dias por lesões — painel SNS", color = "Ano",
       caption = "24 meses; associação agregada. Não demonstra causalidade nem ligação entre vítimas.")
if (gravar_graficos) for (i in 1:5) ggsave(paste0("resultados/graficos/g", i, ".png"), get(paste0("g", i)),
                      width = 9, height = 5, dpi = 180, bg = "white")
