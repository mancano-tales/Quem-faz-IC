# Authors: Tales Mançano & Victor Alcantara

# 1. Import and tidy e Criando o novo DataFrame filtrado IC nas Ciências Sociais -----------------------------------------------------------

library(pacman)
p_load(tidyverse,rio,arrow)

# Clean memory
rm(list=ls())
gc()

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Criando o novo DataFrame filtrado IC nas Ciências Sociais
ic_fflch_usp <- ic_usp %>%
  filter(unidade == "Faculdade de Filosofia, Letras e Ciências Humanas" & ano >= 2009 & ano <= 2018)

# 2. Tratando a Renda das pessoas na base de dados de Renda -----------------------------------------------------------

head(ic_fflch_usp)

table(ic_fflch_usp$rfm)

ic_fflch_usp <- ic_fflch_usp %>% mutate(.,
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

hist(ic_fflch_usp$sfmpct)

table(ic_fflch_usp$ano,ic_fflch_usp$unidade)

colnames(ic_fflch_usp)

# 3. Criando novas variáveis binárias para cotistas na base -----------------------------------------------------------

# Criando a coluna binária para cotista
ic_fflch_usp <- ic_fflch_usp %>%
  mutate(cotista_bin = ifelse(modalidade %in% c("EP", "PPI"), 1, 0))

colnames(ic_fflch_usp)

# Atribuindo Ampla concorrência para valores missing de modalidade (antes das cotas)
ic_fflch_usp <- ic_fflch_usp %>%
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
ic_fflch_usp <- ic_fflch_usp %>%
  mutate(situ_bach_consolidado = tratar_situacao(situ_bacharel))

ic_fflch_usp <- ic_fflch_usp %>%
  mutate(situ_bach_bin = case_when(
    situ_bach_consolidado == "Formado" ~ 1,
    situ_bach_consolidado == "Desligado" ~ 0,
    situ_bach_consolidado == "Cursando" ~ NA_real_,
    TRUE ~ NA_real_
  ))

colnames(ic_fflch_usp)

# 5. Binarizando Raça -----------------------------------------------------------

# Vendo quais são as categorias raciais do dataset
unique_values <- unique(ic_fflch_usp$raca)
print(unique_values)

colnames(ic_fflch_usp)

# Criar a nova coluna 'ppi_bin'
ic_fflch_usp <- ic_fflch_usp %>%
  mutate(ppi_bin = case_when(
    raca %in% c("Parda", "Preta / negra", "Indígena") ~ 1,
    raca %in% c("Branca", "Amarela") ~ 0,
    raca %in% c("Não informada", "Sem informação") ~ NA_integer_,
    TRUE ~ NA_integer_  # Para garantir que todos os casos sejam cobertos
  ))

colnames(ic_fflch_usp)

ic_fflch_usp <- ic_fflch_usp %>%
  mutate(raca_categoria = case_when(
    raca %in% c("Branca") ~ "Brancos",
    raca %in% c("Amarela") ~ "Amarelos",
    raca %in% c("Preta / negra") ~ "Pretos",
    raca %in% c("Parda") ~ "Pardos",
    raca %in% c("Indígena") ~ "Indígenas",
    raca %in% c("Não informada", "Sem informação") ~ NA_character_,
    TRUE ~ NA_character_  # Para garantir que todos os casos sejam cobertos
  ))

colnames(ic_fflch_usp)

unique_values <- unique(ic_fflch_usp$ppi_bin)
print(unique_values)

unique_values <- unique(ic_fflch_usp$raca_categoria)
print(unique_values)

# 6. Binarizando Escola de Ensino Médio -----------------------------------------------------------

percentages <- ic_fflch_usp %>%
  count(ef2) %>%
  mutate(percent = n / sum(n) * 100)
print(percentages)

ic_fflch_usp <- ic_fflch_usp %>%
  mutate(em_bin = case_when(
    ef2 %in% c("Todo em escola pública", "Só em escola pública estadual", "Só em escola pública municipal", "Maior parte em escola pública") ~ 0,
    ef2 %in% c("Todo em escola particular", "Maior parte em escola particular", "No exterior", "Em outra situação") ~ 1,
    ef2 == "Sem informação" ~ NA_real_,
    is.na(ef2) ~ NA_real_,
    TRUE ~ NA_real_
  ))

percentages <- ic_fflch_usp %>%
  count(educ_resp1) %>%
  mutate(percent = n / sum(n) * 100)
print(percentages)

ic_fflch_usp <- ic_fflch_usp %>%
  mutate(turno_bin = case_when(
    periodo %in% c("diurno", "integral", "vespertino", "matutino") ~ 0,
    periodo %in% c("noturno", "Maior parte em escola particular", "No exterior", "Em outra situação") ~ 1,
    periodo == "Sem informação" ~ NA_real_,
    is.na(periodo) ~ NA_real_,
    TRUE ~ NA_real_
  ))

# Criação da nova coluna 'educ_resp_tri' simplificada
ic_fflch_usp$educ_resp_tri <- dplyr::case_when(
  ic_fflch_usp$educ_resp1 %in% c("Ensino fundamental completo", 
                                             "Ensino fundamental incompleto", 
                                             "Iniciou o Ensino Fundamental, mas abandonou entre a 1ª e a 4ª",
                                             "Iniciou o Ensino Fundamental, mas abandonou entre a 5ª e a 8ª", 
                                             "Não estudou") ~ "Até fundamental completo",
  
  ic_fflch_usp$educ_resp1 %in% c("Ensino médio completo", 
                                             "Ensino médio incompleto","Ensino superior completo", 
                                            "Ensino superior incompleto") ~ "Até fundamental completo",
  
  ic_fflch_usp$educ_resp1 %in% c( "Mestrado ou doutorado", 
                                             "Pós-Graduação completa", 
                                             "Pós-Graduação incompleta") ~ "Ensino superior e/ou pós-graduação",
  
  is.na(ic_fflch_usp$educ_resp1) | ic_fflch_usp$educ_resp1 == "Não possuo responsável" ~ NA_character_,
  
  TRUE ~ ic_fflch_usp$educ_resp1  # Mantém categorias não especificadas
)

# Verificando a distribuição das categorias na nova coluna
table(ic_fflch_usp$educ_resp_tri, useNA = "ifany")

percentages <- ic_fflch_usp %>%
  count(educ_resp_tri) %>%
  mutate(percent = n / sum(n) * 100)
print(percentages)# 

# 7. Tratando a atividade remunerada -----------------------------------------------------------

percentages <- ic_fflch_usp %>%
  count(atv_remu) %>%
  mutate(percent = n / sum(n) * 100)
print(percentages)

# Criando a nova coluna work_horas
ic_fflch_usp <- ic_fflch_usp %>%
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
ic_fflch_usp <- ic_fflch_usp %>%
  mutate(work_bin = case_when(
    atv_remu == "Não" ~ 0,
    atv_remu == "Sim, eventualmente" ~ 1,
    atv_remu == "Sim, em meio período (até 20 horas semanais)" ~ 1,
    atv_remu == "Sim, regularmente, em tempo parcial" ~ 1,
    atv_remu == "Sim, em tempo semi-integral (de 21 a 32 horas semanais)" ~ 1,
    atv_remu == "Sim, regularmente, em tempo integral" ~ 1,
    TRUE ~ NA_real_  # Para lidar com valores não especificados
  ))

print(colnames(ic_fflch_usp))

# Exibir os valores únicos de 'atv_remu' para cada valor de 'work_bin' (isso é só pra testar se o código de cima deu certo e ele atesta que sim)
unique_values <- ic_fflch_usp %>%
  group_by(work_bin) %>%
  summarise(atv_remu_values = list(unique(atv_remu)))
table(ic_fflch_usp$work_bin, ic_fflch_usp$atv_remu)

percentages <- ic_fflch_usp %>%
  count(work_bin) %>%
  mutate(percent = n / sum(n) * 100)
print(percentages)

# 8. Tratando as ICs -----------------------------------------------------------

percentages <- ic_fflch_usp %>%
  count(qtd_ic) %>%
  mutate(percent = n / sum(n) * 100)
print(percentages)
ic_fflch_usp <- ic_fflch_usp %>%
  mutate(ic_bin = ifelse(qtd_ic >= 1, 1, 0))
ic_fflch_usp <- ic_fflch_usp %>%
  mutate(ic_bin = ifelse(is.na(ic_bin), 0, ic_bin))

# Exibir os valores únicos de 'atv_remu' para cada valor de 'work_bin'
table(ic_fflch_usp$ic_bin, ic_fflch_usp$qtd_ic)

# 9. Que comecem as Regressões -----------------------------------------------------------


# Generalized Linear Models (GLM): função para regressão logística

colnames(ic_fflch_usp)

# Regressão para fazer IC
reg <- glm(formula = ic_bin ~ periodo + sexo + ppi_bin + sfmpct + + idade_ano_vest + em_bin + work_bin,
           data = ic_fflch_usp, 
           family = "binomial")
summary(reg)

odds_ratios <- exp(coef(reg))
print(odds_ratios)

# Regressão para fazer Trabalhar
reg <- glm(formula = work_bin ~ periodo + sexo + sfmpct + em_bin + ppi_bin + cotista_bin ,
           data = ic_fflch_usp, 
           family = "binomial")
summary(reg)
print(nobs(reg))
print(exp(coef(reg)))

# Regressão para Evasão
reg <- glm(formula = situ_bach_bin ~ periodo + sexo + sfmpct + em_bin  + ppi_bin + cotista_bin + ic_bin,
           data = ic_fflch_usp, 
           family = "binomial")
summary(reg)
print(nobs(reg))
print(exp(coef(reg)))

# Regressão para fazer IC modelo focado em raça e socioeconmico
reg <- glm(formula = ic_bin ~ sfmpct + em_bin  + ppi_bin + cotista_bin,
           data = ic_fflch_usp, 
           family = "binomial")
summary(reg)
print(nobs(reg))
print(exp(coef(reg)))

# Regressão para testar a classificação na carreira

# Filtrar a base de dados
ic_ciencias_sociais_usp_vestibular_ac <- ic_fflch_usp %>%
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
cross_tab <- table(ic_fflch_usp$ic_bin, ic_fflch_usp$Situ_bach_bin)

# Exibir a tabela cruzada
print(cross_tab)

# Calcule as proporções para cada combinação
prop_tab <- prop.table(cross_tab, margin = 2)

# Exibir a tabela de proporções
print(prop_tab)

# Se preferir, use summary statistics com dplyr
summary_stats <- ic_fflch_usp %>%
  group_by(ic_bin, Situ_bach_bin) %>%
  summarise(
    count = n(),
    mean = mean(ic_bin, na.rm = TRUE),
    sd = sd(ic_bin, na.rm = TRUE)
  )

# Exibir as estatísticas descritivas
print(summary_stats)


# 11. Exportando o dataframe ic_fflch_usp para um arquivo CSV -----------------------------------------------------------
 
write.csv(ic_fflch_usp, file = "/Downloads/ic_fflch_usp.csv", row.names = FALSE)

# Remover o dataframe da memória
rm(ic_fflch_usp)

# Limpar a memória
gc()


# 12. Novas Regressões -----

# Ajustando o modelo de regressão linear múltipla

modelo <- lm(ic_bin ~ periodo + sexo + ppi_bin + sfmpct + em_bin + work_bin + idade_ano_vest, 
             data = ic_fflch_usp)

summary(modelo)
nobs(modelo)
coef(modelo)

modelo2 <- lm(ic_bin ~ sfmpct + work_bin + idade_ano_vest + cotista_bin, 
             data = ic_fflch_usp)
summary(modelo2)
nobs(modelo2)
coef(modelo2)

modelo2 <- lm(ic_bin ~ sfmpct + periodo + work_horas + idade_ano_vest + cotista_bin, 
              data = ic_fflch_usp)
summary(modelo2)
nobs(modelo2)
coef(modelo2)

modelo_interacao <- lm(ic_bin ~ sfmpct * work_bin + idade_ano_vest  * work_bin + turno_bin * work_bin, 
              data = ic_fflch_usp)
summary(modelo_interacao)
nobs(modelo_interacao)
coef(modelo_interacao)

modelo_evasao1 <- lm(situ_bach_bin ~ sfmpct * work_bin + idade_ano_vest + turno_bin * work_bin, 
              data = ic_fflch_usp)
summary(modelo_evasao1)
nobs(modelo_evasao1)
coef(modelo_evasao1)

# Usando o dataset 'iris' como exemplo
data(ic_fflch_usp)
df <- ic_fflch_usp[, 1:4]  # Usando apenas as variáveis numéricas para a clusterização



# Análise de Cluster-----

# Instalar pacotes necessários se ainda não estiverem instalados
install.packages("ggplot2")
install.packages("cluster")

# Carregar pacotes
library(ggplot2)
library(cluster)

# Carregar o dataset
data <- ic_fflch_usp

# Criar as variáveis interativas
data$sfmpct_work_bin <- data$sfmpct * data$work_bin
data$idade_ano_vest_work_bin <- data$idade_ano_vest * data$work_bin
data$turno_bin_work_bin <- data$turno_bin * data$work_bin

# Selecionar as variáveis para a clusterização
cluster_data <- data[, c("ic_bin", "sfmpct_work_bin", "idade_ano_vest_work_bin", "turno_bin_work_bin")]

# Normalizar os dados
cluster_data_scaled <- scale(cluster_data)

# Calcular a matriz de distâncias
dist_matrix <- dist(cluster_data_scaled)

# Definir o número de clusters (k)
k <- 6  # Defina o número de clusters com base em sua análise

# Verificar se há valores ausentes
any(is.na(cluster_data_scaled))

# Verificar se há valores infinitos
any(is.infinite(cluster_data_scaled))

# Remover linhas com valores ausentes
cluster_data_scaled <- na.omit(cluster_data_scaled)

# Verificar a estrutura dos dados
str(cluster_data_scaled)


# Executar o k-means
set.seed(123)  # Definir a semente para reprodutibilidade
kmeans_result <- kmeans(cluster_data_scaled, centers = k, nstart = 25)

# Adicionar os clusters ao dataset original
data$cluster <- as.factor(kmeans_result$cluster)

# Visualizar os clusters com ggplot2
ggplot(data, aes(x = sfmpct_work_bin, y = idade_ano_vest_work_bin, color = cluster)) +
  geom_point(size = 3) +
  labs(title = "Clusterização k-means", x = "sfmpct * work_bin", y = "idade_ano_vest * work_bin") +
  theme_minimal()



###

# Carregar pacotes necessários
library(tidyverse)  # Para manipulação de dados e visualização

# Supondo que 'data' seja seu dataset original
data <- ic_fflch_usp

# Selecionar as variáveis relevantes para clusterização
cluster_data <- data %>%
  select(sfmpct, idade_ano_vest, work_bin, turno_bin, ppi_bin)

# Remover dados ausentes antes da normalização
cluster_data_clean <- na.omit(cluster_data)

# Normalizar os dados
cluster_data_scaled <- scale(cluster_data_clean)

# Definir o número de clusters
k <- 5  # Ajuste conforme necessário

# Executar o k-means
set.seed(123)  # Definir a semente para reprodutibilidade
kmeans_result <- kmeans(cluster_data_scaled, centers = k, nstart = 25)

# Adicionar os clusters ao dataset limpo
cluster_data_clean$cluster <- as.factor(kmeans_result$cluster)

# Associar os clusters ao dataset original
data$cluster <- NA  # Adicionar uma coluna de clusters ao dataset original
data[rownames(cluster_data_clean), "cluster"] <- cluster_data_clean$cluster

# Verificar o número de linhas após adicionar os clusters
n_with_clusters <- sum(!is.na(data$cluster))
cat("Número de linhas após adicionar clusters:", n_with_clusters, "\n")

# Visualizar os clusters com ggplot2
ggplot(data, aes(x = sfmpct, y = idade_ano_vest, color = cluster)) +
  geom_point(size = 3) +
  labs(title = "Clusterização k-means", x = "sfmpct", y = "idade_ano_vest") +
  theme_minimal()

