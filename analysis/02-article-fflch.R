# ------------------------------------------------------------------------------
# 02-article-fflch.R -- tabelas, modelos e figuras do artigo
#
# "Quem faz Iniciacao Cientifica? Um estudo sobre as desigualdades
#  socioeconomicas no acesso a Iniciacao Cientifica FFLCH-USP (2010-2022)"
#
# Entrada: data/ic_usp.parquet
# Saida  : outputs/tables/*, outputs/figures/*
#
# Atencao a dois recortes diferentes, ambos presentes no artigo:
#   - as tabelas descritivas usam as coortes de ingresso 2010-2018;
#   - o modelo logistico usa 2010-2022 (N = 16.974, como na Tabela 4 publicada).
# ------------------------------------------------------------------------------

source(here::here("R", "setup.R"))
source(here::here("R", "recode.R"))

painel <- arrow::read_parquet(ARQ_PAINEL)

# Recorte FFLCH. Quem nao consta na base do Atena nunca fez IC: NA vira 0.
fflch <- painel |>
  dplyr::filter(unidade == UNIDADE_FFLCH) |>
  aplicar_recodificacoes() |>
  dplyr::mutate(IC = dplyr::coalesce(IC, 0))

coortes  <- dplyr::filter(fflch, ano %in% COORTES)      # 2010-2018, descritivas
amostra  <- dplyr::filter(fflch, ano %in% 2010:2022)    # 2010-2022, modelo

# Tabela 1 -- proporcao de estudantes que realizaram IC por coorte -------------

tabela1 <- coortes |>
  dplyr::group_by(ano) |>
  dplyr::summarise(
    n        = dplyr::n(),
    fez_ic   = sum(IC, na.rm = TRUE),
    projetos = sum(qtd_ic, na.rm = TRUE),
    .groups  = "drop"
  ) |>
  dplyr::mutate(pct_ic = fez_ic / n)

writexl::write_xlsx(tabela1, file.path(DIR_TABLES, "tabela-1-coortes-fflch.xlsx"))

# Tabela 2 -- taxa de resposta de cada questao do QASE -------------------------

questoes_qase <- c(
  estado_civil    = "Qual é o seu estado civil?",
  ef1             = "Onde você cursou o ensino fundamental/1º Grau?",
  ef2             = "Onde você cursou/cursa o ensino médio/2º Grau?",
  em              = "Que tipo de ensino médio você concluiu/concluirá?",
  rfm             = "Renda familiar mensal",
  pessoas_contrib = "Quantas pessoas contribuem para a obtenção dessa renda familiar?",
  pessoas_resid   = "Quantas pessoas vivem da renda?",
  atv_remu        = "Você exerce alguma atividade remunerada?",
  educ_resp1      = "Instrução do pai ou responsável 1 e variações",
  educ_resp2      = "Instrução da mãe ou responsável 2 e variações",
  ocup_resp1      = "Ocupação/Situação Ocupacional do principal contribuinte da família?",
  pretensao_mant  = "Como pretende se manter durante seus estudos universitários?",
  inclusp         = "Você está participando do processo INCLUSP? (Para os anos aplicáveis)"
)

# A Tabela 2 publicada usa a janela 2010-2022, e nao as coortes 2010-2018 da
# Tabela 1 -- e a janela que reproduz as taxas do artigo (98,55% no Item 16).
tabela2 <- data.frame(
  questao       = unname(questoes_qase),
  pct_respostas = vapply(names(questoes_qase),
                         function(v) mean(!is.na(amostra[[v]])),
                         numeric(1)),
  row.names = NULL
)

writexl::write_xlsx(tabela2, file.path(DIR_TABLES, "tabela-2-resposta-qase.xlsx"))

