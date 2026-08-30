# ------------------------------------------------------------------------------
# arquivar-versoes.R -- arquiva versoes do manuscrito e extrai o texto
#
#   Rscript tools/arquivar-versoes.R                    # varre ~/Downloads
#   Rscript tools/arquivar-versoes.R "C:/outra/pasta"   # varre outra pasta
#
# O que faz, para cada .docx encontrado:
#
#   1. Le a data de criacao e de ultima modificacao de dentro do arquivo
#      (docProps/core.xml). E o unico jeito confiavel: baixar do Google Drive
#      reescreve a data do sistema de arquivos, entao o mtime do disco nao diz
#      quando o texto foi escrito.
#   2. Copia para manuscript/versoes/ com nome normalizado AAAA-MM-DD_slug.docx.
#   3. Extrai o texto para manuscript/texto/AAAA-MM-DD_slug.txt, uma frase por
#      linha. E esse .txt que torna a evolucao visivel: `git diff` entre duas
#      versoes mostra o que saiu e o que entrou.
#   4. Atualiza manuscript/versoes.csv com data, autor da ultima edicao,
#      contagem de palavras e caminho.
#
# Rodar de novo e seguro: arquivos ja arquivados sao ignorados.
# ------------------------------------------------------------------------------

# A raiz e a pasta que contem o run_all.R deste pacote. Nao usamos here(), que
# neste caso sobe demais: o repositorio vive dentro de um meta-repositorio, e
# here() ancora no de fora.
achar_raiz <- function(dir = getwd()) {
  while (!file.exists(file.path(dir, "run_all.R"))) {
    pai <- dirname(dir)
    if (pai == dir) stop("rode a partir da pasta do pacote de replicação")
    dir <- pai
  }
  dir
}

raiz      <- achar_raiz()
DIR_VERS  <- file.path(raiz, "manuscript", "versoes")
DIR_TEXTO <- file.path(raiz, "manuscript", "texto")
ARQ_LISTA <- file.path(raiz, "manuscript", "versoes.csv")
# Override manual de datas e classificacao. Arquivos exportados do Google Docs
# vem sem metadados internos, e o mtime do disco e reescrito pelo download --
# entao para esses a data verdadeira so existe no listing do zip de origem, e
# precisa ser informada aqui.
ARQ_DATAS <- file.path(raiz, "manuscript", "datas.csv")

for (d in c(DIR_VERS, DIR_TEXTO)) dir.create(d, recursive = TRUE, showWarnings = FALSE)

args   <- commandArgs(TRUE)
origem <- if (length(args)) args[1] else file.path(path.expand("~"), "Downloads")
if (!dir.exists(origem)) stop("pasta de origem nao existe: ", origem)

# Metadados de dentro do .docx -------------------------------------------------
# O core.xml traz dcterms:created, dcterms:modified e cp:lastModifiedBy.
metadados <- function(arquivo) {
  tmp <- tempfile()
  ok <- tryCatch({
    utils::unzip(arquivo, files = "docProps/core.xml", exdir = tmp)
    TRUE
  }, warning = function(w) FALSE, error = function(e) FALSE)

  caminho <- file.path(tmp, "docProps", "core.xml")
  if (!ok || !file.exists(caminho)) {
    return(list(criado = NA_character_, modificado = NA_character_, autor = NA_character_))
  }

  xml <- paste(readLines(caminho, warn = FALSE), collapse = "")
  campo <- function(tag) {
    m <- regmatches(xml, regexpr(sprintf("<%s[^>]*>[^<]*</%s>", tag, tag), xml))
    if (!length(m)) return(NA_character_)
    sub(sprintf("</%s>$", tag), "", sub(sprintf("^<%s[^>]*>", tag), "", m))
  }
  list(criado     = substr(campo("dcterms:created"), 1, 10),
       modificado = substr(campo("dcterms:modified"), 1, 10),
       autor      = campo("cp:lastModifiedBy"))
}

