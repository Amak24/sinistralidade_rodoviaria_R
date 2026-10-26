# Conferência dos resultados

Os CSV de `referencia/` preservam os resultados da edição do estudo correspondente aos relatórios enviados. Não são usados como entrada para ajustar a regressão nem para calcular as tabelas.

Depois da análise, `verificar_resultados.R` compara os resultados recalculados com estes nove ficheiros, com uma pequena tolerância numérica. `INICIAR_AQUI.R` faz esta comparação automaticamente.

Se mudar os dados, as decisões de preparação ou o modelo, é normal que os valores deixem de coincidir. Nesse caso, a divergência deve ser analisada e documentada; não substitua a referência apenas para ocultar uma diferença.

O ficheiro `resultados/sessionInfo.txt` regista a versão de R, os pacotes e o sistema utilizados na execução mais recente. Os resultados que acompanham este ZIP foram gerados pelo código incluído.
