# Manuseio dos dados --------------------------------------------------------


# Transformando a base de dados originais em uma cópia de trabalho --------------------------------------------------------
SIC_Ingressantes <- SIC_USP_Cod_243654_SIC_USP_EGIDA_Dados_Ingressantes_SIC_2

# Verificando nome das variáveis
names(SIC_Ingressantes)

# Estrutura dos dados 
str(SIC_Ingressantes)

# "SIC_Ingressantes"

# Carregar o pacote dplyr
library(dplyr)

# Filtrar e excluir colunas
Ingressantes_FD <- SIC_Ingressantes_FD 


Ingressantes_FD <- Ingressantes_FD %>%
  filter("Ano de Ingresso" >= 2000 & "Ano de Ingresso" <= 2023) %>%

  
#####

# Instalar e carregar o pacote dplyr se ainda não estiver instalado
if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}

# Carregar o pacote dplyr
library(dplyr)

# Agora você pode usar o operador %>%

Ingressantes_FD <- Ingressantes_FD %>%
  rename(a.Unidade = 'Unidade',
         b.CursoIngresso = 'Curso de ingresso', 
         c.AnoIngresso = 'Ano de Ingresso',
         d.PeriodoIngresso = 'Período de Ingresso',
         e.ModoIngresso = "Modo de Ingresso",
         f.ClassCarreira = "Classificação na carreira",
         g.Modalidade = "Modalidade",
         h.Sit_Bach = "Situação atual do bacharelado",
         i.AnoConDes_Bach = "Ano de Conclusão/Desligamento do bacharelado",
         j.Sit_lic = "Situação atual da licenciatura",
         k.AnoConDes_Lic = "Ano de Conclusão/Desligamentoda licenciatura",
         l.Sexo = "Sexo",
         "m.Raca_cor" = "Raça ou cor",
         "o.Reigressos" = "Número de reingressos",
         "r13" = "Resposta Item 13",
         "r14" = "Resposta Item 14",
         "r15" = "Resposta Item 15",
         "r16" = "Resposta Item 16",
         "r17" = "Resposta Item 17",
         "r18" = "Resposta Item 18",
         "r19" = "Resposta Item 19",
         "r20" = "Resposta Item 20",
         "r21" = "Resposta Item 21",
         "r22" = "Resposta Item 22",
         "r23" = "Resposta Item 23",
         "r24" = "Resposta Item 24",
         "r25" = "Idade no ano da prova do vestibular",
         "r26" = "Resposta Item 26"
  )

Ingressantes_FD <- Ingressantes_FD %>%
  filter(c.AnoIngresso >= 2010 & c.AnoIngresso <= 2023)
print(colnames(Ingressantes_FD))

Ingressantes_FD <- Ingressantes_FD %>%
select(-f.ClassCarreira, -h.Sit_Bach, 
       -i.AnoConDes_Bach, 
       -j.Sit_lic, -k.AnoConDes_Lic, -o.Reigressos)
print(colnames(Ingressantes_FD))


Ingressantes_FD <- Ingressantes_FD %>%
select(-r26)

Ingressantes_FD <- Ingressantes_FD %>%
  rename(Unidade = a.Unidade,
         CursoIngresso  =  b.CursoIngresso,
         AnoIngresso =   c.AnoIngresso,
         PeriodoIngresso =   d.PeriodoIngresso,
         ModoIngresso =   e.ModoIngresso,
         Sexo =   l.Sexo,
         IdadeIngresso =   r25,
         ComoSeManter =   r24,
         EstadoCivil =   r13,
         TipoEscolaEnsFund =   r14,
         TipoEscolaEnsMed =   r15,
         AnoIngresso =   c.AnoIngresso,
         TipoEnsMed =   r16,
         Trabalha =   r20,
         InstrucaoPai =   r21,
         InstrucaoMae =   r22,
  )

write.csv(Ingressantes_FD, file = "file:///users/Mancano/Downloads/Ingressantes_FD.csv", row.names = FALSE)

Ingressantes_FD <- Ingressantes_FD %>%
  rename(Modalidade = g.Modalidade,
         RacaCor  =  m.Raca_cor,
  )

Ingressantes_FD <- Ingressantes_FD %>%
  select(-Identificador)
print(colnames(Ingressantes_FD))

write.csv(Ingressantes_FD, file = "file:///users/Mancano/Downloads/Ingressantes_FD.csv", row.names = FALSE)


#####


# Criando nova base apenas da FFLCH  --------------------------------------------------------
SIC_Ingressantes_FFLCH <- subset(SIC_Ingressantes, Unidade == "Faculdade de Filosofia, Letras e Ciências Humanas")

