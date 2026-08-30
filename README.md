# Quem faz Iniciação Científica?

**Pacote de replicação** do artigo *Quem faz Iniciação Científica? Um estudo
sobre as desigualdades socioeconômicas no acesso à Iniciação Científica
FFLCH-USP (2010–2022)*, de **Tales Mançano** ([0000-0001-5923-9743](https://orcid.org/0000-0001-5923-9743))
e **Victor Alcantara** ([0000-0001-8846-9652](https://orcid.org/0000-0001-8846-9652)).

📊 **[Relatório de replicação](https://mancano-tales.github.io/Quem-faz-IC/)** —
cada tabela e figura do artigo, gerada a partir dos microdados, com os números
publicados ao lado para conferência.

---

## O artigo

A Iniciação Científica é um recurso escasso e disputado dentro da universidade:
dá prestígio acadêmico, muitas vezes vem com bolsa, e é a porta de entrada
para a pós-graduação. O artigo faz a ela a pergunta clássica dos estudos de
Desigualdade de Oportunidades Educacionais: **qual é a associação entre origem
social e o acesso a esse recurso?**

A literatura sobre estratificação no Brasil documenta amplamente as
desigualdades no *acesso* ao ensino superior. O artigo desloca a pergunta para
o que acontece *depois* do acesso — dentro da maior unidade da USP, a FFLCH —
cruzando o cadastro de ingressantes da graduação com o registro de todos os
projetos de IC da universidade.

### O achado

**As características adscritas explicam pouco; a necessidade de trabalhar
explica muito.**

Renda familiar per capita e escolaridade dos responsáveis, os marcadores
tradicionais da origem social, têm efeito pequeno sobre a probabilidade de
fazer IC — e a renda, quando tem efeito, vai na direção contrária da esperada
(quanto maior a renda, *menores* as chances). O que separa os estudantes é o
vínculo com o trabalho:

| Fator | Razão de chance | Leitura |
|---|---|---|
| Trabalhar em tempo integral ao prestar o vestibular | 0,747 | reduz as chances de fazer IC |
| Pretender se sustentar por conta própria na graduação | 0,697 | o maior efeito negativo do modelo |
| Contar com bolsa e apoio da família | 1,255 | o maior efeito positivo |
| Estudar no período noturno | 0,731 | reduz as chances |
| Renda familiar per capita (por SM) | 0,950 | efeito pequeno e negativo |
| Escolaridade do responsável (superior completo) | 1,070 | não significativo |

A conclusão do artigo é que, embora as desigualdades de origem persistam no
acesso ao ensino superior, **dentro** dele o mecanismo dominante passa a ser
outro: a necessidade de trabalhar, que consome o tempo de que a IC depende.
Isso conversa com Breen e Jonsson (2005) — os efeitos de origem são mais
fortes nas transições educacionais iniciais do que nas avançadas — e com Comin
e Barbosa (2011): na FFLCH do período, cerca de 42% dos ingressantes já
trabalhavam regularmente e 32% pretendiam se manter com o próprio trabalho.

A política de IC esteve em expansão: a proporção de estudantes da FFLCH que
fizeram IC passou de 9,1% na coorte de 2010 para 15,3% na de 2018.

---

## Como replicar

**Requisitos**: R 4.4 ou superior. Os pacotes (`tidyverse`, `arrow`, `readxl`,
`writexl`, `stargazer`, `here`, `scales`) são instalados automaticamente na
primeira execução. Para gerar o relatório, também [Quarto](https://quarto.org).

```bash
git clone https://github.com/mancano-tales/Quem-faz-IC.git
cd Quem-faz-IC
Rscript run_all.R
```

Ou, no RStudio, abra `Quem-faz-IC.Rproj` e rode `source("run_all.R")`.

Isso reconstrói `data/ic_usp.parquet` a partir das planilhas do SIC-USP e
regrava tudo o que está em `outputs/`. Leva alguns minutos — a leitura dos
34 MB de `.xlsx` brutos é a parte lenta. Para gerar o relatório em HTML:

```bash
quarto render replication-report.qmd
```

Os scripts também rodam isoladamente, na ordem numérica. Cada um lê o que
precisa do disco e não depende de objetos deixados na memória pelo anterior.

---

## Estrutura

```
├── run_all.R                  executa o pipeline inteiro
├── replication-report.qmd     relatório de replicação (→ docs/index.html)
│
├── data-raw/                  microdados como recebidos do SIC-USP
├── data/                      ic_usp.parquet — painel analítico, gerado
│
├── R/
│   ├── setup.R                pacotes, caminhos e recortes
│   └── recode.R               recodificação das variáveis do QASE
│
├── analysis/
│   ├── 01-build-data.R        brutos → painel
│   ├── 02-article-fflch.R     tabelas, modelos e figuras do artigo
│   └── 03-supplementary-usp.R recortes da USP e de Ciências Sociais
│
├── outputs/{tables,figures}   resultados gerados
└── inst/legacy/               scripts exploratórios originais dos autores
```

`inst/legacy/` guarda os quatro scripts em que a análise foi feita
originalmente. Eles não fazem parte do pipeline e não rodam sem edição
(dependem de `setwd()` e de caminhos absolutos), mas ficam versionados como
rastro de auditoria: é contra eles que as escolhas de `analysis/` podem ser
conferidas.

---

## Os dados

Os microdados vêm de dois pedidos ao **SIC-USP**, o Serviço de Informação ao
Cidadão da universidade, sob a Lei de Acesso à Informação (Lei nº 12.527/2011).
Foram preparados pelo Escritório de Gestão de Indicadores de Desempenho
Acadêmico (EGIDA) a partir dos bancos institucionais da Superintendência de
Tecnologia da Informação.

| Arquivo | Pedido | Sistema de origem | Conteúdo |
|---|---|---|---|
| `sic-usp-243654-ingressantes.xlsx` | Cod. #243654 | JupiterWeb (Pró-Reitoria de Graduação) | 298.704 ingressantes na USP, com o questionário socioeconômico da FUVEST |
| `sic-usp-243681-perfil-ic.xlsx` | Cod. #243681 | Atena (Pró-Reitoria de Pesquisa) | 29.544 projetos de IC de 22.301 estudantes |

**Privacidade.** A USP entregou os dados já anonimizados: o `Identificador` é
um inteiro sequencial, sem nome, número USP, CPF ou data de nascimento. A
única variável de idade é a idade no ano da prova do vestibular. É por isso
que os microdados podem ser redistribuídos aqui.

As informações socioeconômicas vêm do **QASE**, o Questionário de Avaliação
Socioeconômica aplicado pela FUVEST no vestibular. Ele foi respondido por
98,55% dos ingressantes da FFLCH no período, mas o preenchimento por questão é
muito desigual — duas perguntas são inutilizáveis (ocupação do principal
contribuinte, 19,05%; INCLUSP, nenhuma resposta). A `analysis/02` reproduz essa
tabela de completude.

### O painel

`data/ic_usp.parquet` tem uma linha por ingressante (298.704 × 54). Combina:

- **graduação** — curso, unidade, ano e período de ingresso, modo de ingresso,
  classificação na carreira, situação no bacharelado e na licenciatura;
- **QASE** — renda familiar, pessoas que vivem dessa renda, escolaridade dos
  responsáveis, atividade remunerada, pretensão de sustento, trajetória escolar;
- **IC** — `qtd_ic` (número de projetos), `IC` (indicador binário), atributos do
  primeiro projeto e uma coluna de contagem por fonte de fomento (PIBIC,
  FAPESP, PUB, Unidade USP, etc.).

Uma inconsistência de nomenclatura foi **mantida** para não quebrar a
comparação com os resultados publicados: `ef1` é o Item 14 do QASE (onde
cursou o ensino fundamental), mas `ef2` é o Item 15, que pergunta onde cursou
o ensino **médio**, apesar do prefixo `ef`. `em` é o Item 16 (tipo de ensino
médio concluído).

### Material auxiliar

`data-raw/auxiliar/` reúne o restante do material de origem do projeto. Nada
disso entra no pipeline: são dados que sustentam passagens do artigo ou que
foram usados em fases anteriores da pesquisa, versionados para completar a
proveniência.

| Arquivo | O que é |
|---|---|
| `dicionario-variaveis-sic-usp.xlsx` | dicionário de dados dos pedidos #243654 e #243681 |
| `sic-usp-239991-graduandos-fflch.xlsx` | pedido #239991: 17.700 graduandos da FFLCH (2010–2023) com ingresso, status e ano de conclusão |
| `sic-usp-239991-ciencias-sociais.xlsx` | recorte de Ciências Sociais do mesmo pedido |
| `sic-usp-243681-ic-fflch.xlsx` | recorte FFLCH do Atena: 3.311 projetos de IC |
| `sic-usp-243681-ciencias-sociais-ingressantes.xlsx` | ingressantes de Ciências Sociais |
| `evasao-2018-2.xlsx` | dados de evasão por coorte |

O pedido **#239991** merece um aviso: apesar de o artigo o citar na nota de
fonte das tabelas, ele **não** é a origem de nenhuma delas — não tem campo de
fomento e seus N por coorte não são os publicados (ver "Divergências"). Está
aqui por ser parte do histórico do projeto, não por ser insumo de análise.

Dois arquivos do acervo foram **deliberadamente deixados de fora** por conterem
dados pessoais que os microdados do SIC-USP não têm:

- uma extração do sistema Atena de maio/2022 com nome, e-mail e número USP de
  estudantes e orientadores;
- o levantamento do Programa Unificado de Bolsas da FFLCH (2015–2023), que
  inclui uma lista de 713 docentes com e-mail institucional.

O segundo é a fonte dos números do PUB citados nas limitações do artigo (976
bolsas concedidas na unidade contra 99 registradas no Atena). Quem precisar
deles deve solicitá-los à Pró-Reitoria de Pesquisa.

---

## O que este pacote conserta

O repositório original tinha os dados e quatro scripts exploratórios, mas não
era replicável. As correções:

**O elo perdido do pipeline.** O `ic_usp.parquet` existia como arquivo, mas
nenhum código versionado o gerava — não era possível chegar a ele a partir das
planilhas do SIC-USP. O `analysis/01-build-data.R` reconstrói esse passo. As
três regras de agregação do Atena para o nível do estudante foram inferidas dos
brutos e conferidas contra o parquet original:

| Regra | Conferência |
|---|---|
| Atributos do projeto = primeiro projeto registrado | 22.300 / 22.300 |
| Colunas de fomento = contagem de projetos por fonte | 21.902 / 21.902 |
| `qtd_ic` = projetos com fomento informado | 22.300 / 22.300 |

O painel reconstruído é **idêntico ao original nas 54 colunas e 298.704
linhas**. Sobre a terceira regra: o campo `N_de_ICs` do próprio Atena parece o
candidato natural para `qtd_ic`, mas diverge em 576 estudantes e não reproduz
os números publicados; é a contagem de projetos com fomento informado que
reproduz.

**A especificação do modelo.** A Tabela 4 publicada traz a linha *Período:
Noturno*, mas `periodo` não estava na fórmula de `reg4` em nenhum dos scripts
versionados — o código havia ficado defasado em relação ao artigo. A amostra
também é outra: as tabelas descritivas usam as coortes 2010–2018, o modelo usa
2010–2022. Com `periodo` na fórmula e a janela 2010–2022, os números fecham.

**A recodificação triplicada.** As faixas de renda, escolaridade, raça,
trabalho e sustento do QASE estavam copiadas e coladas em quatro arquivos, com
pequenas divergências entre eles. Agora existem uma vez só, em `R/recode.R`.

**Os caminhos.** `setwd(rstudioapi::getActiveDocumentContext()$path)` e um
`D:/01 - data/...` deram lugar a `here::here()`. Os scripts rodam pelo RStudio,
por `Rscript` e pelo Quarto, em qualquer máquina.

---

## Conferência com o artigo publicado

| Resultado | Situação |
|---|---|
| **Tabela 1** — acesso à IC por coorte (2010–2018) | ✅ idêntica nas 9 coortes |
| **Tabela 2** — taxa de resposta do QASE | ✅ idêntica nas 13 questões |
| **Tabela 4** — regressão logística | ✅ N = 16.974, AIC = 10537,63, `ano` = −0,058, `raça PPI` = −0,138 |
| **Figuras 1 e 2** — probabilidades preditas | ✅ reproduzem o padrão descrito |
| **Tabela 3** — projetos por tipo de fomento | ⚠️ não reproduz — ver abaixo |

### Divergências em relação ao publicado

**Tabela 3 (tipo de fomento).** Não é reproduzível com os dados deste pacote, e
vale registrar o quanto isso foi testado.

A tabela publicada soma 2.979 projetos e usa as categorias "Bolsas FFLCH",
"Bolsas Programas Reitoria (USP)" e "Sem Informação sobre Fomento" — nenhuma
das três existe no campo `TipoFomento` da extração #243681. São agrupamentos
feitos à mão, provavelmente numa tabela dinâmica do Excel; as abas de tabela
dinâmica que sobreviveram nos arquivos estão hoje com as células em `#REF!`.

Como o agrupamento não altera o total, dá para testar o recorte
independentemente dele. Restringindo aos 3.311 projetos de estudantes da FFLCH,
varremos todas as combinações de janela de ano (de ingresso ou de projeto,
início em 2009–2011, fim em 2017–2023) contra a exclusão de até três categorias
de `situacao`. **Nenhuma combinação produz 2.979 projetos.** As mais próximas
são 2.922 (projetos de 2010–2021) e 3.015 (coortes 2009–2022).

A nota de fonte do artigo aponta para o pedido **SIC-USP Cod. #239991**, mas
essa pista foi verificada e não se sustenta: a resposta ao #239991 é um
cadastro de 17.700 graduandos da FFLCH (2010–2023) com ingresso, status e
conclusão, **sem nenhum campo de fomento ou de Iniciação Científica**. Seus N
por coorte (1.003 em 2010, 1.069 em 2011, …) também não são os da Tabela 1
(1.732, 1.759, …), que saem do #243654. A nota de fonte, que credita
"#239991 e #24368" a todas as tabelas, é imprecisa: as tabelas que reproduzem
foram construídas a partir do #243654 e do #243681.

A origem da Tabela 3, portanto, permanece desconhecida. O `analysis/02` gera a
versão reproduzível a partir do que existe (2.818 projetos das coortes
2010–2022) e diz isso no próprio código.

**Rodapé da Tabela 4.** A tabela publicada é internamente inconsistente: o
bloco `AIC = 10537,63 / BIC = 10661,46 / Pseudo-R² = 0,054` corresponde ao
modelo cujos coeficientes ela mostra — e é o que este pacote reproduz —, mas
as linhas `Log Likelihood = −5.295,635` e `Akaike Inf. Crit. = 10.617,270`, do
rodapé automático do `stargazer`, vêm de um modelo diferente, com menos
parâmetros. O modelo reproduzido tem log-verossimilhança −5.252,814.

---

## Limitações reconhecidas no artigo

- **Não há indicador de desempenho** dos estudantes nos dados, embora ele seja
  critério de seleção para as bolsas PIBIC. A classificação na carreira do
  vestibular entra como proxy, mas é limitada: cotistas e ampla concorrência
  disputam em classificações apartadas, o que os torna incomparáveis.
- **Sub-registro de bolsas fora do CNPq.** Só PIBIC e PIBITI são administradas
  exclusivamente pelo Atena. O Programa Unificado de Bolsas da USP concedeu 976
  bolsas na FFLCH no período, mas apenas 99 ICs com bolsa PUB constam no
  sistema; da FAPESP, cerca de 15% aparecem. Como o PUB atende um público de
  menor nível socioeconômico (41,4% dos bolsistas PUB estão no quartil de menor
  renda, contra 26,5% dos PIBIC), o sub-registro pode enviesar a amostra.
- **Até 2015** todos os projetos constam como encerrados; a classificação por
  situação (aprovado, reprovado, cancelado, transferido) só existe a partir de
  2016.

---

## Como citar

> MANÇANO, Tales; ALCANTARA, Victor. Quem faz Iniciação Científica? Um estudo
> sobre as desigualdades socioeconômicas no acesso à Iniciação Científica
> FFLCH-USP (2010–2022).

Para o pacote de replicação, cite este repositório:
`https://github.com/mancano-tales/Quem-faz-IC`.

## Licença

O código é distribuído sob a **GNU General Public License v2** (ver `LICENSE`).

Os microdados em `data-raw/` são informação pública obtida via Lei de Acesso à
Informação e permanecem públicos; ao reutilizá-los, cite o SIC-USP e os códigos
dos pedidos (#243654 e #243681).