# Tabela 3 -- numero de projetos de IC por tipo de fomento ---------------------
# Contada sobre os projetos do Atena dos estudantes das coortes 2010-2022.
# Lemos o arquivo bruto (e nao as colunas do painel) para conseguir informar
# tambem os projetos sem tipo de fomento registrado, que o painel descarta.
#
# ATENCAO: esta tabela NAO reproduz a Tabela 3 publicada. A nota de fonte do
# artigo cita o pedido SIC-USP Cod.#239991, uma extracao anterior que nao
# acompanha este pacote, e cujas categorias ("Bolsas FFLCH", "Bolsas Programas
# Reitoria (USP)") nao existem na extracao Cod.#243681 aqui distribuida.
# Ver a secao "Divergencias em relacao ao publicado" no README.

atena <- readxl::read_excel(ARQ_ATENA, sheet = "BD")

tabela3 <- atena |>
  dplyr::filter(Identificador %in% amostra$id) |>
  dplyr::count(tipo_fomento = TipoFomento, sort = TRUE) |>
  dplyr::rename(casos = n) |>
  dplyr::mutate(
    tipo_fomento = dplyr::coalesce(tipo_fomento, "Sem informação sobre fomento"),
    pct = casos / sum(casos)
  )

writexl::write_xlsx(tabela3, file.path(DIR_TABLES, "tabela-3-tipo-fomento.xlsx"))

# Tabela 4 -- regressao logistica ---------------------------------------------
# Quatro modelos aninhados: tendencia temporal, origem social, vinculo com o
# trabalho e, por fim, o proxy de desempenho (classificacao na carreira).
# O modelo completo (reg4) e o reportado na Tabela 4 do artigo.

md <- amostra |>
  dplyr::select(IC, ano, idade, sexo, raca, educ_resp, sfmpct,
                trabalho, sustento, periodo, class_carreira) |>
  na.exclude()

reg1 <- glm(IC ~ ano, data = md, family = binomial)

reg2 <- glm(IC ~ ano + idade + sexo + raca + educ_resp + sfmpct,
            data = md, family = binomial)

reg3 <- glm(IC ~ ano + idade + sexo + raca + educ_resp + sfmpct +
              trabalho + sustento,
            data = md, family = binomial)

reg4 <- glm(IC ~ ano + idade + sexo + raca + educ_resp + sfmpct +
              trabalho + sustento + periodo + class_carreira,
            data = md, family = binomial)

# As tres colunas da Tabela 4 publicada sao o mesmo reg4 reexpresso: os
# coeficientes na escala logito ("Valor Z"), exponenciados ("Razao de chance")
# e exponenciados menos um ("Probabilidades").
stargazer::stargazer(reg1, reg2, reg3, reg4, nobs = TRUE, type = "html",
                     out = file.path(DIR_TABLES, "tabela-4-modelos-aninhados.html"))

stargazer::stargazer(reg4, nobs = TRUE, type = "html",
                     out = file.path(DIR_TABLES, "tabela-4-zvalue.html"))

stargazer::stargazer(reg4, coef = list(exp(coef(reg4))), nobs = TRUE, type = "html",
                     out = file.path(DIR_TABLES, "tabela-4-oddsratio.html"))

stargazer::stargazer(reg4, coef = list(exp(coef(reg4)) - 1), nobs = TRUE, type = "html",
                     out = file.path(DIR_TABLES, "tabela-4-probs.html"))

# Figuras ---------------------------------------------------------------------

md$p <- predict(reg4, md, type = "response")

# Distribuicao da variavel dependente na amostra do modelo.
fig0 <- as.data.frame(prop.table(table(md$IC))) |>
  ggplot2::ggplot(ggplot2::aes(x = Var1, y = Freq)) +
  ggplot2::geom_col(fill = "steelblue", width = 0.5) +
  ggplot2::geom_text(ggplot2::aes(label = scales::percent(Freq, accuracy = 0.1)),
                     vjust = 1.5, size = 4, colour = "white") +
  ggplot2::scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.15)) +
  ggplot2::labs(x = "Realização de IC", y = "Frequência relativa") +
  TEMA_ARTIGO