# Criando nova base apenas da FFLCH  --------------------------------------------------------
SIC_Ingressantes_FD <- subset(SIC_Ingressantes, Unidade == "Faculdade de Direito")

# Print the resulting dataset
print(SIC_Ingressantes_FFLCH)


# Saber os nomes das colunas da base de dados da FFLCH --------------------------------------------------------

# Get the names of the columns in the dataset
column_names <- names(SIC_BD.Est_FFLCH)
print(column_names)


# Agrupar categorias de Raça ou cor em PPI ou não  --------------------------------------------------------

print(SIC_Ingressantes_FFLCH$`Raça ou cor`)

# Create a new column "nPPI" based on the values in the "race_color" column
SIC_Ingressantes_FFLCH$'nPPI' <- ifelse(is.na(SIC_Ingressantes_FFLCH$`Raça ou cor`), "Sem Informação",
                       ifelse(grepl("Branca", SIC_Ingressantes_FFLCH$`Raça ou cor`, ignore.case = TRUE), "Não PPI",
                              ifelse(grepl("Parda", SIC_Ingressantes_FFLCH$`Raça ou cor`, ignore.case = TRUE) | 
                                       grepl("Negr", SIC_Ingressantes_FFLCH$`Raça ou cor`, ignore.case = TRUE) | 
                                       grepl("Pret", SIC_Ingressantes_FFLCH$`Raça ou cor`, ignore.case = TRUE) | 
                                       grepl("Ind", SIC_Ingressantes_FFLCH$`Raça ou cor`, ignore.case = TRUE), "PPI",
                                     ifelse(grepl("inform", SIC_Ingressantes_FFLCH$`Raça ou cor`, ignore.case = TRUE), "Sem Informação",
                                            ifelse(grepl("Amarel", SIC_Ingressantes_FFLCH$`Raça ou cor`, ignore.case = TRUE), "Não PPI",
                                                   "Outro")))))

# Print the updated data frame
print(SIC_Ingressantes_FFLCH$`nPPI`)

# Change the name of the column
colnames(SIC_Ingressantes_FFLCH)[colnames(SIC_Ingressantes_FFLCH) == "Resposta Item 13"] <- "Resposta Item 13 (Estado civil)"

# Ajustando ordem e nomes das Colunas  --------------------------------------------------------

# Renomeando coluna de trabalho pois eu estava confundindo muito
SIC_BD.Est_FFLCH <- SIC_Ingressantes_FFLCH
remove(SIC_Ingressantes_FFLCH)



# Dicionário de renomeação (NÃO FUNCIONOU): nome novo -> nome antigo   --------------------------------------------------------

#dicionario_renomeacao <- c(
    "d.PeriodoIngresso" = "Período de Ingresso",
    "e.ModoIngresso" = "Modo de Ingresso",
    "f.ClassCarreira" = "Classificação na carreira",
    "g.Modalidade" = "Modalidade",
    "h.Sit_Bach" = "Situação atual do bacharelado",
    "i.AnoConDes_Bach" = "Ano de Conclusão/Desligamento do bacharelado",
    "j.Sit_lic" = "Situação atual da licenciatura",
    "k.AnoConDes_Lic" = "Ano de Conclusão/Desligamentoda licenciatura",
    "l.Sexo" = "Sexo",
    "m.Raca_cor" = "Raça ou cor",
    "n.PPI" = "nPPI",
    "o.Reigressos" = "Número de reingressos",
    "r13" = "Resposta Item 13 (Estado civil)",
    "r14" = "Resposta Item 14",
    "r15" = "Resposta Item 15",
    "r16" = "Resposta Item 16",
    "r17" = "Resposta Item 17",
    "r18" = "Resposta Item 18",
    "r19" = "Resposta Item 19",
    "r20" = "Resposta Item 20",
    "r21" = "Resposta Item 21",
    "r22" = "Resposta Item 22",
    "r23" = "Resposta Item 23",
    "r24" = "Resposta Item 24",
    "r25" = "Idade no ano da prova do vestibular",
    "r26" = "Resposta Item 26")

# Renomeando as colunas com o dicionário de renomeação
#SIC_BD.Est_FFLCH <- SIC_BD.Est_FFLCH %>%
#  rename_with(~dicionario_renomeacao[.], everything())




# Renomeando e Reordenando colunas  --------------------------------------------------------

library(dplyr)

SIC_BD.Est_FFLCH <- SIC_BD.Est_FFLCH %>%
  rename(a.Unidade = Unidade)
