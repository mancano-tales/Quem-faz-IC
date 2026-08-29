# Authors: Tales Mançano & Victor Alcantara

# 1. Import and tidy e Criando o novo DataFrame filtrado IC nas Ciências Sociais -----------------------------------------------------------

library(pacman)
p_load(tidyverse,rio,arrow)

# Clean memory
rm(list=ls())
gc()

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Criando o novo DataFrame filtrado IC nas Ciências Sociais
ic_ciencias_sociais_usp <- ic_usp %>%
  filter(curso == "Ciências Sociais" & ano >= 2010 & ano <= 2019)

# 2. Tratando a Renda das pessoas na base de dados de Renda -----------------------------------------------------------

head(ic_ciencias_sociais_usp)

table(ic_ciencias_sociais_usp$rfm)

ic_ciencias_sociais_usp <- ic_ciencias_sociais_usp %>% mutate(.,
                            smf = case_when(
                              
                              rfm %in% c("Até 1 SM - até R$ 1.045,00",
                                         "Até 1 SM - até R$ 1.100,00",
                                         "Até 1 SM - até R$ 1.212,00",
                                         "Inferior a 1 SM.") ~ .5,
                              
                              rfm %in% c("Acima de 1 até 2 SM - de R$ 1.045,01 até R$ 2.090,00",
                                         "Acima de 1 até 2 SM - de R$ 1.100,01 até R$ 2.200,00",
                                         "Acima de 1 até 2 SM - de R$ 1.212,01 até R$ 2.424,00",
                                         "De 1 a 1,9 SM.") ~ 1.5,
                              
                              rfm %in% c("Acima de 2 até 3 SM - de R$ 2.090,01 até R$ 3.135,00",
                                         "Acima de 2 até 3 SM - de R$ 2.200,01 até R$ 3.300,00",
                                         "Acima de 2 até 3 SM - de R$ 2.424,01 até R$ 3.636,00",
                                         "De 2 a 2,9 SM.") ~ 2.5,
                              
                              rfm %in% c("Acima de 3 até 5 SM - de R$ 3.135,01 até R$ 5.225,00",
                                         "Acima de 3 até 5 SM - de R$ 3.300,01 até R$ 5.500,00",
                                         "Acima de 3 até 5 SM - de R$ 3.636,01 até R$ 6.060,00",
                                         "De 3 a 4,9 SM.") ~ 3.5,
                              
                              rfm %in% c("Acima de 5 até 7 SM - de R$ 5.225,01 até R$ 7.315,00", 
                                         "Acima de 5 até 7 SM - de R$ 5.500,01 até R$ 7.700,00", 
                                         "Acima de 5 até 7 SM - de R$ 6.060,01 até R$ 8.484,00",
                                         "De 5 a 6,9 SM.") ~ 6,
                              
                              rfm %in% c("Acima de 7 até 10 SM - de R$ 7.315,01 até R$ 10.450,00", 
                                         "Acima de 7 até 10 SM - de R$ 7.700,01 até R$ 11.000,00", 
                                         "Acima de 7 até 10 SM - de R$ 8.484,01 até R$ 12.120,00",
                                         "De 7 a 9,9 SM.") ~ 8.5,
                              
                              rfm %in% c("Acima de 10 até 15 SM - de R$ 10.450,01 até R$ 15.675,00", 
                                         "Acima de 10 até 15 SM - de R$ 11.000,01 até R$ 16.500,00", 
                                         "Acima de 10 até 15 SM - de R$ 12.120,01 até R$ 18.180,00",
                                         "Acima de 15 até 20 SM - de R$ 15.675,01 até R$ 20.900,00", 
                                         "Acima de 15 até 20 SM - de R$ 16.500,01 até R$ 22.000,00", 
                                         "Acima de 15 até 20 SM - de R$ 18.180,01 até R$ 24.240,00", 
                                         "De 10 a 14,9 SM.","De 10 a 13,9 SM.",
                                         "De 14 a 19,9 SM.","De 15 a 19,9 SM.") ~ 15,
                              
                              rfm %in% c("Acima de 20 SM até 30 SM - de R$ 20.900,01 até R$ 31.350,00", 
                                         "Acima de 20 SM até 30 SM - de R$ 22.000,01 até R$ 33.000,00", 
                                         "Acima de 20 SM até 30 SM - de R$ 24.240,01 até R$ 36.360,00",
                                         "Acima de 30 SM até 50 SM - de R$ 31.350,01 até R$ 52.250,00", 
                                         "Acima de 30 SM até 50 SM - de R$ 33.000,01 até R$ 55.000,00", 
                                         "Acima de 30 SM até 50 SM - de R$ 36.360,01 até R$ 60.600,00",
                                         "Acima de 50 SM - superior a R$ 52.250,00", 
                                         "Acima de 50 SM - superior a R$ 55.000,00", 
                                         "Acima de 50 SM - superior a R$ 60.600,00", 
                                         "Igual ou superior a 20 SM.") ~ 25,
                              
                            ),
                            
                            qtd_pessoas = case_when(
                              pessoas_resid == "Uma" ~ 1,
                              pessoas_resid == "Duas" ~ 2,
                              pessoas_resid == "Três" ~ 3,
                              pessoas_resid == "Quatro" ~ 4,
                              pessoas_resid == "Cinco" ~ 5,
                              pessoas_resid %in% c("Seis","Seis ou mais","Sete","Oito ou mais") ~ 6,
                            )
) %>% mutate(.,
             sfmpct = smf/qtd_pessoas
)