ggplot2::ggsave(file.path(DIR_FIGURES, "figura-0-distribuicao-ic.png"),
                fig0, width = 6, height = 4, dpi = 300)

tema_densidade <- ggplot2::theme_bw(base_size = 15) +
  ggplot2::theme(
    plot.title    = ggplot2::element_text(hjust = 0.5),
    axis.text     = ggplot2::element_text(size = 18),
    axis.title    = ggplot2::element_text(size = 16),
    legend.position = "bottom",
    legend.title  = ggplot2::element_text(size = 16),
    legend.text   = ggplot2::element_text(size = 16)
  )

# Figura 1 -- densidade das probabilidades preditas por vinculo com o trabalho.
cores_trabalho <- c("Sim, em tempo integral" = "#e97d5a",
                    "Sim, em tempo parcial"  = "#a3a500",
                    "Não"                    = "#1bb57f")
linhas_trabalho <- c("Sim, em tempo integral" = "solid",
                     "Sim, em tempo parcial"  = "dashed",
                     "Não"                    = "dotted")

fig1 <- md |>
  dplyr::mutate(trabalho = factor(trabalho, levels = names(cores_trabalho))) |>
  ggplot2::ggplot(ggplot2::aes(x = p, colour = trabalho, fill = trabalho,
                               linetype = trabalho)) +
  ggplot2::geom_density(linewidth = 1.2, alpha = 0.6) +
  ggplot2::scale_fill_manual(values = cores_trabalho) +
  ggplot2::scale_colour_manual(values = cores_trabalho) +
  ggplot2::scale_linetype_manual(values = linhas_trabalho) +
  ggplot2::scale_x_continuous(limits = c(0, 0.51), breaks = seq(0, 0.5, 0.25),
                              expand = c(0.001, 0.001)) +
  ggplot2::scale_y_continuous(expand = c(0.001, 0.001)) +
  ggplot2::labs(x = "Probabilidades preditas", y = "Densidade",
                colour = "Trabalho", fill = "Trabalho", linetype = "Trabalho") +
  tema_densidade

ggplot2::ggsave(file.path(DIR_FIGURES, "figura-1-trabalho.png"),
                fig1, width = 10, height = 6, dpi = 300)

# Figura 2 -- densidade das probabilidades preditas por pretensao de sustento.
# "Outros" fica de fora: sao poucos casos e uma categoria residual.
cores_sustento <- c("Por conta própria"               = "#e97d5a",
                    "Com trabalho e apoio da família" = "#00aff6",
                    "Suporte da família"              = "#a3a500",
                    "Com bolsa e apoio da família"    = "#1bb57f")
linhas_sustento <- c("Por conta própria"               = "solid",
                     "Com trabalho e apoio da família" = "dotdash",
                     "Suporte da família"              = "dashed",
                     "Com bolsa e apoio da família"    = "dotted")

fig2 <- md |>
  dplyr::filter(sustento != "Outros") |>
  dplyr::mutate(sustento = factor(as.character(sustento),
                                  levels = names(cores_sustento))) |>
  ggplot2::ggplot(ggplot2::aes(x = p, colour = sustento, fill = sustento,
                               linetype = sustento)) +
  ggplot2::geom_density(linewidth = 1.2, alpha = 0.6) +
  ggplot2::scale_fill_manual(values = cores_sustento) +
  ggplot2::scale_colour_manual(values = cores_sustento) +
  ggplot2::scale_linetype_manual(values = linhas_sustento) +
  ggplot2::scale_x_continuous(limits = c(0, 0.51), breaks = seq(0, 0.5, 0.25),
                              expand = c(0.001, 0.001)) +
  ggplot2::scale_y_continuous(expand = c(0.001, 0.001)) +
  ggplot2::labs(x = "Probabilidades preditas", y = "Densidade",
                colour = "Sustento", fill = "Sustento", linetype = "Sustento") +
  tema_densidade

