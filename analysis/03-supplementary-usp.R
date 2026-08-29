# ------------------------------------------------------------------------------
# 03-supplementary-usp.R -- analises suplementares fora do recorte do artigo
#
# Entrada: data/ic_usp.parquet
# Saida  : outputs/tables/supl-*, outputs/figures/supl-*
#
# O artigo analisa a FFLCH. O painel, porem, cobre a USP inteira, e os autores
# mantinham dois recortes adicionais em scripts separados (ic_fflch_usp.R e
# ic_ciencias_sociais_usp.R), com dezenas de modelos exploratorios.
#
# Aqui esses recortes viram uma comparacao com uma pergunta so: a mesma
# especificacao da Tabela 4 do artigo se sustenta fora da FFLCH? Manter a
# especificacao fixa e o que torna as tres colunas comparaveis entre si.
# Nenhum destes resultados entra no artigo publicado.
# ------------------------------------------------------------------------------

source(here::here("R", "setup.R"))
source(here::here("R", "recode.R"))

painel <- arrow::read_parquet(ARQ_PAINEL) |>
  aplicar_recodificacoes() |>
  dplyr::mutate(IC = dplyr::coalesce(IC, 0))

# Mesma janela do modelo do artigo.
painel <- dplyr::filter(painel, ano %in% 2010:2022)

FORMULA_ARTIGO <- IC ~ ano + idade + sexo + raca + educ_resp + sfmpct +
  trabalho + sustento + periodo + class_carreira

ajustar <- function(dados) {
  md <- dados |>
    dplyr::select(IC, ano, idade, sexo, raca, educ_resp, sfmpct,
                  trabalho, sustento, periodo, class_carreira) |>
    na.exclude()
  glm(FORMULA_ARTIGO, data = md, family = binomial)
}

# Acesso a IC por unidade da USP ----------------------------------------------
# Ordena as unidades pela proporcao de estudantes que fizeram IC, para situar a
# FFLCH no conjunto da universidade.

supl_unidades <- painel |>
  dplyr::group_by(unidade) |>
  dplyr::summarise(
    n       = dplyr::n(),
    fez_ic  = sum(IC, na.rm = TRUE),
    pct_ic  = mean(IC, na.rm = TRUE),
    .groups = "drop"
  ) |>
  dplyr::filter(n >= 500) |>   # unidades pequenas dao proporcoes instaveis
  dplyr::arrange(dplyr::desc(pct_ic))

writexl::write_xlsx(supl_unidades,
                    file.path(DIR_TABLES, "supl-1-ic-por-unidade.xlsx"))

# Acesso a IC por coorte, nos tres recortes ------------------------------------

recortes <- list(
  "USP"              = painel,
  "FFLCH"            = dplyr::filter(painel, unidade == UNIDADE_FFLCH),
  "Ciências Sociais" = dplyr::filter(painel, curso == "Ciências Sociais")
)

supl_coortes <- do.call(rbind, lapply(names(recortes), function(nm) {
  recortes[[nm]] |>
    dplyr::group_by(ano) |>
    dplyr::summarise(n = dplyr::n(), pct_ic = mean(IC, na.rm = TRUE),
                     .groups = "drop") |>
    dplyr::mutate(recorte = nm, .before = 1)
}))

writexl::write_xlsx(supl_coortes,
                    file.path(DIR_TABLES, "supl-2-ic-por-coorte.xlsx"))

fig_supl <- supl_coortes |>
  ggplot2::ggplot(ggplot2::aes(x = ano, y = pct_ic, colour = recorte,
                               linetype = recorte)) +
  ggplot2::geom_line(linewidth = 1.1) +
  ggplot2::geom_point(size = 2) +
  ggplot2::scale_y_continuous(labels = scales::percent) +
  ggplot2::scale_x_continuous(breaks = seq(2010, 2022, 2)) +
  ggplot2::labs(x = "Coorte de ingresso", y = "Estudantes que fizeram IC",
                colour = NULL, linetype = NULL) +
  ggplot2::theme(legend.position = "bottom")

ggplot2::ggsave(file.path(DIR_FIGURES, "supl-1-ic-por-coorte.png"),
                fig_supl, width = 8, height = 5, dpi = 300)

# A especificacao do artigo nos tres recortes ----------------------------------

modelos <- lapply(recortes, ajustar)

stargazer::stargazer(
  modelos, nobs = TRUE, type = "html",
  column.labels = names(recortes),
  out = file.path(DIR_TABLES, "supl-3-modelo-por-recorte.html")
)

message("\n--- Acesso a IC por recorte (coortes 2010-2022) ---")
for (nm in names(recortes)) {
  m <- modelos[[nm]]
  message(sprintf("%-17s n = %6d | modelo N = %6d | AIC = %9.2f | sustento(propria) = %+.3f",
                  nm, nrow(recortes[[nm]]), nobs(m), AIC(m),
                  coef(m)[["sustentoPor conta própria"]]))
}

message("\n--- Cinco unidades com maior e menor acesso a IC ---")
print(rbind(utils::head(supl_unidades, 5), utils::tail(supl_unidades, 5)),
      row.names = FALSE)