hist(ic_ciencias_sociais_usp$sfmpct)

table(ic_ciencias_sociais_usp$ano,ic_ciencias_sociais_usp$unidade)

colnames(ic_ciencias_sociais_usp)

# 3. Criando novas variáveis binárias para cotistas na base -----------------------------------------------------------

# Criando a coluna binária para cotista
ic_ciencias_sociais_usp <- ic_ciencias_sociais_usp %>%
  mutate(cotista_bin = ifelse(modalidade %in% c("EP", "PPI"), 1, 0))

# Atribuindo Ampla concorrência para valores missing de modalidade (antes das cotas)
ic_ciencias_sociais_usp <- ic_ciencias_sociais_usp %>%
  mutate(modalidade = case_when(
    modo_ingresso == "Vestibular" & (is.na(modalidade) | modalidade == "") ~ "AC",
    TRUE ~ modalidade
  ))


# 4. Padronizando e Simplificando Status no curso (Evasão e Conclusão) -----------------------------------------------------------
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

# Aplicar a função e criar a nova coluna no dataframe
ic_ciencias_sociais_usp <- ic_ciencias_sociais_usp %>%
  mutate(situ_bach_consolidado = tratar_situacao(situ_bacharel))

ic_ciencias_sociais_usp <- ic_ciencias_sociais_usp %>%
  mutate(situ_bach_bin = case_when(
    situ_bach_consolidado == "Formado" ~ 1,
    situ_bach_consolidado == "Desligado" ~ 0,
    situ_bach_consolidado == "Cursando" ~ NA_real_,
    TRUE ~ NA_real_
  ))

# 5. Binarizando Raça -----------------------------------------------------------

# Vendo quais são as categorias raciais do dataset
unique_values <- unique(ic_ciencias_sociais_usp$raca)
print(unique_values)

# Criar a nova coluna 'ppi_bin'
ic_ciencias_sociais_usp <- ic_ciencias_sociais_usp %>%
  mutate(ppi_bin = case_when(
    raca %in% c("Parda", "Preta / negra", "Indígena") ~ 1,
    raca %in% c("Branca", "Amarela") ~ 0,
    raca %in% c("Não informada", "Sem informação") ~ NA_integer_,
    TRUE ~ NA_integer_  # Para garantir que todos os casos sejam cobertos
  ))

ic_ciencias_sociais_usp <- ic_ciencias_sociais_usp %>%
  mutate(raca_categoria = case_when(
    raca %in% c("Branca") ~ "Brancos",
    raca %in% c("Amarela") ~ "Amarelos",
    raca %in% c("Preta / negra") ~ "Pretos",
    raca %in% c("Parda") ~ "Pardos",
    raca %in% c("Indígena") ~ "Indígenas",
    raca %in% c("Não informada", "Sem informação") ~ NA_character_,
    TRUE ~ NA_character_  # Para garantir que todos os casos sejam cobertos
  ))

unique_values <- unique(ic_ciencias_sociais_usp$raca)
print(unique_values)

# 6. Binarizando Escola de Ensino Médio -----------------------------------------------------------

percentages <- ic_ciencias_sociais_usp %>%
  count(ef2) %>%
  mutate(percent = n / sum(n) * 100)
print(percentages)

ic_ciencias_sociais_usp <- ic_ciencias_sociais_usp %>%
  mutate(em_bin = case_when(
    ef2 %in% c("Todo em escola pública", "Só em escola pública estadual", "Só em escola pública municipal", "Maior parte em escola pública") ~ 0,
    ef2 %in% c("Todo em escola particular", "Maior parte em escola particular", "No exterior", "Em outra situação") ~ 1,
    ef2 == "Sem informação" ~ NA_real_,
    is.na(ef2) ~ NA_real_,
    TRUE ~ NA_real_
  ))