SIC_BD.Est_FFLCH <- SIC_BD.Est_FFLCH %>%
  rename(b.CursoIngresso = 'Curso de ingresso', 
          c.AnoIngresso = 'Ano de Ingresso',
          d.PeriodoIngresso = 'Período de Ingresso',
          e.ModoIngresso = "Modo de Ingresso",
         f.ClassCarreira = "Classificação na carreira",
         g.Modalidade = "Modalidade",
         h.Sit_Bach = "Situação atual do bacharelado",
         i.AnoConDes_Bach = "Ano de Conclusão/Desligamento do bacharelado",
         j.Sit_lic = "Situação atual da licenciatura",
         k.AnoConDes_Lic = "Ano de Conclusão/Desligamentoda licenciatura",
         l.Sexo = "Sexo",
         "m.Raca_cor" = "Raça ou cor",
         "n.PPI" = "nPPI",
         "o.Reigressos" = "Número de reingressos",
         "r13" = "Resposta Item 13 (Estado civil)",
         "r14" = "Resposta Item 14",
         "r15" = "Resposta Item 15",
         "r16" = "Resposta Item 16",
         "r17" = "Resposta Item 17",
         "r18" = "Resposta Item 18",
         "r19" = "Resposta Item 19",
         "r20" = "Resposta Item 20",
         "r21" = "Resposta Item 21",
         "r22" = "Resposta Item 22",
         "r23" = "Resposta Item 23",
         "r24" = "Resposta Item 24",
         "r25" = "Idade no ano da prova do vestibular",
         "r26" = "Resposta Item 26"
  )


# Trocando a ordem das colunas 
SIC_BD.Est_FFLCH <- SIC_BD.Est_FFLCH %>%
  select(Identificador,
         a.Unidade,
         b.CursoIngresso,
         c.AnoIngresso,
         d.PeriodoIngresso,
         e.ModoIngresso,
         f.ClassCarreira,
         g.Modalidade,
         h.Sit_Bach,
         i.AnoConDes_Bach,
         j.Sit_lic,
         k.AnoConDes_Lic,
         l.Sexo,
         m.Raca_cor,
         n.PPI,
         o.Reigressos,
         r13,
         r14,
         r15,
         r16,
         r17,
         r18,
         r19,
         r20,
         r21,
         r22,
         r23,
         r24,
         r25,
         r26,)

# Criando tratamentos para as Situações dos cursos


# Agrupar categorias de jubilamento ou não  --------------------------------------------------------

# Função para tratar os valores da coluna "h.Sit_Bach"
tratar_situacao <- function(x) {
  case_when(
    is.na(x) | x == "" ~ "Cursando",
    grepl("Abandono", x) ~ "Desligado",
    grepl("Cancelamento", x) ~ "Desligado",
    grepl("Desistência", x) ~ "Desligado",
    grepl("Encerramento", x) ~ "Desligado",
    grepl("sem Frequência", x) ~ "Desligado",
    grepl("Não cump", x) ~ "Desligado",
    grepl("Não cursa", x) ~ "Não Abriu",
    grepl("Transferência", x) ~ "Transferência",
    grepl("Conclusão", x) ~ "Formado",
    TRUE ~ "Outro"
  )
}

# Aplicando a função de tratamento na coluna "h.Sit_Bach" e criando a nova coluna "h1.Sit_Bach_Trat"
SIC_BD.Est_FFLCH <- SIC_BD.Est_FFLCH %>%
  mutate(h1.Sit_Bach_Trat = tratar_situacao(h.Sit_Bach))

# AGORA LICENCIATURA

# Função para tratar os valores da coluna "j.Sit_lic"
tratar_situacao <- function(x) {
  case_when(
    is.na(x) | x == "" ~ "Cursando",
    grepl("Abandono", x) ~ "Desligado",
    grepl("Cancelamento", x) ~ "Desligado",
    grepl("Desistência", x) ~ "Desligado",
    grepl("Encerramento", x) ~ "Desligado",
    grepl("sem Frequência", x) ~ "Desligado",
    grepl("Não cump", x) ~ "Desligado",
    grepl("Não cursa", x) ~ "Não Abriu",
    grepl("Transferência", x) ~ "Transferência",
    grepl("Conclusão", x) ~ "Formado",
    TRUE ~ "Outro"
  )
}


# Aplicando a função de tratamento na coluna "h.Sit_Lic" e criando a nova coluna "h1.Sit_Lic_Trat"
SIC_BD.Est_FFLCH <- SIC_BD.Est_FFLCH %>%
  mutate(j1.Sit_lic_Trat = tratar_situacao(j.Sit_lic))