ggplot2::ggsave(file.path(DIR_FIGURES, "figura-2-sustento.png"),
                fig2, width = 10, height = 6, dpi = 300)

# Conferencia contra os numeros publicados ------------------------------------

message("\n--- Tabela 1 (coortes 2010-2018) ---")
print(as.data.frame(tabela1), row.names = FALSE)

message("\n--- Tabela 2: taxa de resposta do QASE (coortes 2010-2022) ---")
print(transform(tabela2, pct_respostas = sprintf("%.2f%%", 100 * pct_respostas)),
      row.names = FALSE, right = FALSE)

message("\n--- Tabela 3: ", sum(tabela3$casos), " projetos de IC ---")
print(as.data.frame(tabela3), row.names = FALSE)
message("    (a Tabela 3 publicada traz 2.979 projetos, de outra extracao do")
message("     SIC-USP -- ver 'Divergencias em relacao ao publicado' no README)")

message(sprintf(
  "\n--- Tabela 4: N = %s | AIC = %.2f | ano = %.3f | racaPPI = %.3f ---",
  format(nobs(reg4), big.mark = "."), AIC(reg4),
  coef(reg4)[["ano"]], coef(reg4)[["racaPPI"]]
))
message("    (publicado: N = 16.974 | AIC = 10537.63 | ano = -0.058 | racaPPI = -0.138)")

# Asseveracoes contra a versao publicada --------------------------------------
# Estas nao sao mensagens: se um numero mudar, o script para aqui. E o que
# impede que uma alteracao no pipeline se afaste do artigo sem que ninguem note.

perto <- function(x, alvo, tol) abs(x - alvo) < tol

stopifnot(
  # Tabela 1 -- coortes 2010-2018 (identica ao publicado nas 9 coortes)
  "Tabela 1: N da coorte de 2010 deve ser 1.732" =
    tabela1$n[tabela1$ano == 2010] == 1732,
  "Tabela 1: 157 estudantes da coorte de 2010 fizeram IC" =
    tabela1$fez_ic[tabela1$ano == 2010] == 157,
  "Tabela 1: N da coorte de 2018 deve ser 1.704" =
    tabela1$n[tabela1$ano == 2018] == 1704,
  "Tabela 1: 261 estudantes da coorte de 2018 fizeram IC" =
    tabela1$fez_ic[tabela1$ano == 2018] == 261,

  # Tabela 2 -- taxas de resposta do QASE (identica nas 13 questoes)
  "Tabela 2: o Item 16 do QASE tem 98,55% de respostas" =
    perto(tabela2$pct_respostas[tabela2$questao == questoes_qase[["em"]]],
          0.9855, 0.00005),
  "Tabela 2: a renda familiar tem 98,42% de respostas" =
    perto(tabela2$pct_respostas[tabela2$questao == questoes_qase[["rfm"]]],
          0.9842, 0.00005),
  "Tabela 2: a ocupacao do contribuinte tem 19,05% de respostas" =
    perto(tabela2$pct_respostas[tabela2$questao == questoes_qase[["ocup_resp1"]]],
          0.1905, 0.00005),

  # Tabela 4 -- modelo logistico
  "Tabela 4: a amostra do modelo deve ter 16.974 observacoes" =
    nobs(reg4) == 16974,
  "Tabela 4: o AIC do modelo deve ser 10537,63" =
    perto(AIC(reg4), 10537.63, 0.01),
  "Tabela 4: o coeficiente de `ano` deve ser -0,058" =
    perto(coef(reg4)[["ano"]], -0.058, 0.0005),
  "Tabela 4: o coeficiente de `raca` (PPI) deve ser -0,138" =
    perto(coef(reg4)[["racaPPI"]], -0.138, 0.0005),
  "Tabela 4: o modelo tem 16 parametros" =
    length(coef(reg4)) == 16
)

message("\nOK: as tabelas 1, 2 e 4 reproduzem os numeros publicados.")