percentages <- ic_ciencias_sociais_usp %>%
  count(educ_resp1) %>%
  mutate(percent = n / sum(n) * 100)
print(percentages)

# Criação da nova coluna 'educ_resp_tri' simplificada
ic_ciencias_sociais_usp$educ_resp_tri <- dplyr::case_when(
  ic_ciencias_sociais_usp$educ_resp1 %in% c("Ensino fundamental completo", 
                                             "Ensino fundamental incompleto", 
                                             "Iniciou o Ensino Fundamental, mas abandonou entre a 1ª e a 4ª",
                                             "Iniciou o Ensino Fundamental, mas abandonou entre a 5ª e a 8ª", 
                                             "Não estudou") ~ "Até fundamental completo",
  
  ic_ciencias_sociais_usp$educ_resp1 %in% c("Ensino médio completo", 
                                             "Ensino médio incompleto","Ensino superior completo", 
                                            "Ensino superior incompleto") ~ "Até fundamental completo",
  
  ic_ciencias_sociais_usp$educ_resp1 %in% c( "Mestrado ou doutorado", 
                                             "Pós-Graduação completa", 
                                             "Pós-Graduação incompleta") ~ "Ensino superior e/ou pós-graduação",
  
  is.na(ic_ciencias_sociais_usp$educ_resp1) | ic_ciencias_sociais_usp$educ_resp1 == "Não possuo responsável" ~ NA_character_,
  
  TRUE ~ ic_ciencias_sociais_usp$educ_resp1  # Mantém categorias não especificadas
)

# Verificando a distribuição das categorias na nova coluna
table(ic_ciencias_sociais_usp$educ_resp_tri, useNA = "ifany")

percentages <- ic_ciencias_sociais_usp %>%
  count(educ_resp_tri) %>%
  mutate(percent = n / sum(n) * 100)
print(percentages)# 

# 7. Tratando a atividade remunerada -----------------------------------------------------------

percentages <- ic_ciencias_sociais_usp %>%
  count(atv_remu) %>%
  mutate(percent = n / sum(n) * 100)
print(percentages)

# Criando a nova coluna work_horas
ic_ciencias_sociais_usp <- ic_ciencias_sociais_usp %>%
  mutate(work_horas = case_when(
    atv_remu == "Não" ~ 0,
    atv_remu == "Sim, eventualmente" ~ 10,
    atv_remu == "Sim, em meio período (até 20 horas semanais)" ~ 20,
    atv_remu == "Sim, regularmente, em tempo parcial" ~ 20,
    atv_remu == "Sim, em tempo semi-integral (de 21 a 32 horas semanais)" ~ 30,
    atv_remu == "Sim, regularmente, em tempo integral" ~ 40,
    TRUE ~ NA_real_  # Para lidar com valores não especificados
  ))

# Criando a nova coluna work_bin
ic_ciencias_sociais_usp <- ic_ciencias_sociais_usp %>%
  mutate(work_bin = case_when(
    atv_remu == "Não" ~ 0,
    atv_remu == "Sim, eventualmente" ~ 1,
    atv_remu == "Sim, em meio período (até 20 horas semanais)" ~ 1,
    atv_remu == "Sim, regularmente, em tempo parcial" ~ 1,
    atv_remu == "Sim, em tempo semi-integral (de 21 a 32 horas semanais)" ~ 1,
    atv_remu == "Sim, regularmente, em tempo integral" ~ 1,
    TRUE ~ NA_real_  # Para lidar com valores não especificados
  ))

# Exibir os valores únicos de 'atv_remu' para cada valor de 'work_bin' (isso é só pra testar se o código de cima deu certo e ele atesta que sim)
unique_values <- ic_ciencias_sociais_usp %>%
  group_by(work_bin) %>%
  summarise(atv_remu_values = list(unique(atv_remu)))
table(ic_ciencias_sociais_usp$work_bin, ic_ciencias_sociais_usp$atv_remu)

percentages <- ic_ciencias_sociais_usp %>%
  count(work_bin) %>%
  mutate(percent = n / sum(n) * 100)
print(percentages)

# 8. Tratando as ICs -----------------------------------------------------------

percentages <- ic_ciencias_sociais_usp %>%
  count(qtd_ic) %>%
  mutate(percent = n / sum(n) * 100)
print(percentages)
ic_ciencias_sociais_usp <- ic_ciencias_sociais_usp %>%
  mutate(ic_bin = ifelse(qtd_ic >= 1, 1, 0))
ic_ciencias_sociais_usp <- ic_ciencias_sociais_usp %>%
  mutate(ic_bin = ifelse(is.na(ic_bin), 0, ic_bin))

