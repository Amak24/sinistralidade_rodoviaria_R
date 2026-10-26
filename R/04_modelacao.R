# M4: análise aprofundada da associação temporal.
associacao_ajustada <- lm(dias_internamentos ~ feridos_graves + t + sin_mes + cos_mes,
                         data = cruzamento)
writeLines(capture.output(summary(associacao_ajustada)), "resultados/associacao_ajustada.txt")
write_csv(tibble(termo = names(coef(associacao_ajustada)),
                estimativa = unname(coef(associacao_ajustada))),
          "resultados/associacao_ajustada_coeficientes.csv")

# Modelo simples e explicável, adequado à unidade agregada disponível.
# Estima a média de dias por célula hospital/mês/faixa etária/sexo.
# Não prevê a recuperação de uma pessoa nem usa dados hospitalares por veículo.
dados_modelo <- sns_painel %>% filter(internamentos > 0) %>%
  mutate(faixa_etaria = factor(faixa_etaria), sexo = factor(sexo), regiao = factor(regiao))
treino <- filter(dados_modelo, ano == 2023)
teste <- filter(dados_modelo, ano == 2024)
# O teste representa o ano seguinte, evitando distribuir o mesmo período aleatoriamente.
modelo <- lm(duracao_media ~ faixa_etaria + sexo + regiao + sin_mes + cos_mes,
             data = treino, weights = internamentos)
# Ponderamos pelo volume de episódios: células muito pequenas não dominam o ajuste.
# Coeficientes são descritivos. Erros-padrão usuais não corrigem repetição por instituição.
teste$previsao <- predict(modelo, newdata = teste)
base <- weighted.mean(treino$duracao_media, treino$internamentos)
metricas <- function(obs, pred, peso) {
  c(MAE = weighted.mean(abs(obs - pred), peso),
    RMSE = sqrt(weighted.mean((obs - pred)^2, peso)))
}
m1 <- metricas(teste$duracao_media, teste$previsao, teste$internamentos)
m0 <- metricas(teste$duracao_media, rep(base, nrow(teste)), teste$internamentos)
# Análise de sensibilidade: exclusão de médias extremas SOMENTE no treino.
# O limite é aprendido em 2023; o teste completo é o mesmo para todos os modelos.
qt <- quantile(treino$duracao_media, c(.25, .75))
limite_treino <- unname(qt[2] + 1.5 * diff(qt))
modelo_sens <- lm(duracao_media ~ faixa_etaria + sexo + regiao + sin_mes + cos_mes,
                  data = filter(treino, duracao_media <= limite_treino), weights = internamentos)
ms <- metricas(teste$duracao_media, predict(modelo_sens, newdata = teste), teste$internamentos)
avaliacao <- tibble(modelo = c("Regressão ponderada", "Referência: média de 2023", "Sensibilidade: treino sem extremos"),
  MAE_dias = c(m1[1], m0[1], ms[1]), RMSE_dias = c(m1[2], m0[2], ms[2]),
  n_celulas_teste = nrow(teste))
write_csv(avaliacao, "resultados/avaliacao_modelo.csv")
write_csv(teste, "resultados/previsoes_2024.csv")
write_csv(tibble(termo = names(coef(modelo)), estimativa_dias = unname(coef(modelo))),
          "resultados/coeficientes_modelo.csv")
writeLines(capture.output(summary(modelo)), "resultados/modelo_resumo.txt")
saveRDS(modelo, "resultados/modelo.rds")
write_csv(tibble(n_treino = nrow(treino), n_teste = nrow(teste),
  base_dias = base, limite_iqr_treino = limite_treino,
  previsoes_negativas = sum(teste$previsao < 0),
  correlacao_residuos_lag1 = cor(residuals(associacao_ajustada)[-1],
    head(residuals(associacao_ajustada), -1))), "resultados/diagnosticos.csv")
g6 <- ggplot(teste, aes(previsao, duracao_media)) +
  geom_point(alpha = .18, color = "#087E8B") + geom_abline(slope = 1, intercept = 0, color = "#E08D39") +
  coord_cartesian(ylim = c(0, quantile(teste$duracao_media, .99))) +
  labs(title = "Avaliação temporal: médias previstas e observadas em 2024",
       x = "Dias previstos por célula", y = "Dias observados por célula",
       caption = "Vista até ao percentil 99; as métricas usam todas as células do teste.")
if (gravar_graficos) ggsave("resultados/graficos/g6.png", g6, width = 9, height = 5, dpi = 180, bg = "white")
