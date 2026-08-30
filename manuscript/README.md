# Arquivo de versões do manuscrito

Esta pasta guarda as versões sucessivas do texto, para que a evolução do artigo
fique visível e datável. Ela existe porque boa parte do trabalho de escrita e de
análise aconteceu fora de controle de versão, em documentos do Google e em
planilhas, e essa parte da história se perderia se ficasse só na memória.

## Como está organizada

```
manuscript/
├── versoes/      os .docx como foram salvos, renomeados AAAA-MM-DD_slug.docx
├── texto/        o texto de cada versão em .txt, uma frase por linha
├── versoes.csv   o registro: data, tipo, autor da última edição, palavras
└── datas.csv     datas e classificação informadas à mão (ver abaixo)
```

Os `.txt` são o que torna a evolução legível. O Word guarda cada parágrafo numa
linha única, e o `git diff` entre dois `.docx` não diz nada. Quebrando o texto
em uma frase por linha, dá para ver frase a frase o que saiu e o que entrou:

```bash
diff manuscript/texto/2025-08-15_vr1-pucrs-quem-faz-iniciacao-cientifica.txt \
     manuscript/texto/2025-08-21_vr1-pucrs-quem-faz-iniciacao-cientifica-versaovictor.txt
```

## Para arquivar novas versões

Baixe os `.docx` (a pasta de Downloads serve) e rode:

```bash
Rscript tools/arquivar-versoes.R
```

O script lê a data de dentro de cada arquivo, copia para `versoes/`, extrai o
texto para `texto/` e atualiza o registro. Rodar de novo é seguro: arquivos já
arquivados são reconhecidos pelo MD5 e ignorados, mesmo que tenham sido
renomeados.

**Uma ressalva sobre datas.** Documentos exportados do Google Docs chegam sem
os metadados internos de criação e modificação, e o download reescreve a data
do sistema de arquivos. Para esses arquivos não há como recuperar a data
verdadeira automaticamente — ela foi lida do listing do zip de origem e anotada
em `datas.csv`. Quando o script não encontrar data confiável, ele avisa e pede
uma linha nesse arquivo.

## As versões

| Data | Tipo | Palavras | Arquivo |
|---|---|---|---|
| 2024-08-01 | material de campo | 392 | TCLE — entrevistas Anpocs |
| 2024-08-06 | material de campo | 861 | Roteiro de entrevista |
| 2024-12-02 | material de campo | 445 | TCLE — métodos |
| 2025-05-28 | outro artigo | 596 | Revisão sistemática sobre evasão |
| 2025-05-30 | folha de rosto | 658 | Folha de rosto PUC-RS |
| 2025-08-06 | plano de revisão | 696 | Plano de revisão |
| **2025-08-13** | **versão do artigo** | **6.323** | Escrita de Tales, antes da passagem de Victor |
| **2025-08-15** | **versão do artigo** | **6.384** | vr1 |
| 2025-08-15 | gráficos e tabelas | 1.276 | Gráficos e tabelas |
| **2025-08-21** | **versão do artigo** | **5.758** | Revisão de Victor |
| **2025-09-10** | **versão do artigo** | **7.028** | Pós-revisão editorial da revista |

O registro em `versoes.csv` é a fonte; esta tabela é um resumo.

A trajetória de tamanho conta parte da história. O texto sai de Tales com 6.323
palavras, cresce pouco na `vr1`, e então Victor corta cerca de 600 palavras na
revisão de agosto — sobretudo do resumo e da introdução, condensando passagens
que explicavam a hipótese inicial. A editoração da revista devolve 1.270
palavras, o que é esperado: é nela que entram as tabelas por extenso, as notas
de rodapé sobre os modos de ingresso e as expansões pedidas pelo parecer.

Os documentos que não são versões do artigo estão aqui de propósito. O roteiro
de entrevista e os termos de consentimento pertencem a uma etapa qualitativa do
projeto que não entrou nesta submissão, e a revisão sistemática sobre evasão é
outro artigo, com outros coautores — está no arquivo porque foi escrita no
mesmo período e ajuda a datar o que estava em curso.

## Da planilha ao código

A parte quantitativa do trabalho passou por três fases, e o repositório guarda
vestígios das três.

**Planilhas.** As primeiras tabulações foram feitas em planilhas, com tabelas
dinâmicas do Excel e do Google Sheets. Isso funcionou para explorar, mas não
deixou rastro do procedimento: as abas de tabela dinâmica que sobreviveram nos
arquivos de origem estão hoje com as células em `#REF!`, e o que se vê é o
resultado sem a receita. A consequência mais concreta aparece na **Tabela 3** do
artigo publicado, com os 2.979 projetos por tipo de fomento: ela usa categorias
("Bolsas FFLCH", "Bolsas Programas Reitoria (USP)") que não existem em nenhum
arquivo de dados, e nenhuma combinação de filtros sobre os microdados a
reproduz. Ela foi montada à mão, e a receita se perdeu.

**Scripts exploratórios.** A segunda fase está em `inst/legacy/`: cinco arquivos
de R escritos entre 2023 e 2025, com a recodificação das faixas de renda
copiada e colada em quatro deles, `setwd(rstudioapi::getActiveDocumentContext())`
no topo, e um caminho absoluto para `D:/01 - data/`. Eles produziram os
resultados publicados, mas não rodam em outra máquina, e o código que gerava o
painel a partir das planilhas do SIC-USP não chegou a ser versionado — existia o
arquivo `ic_usp.parquet`, não o procedimento que o construía.

**Pipeline reproduzível.** A terceira fase é o que está em `analysis/`. O elo
perdido foi reconstruído: as regras de agregação foram inferidas dos microdados
e conferidas contra o parquet original, que hoje é regenerado de forma idêntica
nas 54 colunas e 298.704 linhas. A recodificação existe uma vez só. As
conferências contra os números publicados são asseverações que derrubam a
execução, e não mensagens impressas. E um workflow roda o pacote inteiro num
ambiente limpo a cada alteração.

O que se ganhou nessa passagem não foi apenas conveniência. Foi a possibilidade
de descobrir erros: a especificação do modelo publicado não incluía a variável
`periodo` em nenhum script versionado, o rodapé da Tabela 4 mistura estatísticas
de dois modelos diferentes, e a nota de fonte credita um pedido de acesso à
informação que não contém os dados usados. Nada disso era visível enquanto o
procedimento morava numa planilha.