# Exibir os valores únicos de 'atv_remu' para cada valor de 'work_bin'
table(ic_ciencias_sociais_usp$ic_bin, ic_ciencias_sociais_usp$qtd_ic)

# 9. Que comecem as Regressões -----------------------------------------------------------

colnames(ic_ciencias_sociais_usp)

# Generalized Linear Models (GLM): função para regressão logística

colnames(ic_ciencias_sociais_usp)

# Regressão para fazer IC
reg <- glm(formula = ic_bin ~ periodo + sexo + ppi_bin + sfmpct + + idade_ano_vest + em_bin + work_bin,
           data = ic_ciencias_sociais_usp, 
           family = "binomial")
summary(reg)

odds_ratios <- exp(coef(reg))
print(odds_ratios)

# Regressão para fazer Trabalhar
reg <- glm(formula = work_bin ~ periodo + sexo + sfmpct + em_bin + ppi_bin + cotista_bin ,
           data = ic_ciencias_sociais_usp, 
           family = "binomial")
summary(reg)
print(nobs(reg))
print(exp(coef(reg)))

# Regressão para Evasão
reg <- glm(formula = situ_bach_bin ~ periodo + sexo + sfmpct + em_bin  + ppi_bin + cotista_bin + ic_bin,
           data = ic_ciencias_sociais_usp, 
           family = "binomial")
summary(reg)
print(nobs(reg))
print(exp(coef(reg)))

# Regressão para fazer IC modelo focado em raça e socioeconmico
reg <- glm(formula = ic_bin ~ sfmpct + em_bin  + ppi_bin + cotista_bin,
           data = ic_ciencias_sociais_usp, 
           family = "binomial")
summary(reg)
print(nobs(reg))
print(exp(coef(reg)))

# Regressão para testar a classificação na carreira

# Filtrar a base de dados
ic_ciencias_sociais_usp_vestibular_ac <- ic_ciencias_sociais_usp %>%
  filter(modo_ingresso == "Vestibular" & modalidade == "AC")

ic_ciencias_sociais_usp_vestibular_ac_formado <- ic_ciencias_sociais_usp_vestibular_ac %>%
  filter(situ_bach_bin == "1")

# Realizar a regressão logística
reg <- glm(ic_bin ~ class_carreira + class_carreira + periodo + sexo + sfmpct + em_bin  + ppi_bin, 
           family = "binomial", 
           data = ic_ciencias_sociais_usp_vestibular_ac)
summary(reg)
print(nobs(reg))
print(exp(coef(reg)))

# Realizar a regressão logística
reg <- glm(situ_bach_bin ~ class_carreira + periodo + sexo + sfmpct + work_bin, 
           family = "binomial", 
           data = ic_ciencias_sociais_usp_vestibular_ac)
summary(reg)
print(nobs(reg))
print(exp(coef(reg)))

# Realizar a regressão logística
reg <- glm(ic_bin ~ class_carreira + periodo + sfmpct + work_bin + situ_bach_bin + em_bin  + ppi_bin, 
           family = "binomial", 
           data = ic_ciencias_sociais_usp_vestibular_ac)
summary(reg)
print(nobs(reg))
print(exp(coef(reg)))


# Regressão apenas com formados

reg <- glm(ic_bin ~ class_carreira + periodo + sfmpct + work_bin + em_bin  + ppi_bin, 
           family = "binomial", 
           data = ic_ciencias_sociais_usp_vestibular_ac_formado)
summary(reg)
odds_ratios <- exp(coef(reg))
print(odds_ratios)


# 10. Estatísticas Descritivas -----------------------------------------------------------

# Crie uma tabela cruzada usando table()
cross_tab <- table(ic_ciencias_sociais_usp$ic_bin, ic_ciencias_sociais_usp$Situ_bach_bin)

# Exibir a tabela cruzada
print(cross_tab)

# Calcule as proporções para cada combinação
prop_tab <- prop.table(cross_tab, margin = 2)

# Exibir a tabela de proporções
print(prop_tab)

# Se preferir, use summary statistics com dplyr
summary_stats <- ic_ciencias_sociais_usp %>%
  group_by(ic_bin, Situ_bach_bin) %>%
  summarise(
    count = n(),
    mean = mean(ic_bin, na.rm = TRUE),
    sd = sd(ic_bin, na.rm = TRUE)
  )

# Exibir as estatísticas descritivas
print(summary_stats)


# 11. Exportando o dataframe ic_ciencias_sociais_usp para um arquivo CSV -----------------------------------------------------------
 
write.csv(ic_ciencias_sociais_usp, file = "/Downloads/ic_ciencias_sociais_usp.csv", row.names = FALSE)

# Remover o dataframe da memória
rm(ic_ciencias_sociais_usp)

# Limpar a memória
gc()
