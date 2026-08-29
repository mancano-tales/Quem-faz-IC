# ------------------------------------------------------------------------------
# run_all.R -- executa o pacote de replicacao inteiro, do bruto ao resultado
#
# Uso:
#   Rscript run_all.R          (de qualquer lugar dentro do projeto)
#   source("run_all.R")        (no RStudio, com o .Rproj aberto)
#
# Reconstroi data/ic_usp.parquet a partir das planilhas do SIC-USP e regrava
# tudo o que esta em outputs/. Leva alguns minutos: a leitura das planilhas
# brutas (34 MB de xlsx) e a parte lenta.
# ------------------------------------------------------------------------------

if (!requireNamespace("here", quietly = TRUE)) {
  install.packages("here", repos = "https://cloud.r-project.org")
}

etapas <- c(
  "01-build-data.R"          ,
  "02-article-fflch.R"       ,
  "03-supplementary-usp.R"
)

inicio_total <- Sys.time()

for (etapa in etapas) {
  caminho <- here::here("analysis", etapa)
  message("\n", strrep("=", 78))
  message("== ", etapa)
  message(strrep("=", 78))

  inicio <- Sys.time()
  # Cada etapa roda em seu proprio ambiente: nenhuma depende de objetos
  # deixados na memoria pela anterior, so dos arquivos que ela grava.
  source(caminho, local = new.env(), echo = FALSE)
  message(sprintf("-- concluida em %.1f min",
                  as.numeric(difftime(Sys.time(), inicio, units = "mins"))))
}

message("\n", strrep("=", 78))
message(sprintf("== Pacote de replicacao concluido em %.1f min",
                as.numeric(difftime(Sys.time(), inicio_total, units = "mins"))))
message("== Resultados em outputs/tables e outputs/figures")
message(strrep("=", 78))