# Trocando a ordem das colunas inserindo as novas colunas tratadas no meio
SIC_BD.Est_FFLCH <- SIC_BD.Est_FFLCH %>%
  select(Identificador,
         a.Unidade,
         b.CursoIngresso,
         c.AnoIngresso,
         d.PeriodoIngresso,
         e.ModoIngresso,
         f.ClassCarreira,
         g.Modalidade,
         h.Sit_Bach,
         h1.Sit_Bach_Trat,
         i.AnoConDes_Bach,
         j.Sit_lic,
         j1.Sit_lic_Trat,
         k.AnoConDes_Lic,
         l.Sexo,
         m.Raca_cor,
         n.PPI,
         o.Reigressos,
         r13,
         r14,
         r15,
         r16,
         r17,
         r18,
         r19,
         r20,
         r21,
         r22,
         r23,
         r24,
         r25,
         r26,)

# Importei a Base de ICs  --------------------------------------------------------

library(readr)
write.csv(SIC_BD.Est_FFLCH, file = "file:///users/Mancano/Downloads/SIC_BD.Est_FFLCH", row.names = FALSE)
write.csv(SIC_BD_IC_USP, file = "file:///users/Mancano/Downloads/SIC_BD.Est_FFLCH", row.names = FALSE)

SIC_BD_IC_USP_SE <- SIC_BD_IC_USP %>%
  
  
  #filter(!grepl("Aluno Externo", p.AlunoUSP.Ext))
  
  library(dplyr)

# Supondo que "SIC_BD_IC_USP" seja o nome da tabela original
# Criar a nova tabela "SIC_BD_IC_USP_SE" excluindo as linhas que contenham "Aluno Externo" na coluna "p.AlunoUSP/Ext"
SIC_BD_IC_USP_SE <- SIC_BD_IC_USP %>%
  filter(!grepl("Aluno Externo", p.AlunoUSP.Ext))

SIC_BD_IC_USP_SE <- SIC_BD_IC_USP

filter(!grepl("Aluno Externo", 'p.AlunoUSP/Ext'))

SIC_BD_IC_USP_SE <- SIC_BD_IC_USP_SE %>%
  filter(!grepl("Aluno Externo", `p.AlunoUSP/Ext`))

library(dplyr)

# Supondo que "SIC_BD_IC_USP_SE" seja o nome da base de dados e "p.AlunoUSP/Ext" a coluna
# Excluir as linhas que contêm "Aluno Externo" na coluna "p.AlunoUSP/Ext"
SIC_BD_IC_USP_SE <- SIC_BD_IC_USP_SE %>%
  filter(!grepl("Aluno Externo", `p.AlunoUSP/Ext`, ignore.case = TRUE))

library(readr)
write.csv(SIC_BD_IC_USP_SE, file = "file:///users/Mancano/Downloads/SIC_BD_IC_USP_SE.csv", row.names = FALSE)

library(dplyr)
SIC_BD_IC_USP_SE <- SIC_BD_IC_USP_SE %>%
  filter(grepl("Faculdade de Filosofia, Letras e Ciências Humanas", `a.Unidade`, ignore.case = TRUE))

write.csv(SIC_BD_IC_USP_SE, file = "file:///users/Mancano/Downloads/SIC_BD_IC_USP_SE.csv", row.names = FALSE)

decis <- quantile(BD, probs = seq(0.1, 1, 0.1))
print(decis)

decis <- lapply(BD, function(x) quantile(x, probs = seq(0.1, 1, 0.1)))
decis_df <- as.data.frame(do.call(cbind, decis))

print(decis_df)

# Maiores IES Públicas do Brasil


soma_total <- sum(indicadores_trajetoria_educacao_superior_2010_2019 $QT_INGRESSANTE)
print(soma_total)


# Obter os valores únicos da coluna CO_CURSO
valores_unicos <- unique(indicadores_trajetoria_educacao_superior_2010_2019$CO_CURSO)

# Contar o número de valores únicos
contagem_unica <- length(valores_unicos)

# Imprimir o resultado
cat("Número único de cursos:", contagem_unica, "\n")

# Carregar o dataset
indicadores_trajetoria_educacao_superior_2010_2019 <- read.csv('seu_dataset.csv')

# Calcular a soma total de QT_INGRESSANTE para cada CO_CURSO único
soma_total_por_curso <- aggregate(QT_INGRESSANTE ~ CO_CURSO, data = indicadores_trajetoria_educacao_superior_2010_2019, sum)

# Imprimir o resultado
print(soma_total_por_curso)

# Calcular a soma total de QT_INGRESSANTE para cada CO_CURSO único
total_por_curso <- aggregate(QT_INGRESSANTE ~ CO_CURSO, data = indicadores_trajetoria_educacao_superior_2010_2019, sum)