# Nome de arquivo legivel, sem acentos nem espacos.
sluguificar <- function(x) {
  x <- tools::file_path_sans_ext(basename(x))
  x <- iconv(x, to = "ASCII//TRANSLIT")
  x <- gsub("[^A-Za-z0-9]+", "-", x)
  x <- gsub("(^-|-$)", "", x)
  tolower(substr(x, 1, 60))
}

docx <- list.files(origem, pattern = "[.]docx$", full.names = TRUE,
                   ignore.case = TRUE, recursive = TRUE)
docx <- docx[!grepl("^~[$]", basename(docx))]   # arquivos de bloqueio do Word

if (!length(docx)) {
  message("Nenhum .docx em ", origem)
  quit(save = "no")
}

datas <- if (file.exists(ARQ_DATAS)) {
  utils::read.csv(ARQ_DATAS, encoding = "UTF-8")
} else {
  data.frame(origem = character(), data = character(), tipo = character(),
             nota = character())
}

registro <- if (file.exists(ARQ_LISTA)) {
  utils::read.csv(ARQ_LISTA, encoding = "UTF-8")
} else {
  data.frame(data = character(), tipo = character(), autor = character(),
             palavras = numeric(), arquivo = character(), origem = character(),
             nota = character(), md5 = character())
}

novos <- 0

for (f in docx) {
  md5 <- unname(tools::md5sum(f))
  if (md5 %in% registro$md5) next          # ja arquivado, ainda que com outro nome

  m    <- metadados(f)
  ov   <- datas[datas$origem == basename(f), ]
  tipo <- if (nrow(ov)) ov$tipo[1] else ""
  nota <- if (nrow(ov)) ov$nota[1] else ""

  data <- if (nrow(ov) && nzchar(ov$data[1])) ov$data[1] else m$modificado
  if (is.na(data) || !nzchar(data)) data <- m$criado
  if (is.na(data) || !nzchar(data)) {
    data <- format(as.Date(file.info(f)$mtime), "%Y-%m-%d")
    message("  SEM DATA CONFIAVEL, usando o mtime: ", basename(f),
            " -- acrescente uma linha em manuscript/datas.csv")
  }

  destino <- file.path(DIR_VERS, sprintf("%s_%s.docx", data, sluguificar(f)))
  file.copy(f, destino, overwrite = TRUE)

  # Texto plano, uma frase por linha: e o que faz o diff entre versoes ficar
  # legivel. Sem isso, o Word guarda tudo num paragrafo unico e o diff vira
  # uma linha gigante que nao diz nada.
  txt <- file.path(DIR_TEXTO, sprintf("%s_%s.txt", data, sluguificar(f)))
  system2("pandoc", c("-t", "plain", "--wrap=none", shQuote(destino)),
          stdout = txt)
  linhas <- readLines(txt, warn = FALSE)
  linhas <- unlist(strsplit(linhas, "(?<=[.!?]) +(?=[A-ZÀ-Ú])", perl = TRUE))
  writeLines(linhas, txt, useBytes = TRUE)

  palavras <- length(unlist(strsplit(paste(linhas, collapse = " "), "\\s+")))

  registro <- rbind(registro, data.frame(
    data = data, tipo = tipo, autor = ifelse(is.na(m$autor), "", m$autor),
    palavras = palavras, arquivo = basename(destino),
    origem = basename(f), nota = nota, md5 = md5))
  novos <- novos + 1
  message(sprintf("  arquivado  %s  %5d palavras  %s", data, palavras, basename(destino)))
}

registro <- registro[order(registro$data, registro$arquivo), ]
utils::write.csv(registro, ARQ_LISTA, row.names = FALSE, fileEncoding = "UTF-8")

message("\n", novos, " versão(ões) nova(s). O arquivo tem agora ",
        nrow(registro), " versões, de ", min(registro$data), " a ",
        max(registro$data), ".")
