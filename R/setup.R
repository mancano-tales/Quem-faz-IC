# ------------------------------------------------------------------------------
# setup.R -- pacotes, caminhos e opcoes comuns a todos os scripts
#
# Pacote de replicacao: "Quem faz Iniciacao Cientifica?"
# Mancano & Alcantara
# ------------------------------------------------------------------------------

# Pacotes necessarios. Instala o que estiver faltando.
.pkgs <- c("here", "dplyr", "tidyr", "readxl", "writexl",
           "ggplot2", "scales", "arrow", "stargazer")

.faltando <- .pkgs[!vapply(.pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(.faltando)) {
  message("Instalando pacotes ausentes: ", paste(.faltando, collapse = ", "))
  install.packages(.faltando, repos = "https://cloud.r-project.org")
}
invisible(lapply(.pkgs, library, character.only = TRUE))

# Caminhos ---------------------------------------------------------------------
# here::here() ancora tudo na raiz do projeto (onde esta o .Rproj), de modo que
# os scripts rodam igual pelo RStudio, pelo Rscript e pelo Quarto.
DIR_RAW     <- here::here("data-raw")
DIR_DATA    <- here::here("data")
DIR_TABLES  <- here::here("outputs", "tables")
DIR_FIGURES <- here::here("outputs", "figures")

for (d in c(DIR_DATA, DIR_TABLES, DIR_FIGURES)) {
  if (!dir.exists(d)) dir.create(d, recursive = TRUE)
}

# Arquivos de origem (respostas do SIC-USP a Lei de Acesso a Informacao) --------
ARQ_JUPITER <- file.path(DIR_RAW, "sic-usp-243654-ingressantes.xlsx")
ARQ_ATENA   <- file.path(DIR_RAW, "sic-usp-243681-perfil-ic.xlsx")
ARQ_PAINEL  <- file.path(DIR_DATA, "ic_usp.parquet")

# Recorte analitico do artigo --------------------------------------------------
UNIDADE_FFLCH <- "Faculdade de Filosofia, Letras e Ciências Humanas"
COORTES       <- 2010:2018   # coortes de ingresso analisadas no artigo

# Opcoes -----------------------------------------------------------------------
options(stringsAsFactors = FALSE, scipen = 999)
ggplot2::theme_set(ggplot2::theme_bw(base_size = 12))

TEMA_ARTIGO <- ggplot2::theme(
  panel.grid.major = ggplot2::element_blank(),
  panel.grid.minor = ggplot2::element_blank(),
  axis.text  = ggplot2::element_text(size = 12),
  axis.title = ggplot2::element_text(size = 12)
)

set.seed(1234)