# Calcular a soma total de QT_INGRESSANTE em todo o dataset
total_global <- sum(total_por_curso$QT_INGRESSANTE)

# Imprimir o resultado
print(total_global)


_____

soma_por_curso <- aggregate(QT_INGRESSANTE ~ CO_CURSO, data = indicadores_trajetoria_educacao_superior_2010_2019, sum)

# Calcular o número de repetições de cada CO_CURSO
repeticoes <- table(indicadores_trajetoria_educacao_superior_2010_2019$CO_CURSO)

# Adicionar uma coluna com a quantidade de repetições para cada CO_CURSO
soma_por_curso$QT_REPETIDO <- repeticoes[match(soma_por_curso$CO_CURSO, names(repeticoes))]

# Calcular a soma total de QT_INGRESSANTE para cada CO_CURSO dividido pelo número de repetições
soma_por_curso$QT_MEDIO <- soma_por_curso$QT_INGRESSANTE / soma_por_curso$QT_REPETIDO

# Calcular a soma total dos valores médios
resultado_final <- sum(soma_por_curso$QT_MEDIO)

# Imprimir o resultado final
print




# Calcular a soma total de QT_INGRESSANTE para cada CO_CURSO único
soma_total_por_curso <- aggregate(QT_INGRESSANTE ~ CO_CURSO, data = ifes_2010_2019, sum)

# Imprimir o resultado
print(soma_total_por_curso)

# Calcular a soma total de QT_INGRESSANTE para cada CO_CURSO único
total_por_curso <- aggregate(QT_INGRESSANTE ~ CO_CURSO, data = ifes_2010_2019, sum)

# Calcular a soma total de QT_INGRESSANTE em todo o dataset
total_global <- sum(total_por_curso$QT_INGRESSANTE)

# Imprimir o resultado
print(total_global)


##### Teste final


# Calcular a soma de QT_INGRESSANTE para cada CO_CURSO único
soma_por_curso <- aggregate(QT_INGRESSANTE ~ CO_CURSO, data = ifes_2014_2021, sum)

# Calcular o número de repetições de cada CO_CURSO
repeticoes <- table(ifes_2014_2021$CO_CURSO)

# Adicionar uma coluna com a quantidade de repetições para cada CO_CURSO
soma_por_curso$QT_REPETIDO <- repeticoes[match(soma_por_curso$CO_CURSO, names(repeticoes))]

# Calcular a soma total de QT_INGRESSANTE para cada CO_CURSO dividido pelo número de repetições
soma_por_curso$QT_MEDIO <- soma_por_curso$QT_INGRESSANTE / soma_por_curso$QT_REPETIDO

# Calcular a soma total dos valores médios
resultado_final <- sum(soma_por_curso$QT_MEDIO)

# Imprimir o resultado final
print(resultado_final)

Total_das_coortes <- sum(2573449, 2574755, 2899439, 2935860, 3177422)
print(Total_das_coortes)

ocorrencias <- table(ifes_2010_2019$NU_ANO_INTEGRALIZAÇÃO)

# Imprimir o resultado
print(ocorrencias)


curso_ies_filtrado <- subset(ifes_2014_2021, NO_CURSO == "CIÊNCIAS SOCIAIS" & NO_IES == "UNIVERSIDADE DE SÃO PAULO")

# Imprimir o resultado
print(curso_ies_filtrado)

write.csv(curso_ciencias_sociais, file = "file:///users/Mancano/Downloads/curso_ciencias_sociais.csv", row.names = FALSE)




SIC_BD_IC_USP_SE <- SIC_BD_IC_USP_SE %>%
  filter(!grepl("Aluno Externo", `p.AlunoUSP/Ext`, ignore.case = TRUE))

library(readr)
write.csv(SIC_BD_IC_USP_SE, file = "file:///users/Mancano/Downloads/SIC_BD_IC_USP_SE.csv", row.names = FALSE)

library(dplyr)
SIC_BD_IC_USP_SE <- SIC_BD_IC_USP_SE %>%
  filter(grepl("Faculdade de Filosofia, Letras e Ciências Humanas", `a.Unidade`, ignore.case = TRUE))

write.csv(SIC_BD_IC_USP_SE, file = "file:///users/Mancano/Downloads/SIC_BD_IC_USP_SE.csv", row.names = FALSE)

decis <- quantile(BD, probs = seq(0.1, 1, 0.1))
print(decis)

decis <- lapply(BD, function(x) quantile(x, probs = seq(0.1, 1, 0.1)))
decis_df <- as.data.frame(do.call(cbind, decis))

print(decis_df)

# Maiores IES Públicas do Brasil



