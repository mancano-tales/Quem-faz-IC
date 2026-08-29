mydta %>%
  filter(!is.na(raca)) %>%  # remove casos sem raça
  ggplot(aes(
    x = p,                   # variável contínua
    color = raca,            # cor por raça
    fill = raca,             # preenchimento por raça
    linetype = raca          # tipo de linha por raça
  )) +
  geom_density(size = 1.2, alpha = 0.6) +
  scale_fill_manual(values = c("Brancos" = "#1b9e77", "PPI" = "#d95f02", "NA" = "#7570b3")) +
  scale_color_manual(values = c("Brancos" = "#1b9e77", "PPI" = "#d95f02", "NA" = "#7570b3")) +
  scale_linetype_manual(values = c("Brancos" = "solid", "PPI" = "dashed", "NA" = "dotted")) +
  scale_x_continuous(limits = c(0, 0.51), breaks = seq(0, 0.5, 0.25), expand = c(0.001, 0.001)) +
  scale_y_continuous(expand = c(0.001, 0.001)) +
  labs(
    x = "Probabilidades preditas",
    y = "Densidade",
    color = "Raça",
    fill = "Raça",
    linetype = "Raça"
  ) +
  theme_bw(base_size = 15) +
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.text = element_text(size = 18),
    axis.title = element_text(size = 16),
    legend.position = "bottom",
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 16)
  )


---
  
  
  mydta %>%
  filter(!is.na(sfmpct)) %>%
  mutate(renda_cat = cut(sfmpct, breaks = 4, labels = c("Baixa","Média-Baixa","Média-Alta","Alta"))) %>%
  ggplot(aes(x = p, color = renda_cat, fill = renda_cat, linetype = renda_cat)) +
  geom_density(alpha = 0.4, size = 1.2) +
  labs(
    x = "Probabilidades preditas",
    y = "Densidade",
    color = "Renda",
    fill = "Renda",
    linetype = "Renda"
  ) +
  theme_bw(base_size = 15)

---
  
  mydta %>%
  filter(!is.na(idade)) %>%
  mutate(idade_cat = cut(idade, breaks = 4, labels = c("Jovem","Adulto-Jovem","Adulto","Idoso"))) %>%
  ggplot(aes(x = p, color = idade_cat, fill = idade_cat, linetype = idade_cat)) +
  geom_density(alpha = 0.4, size = 1.2) +
  labs(
    x = "Probabilidades preditas",
    y = "Densidade",
    color = "Faixa Etária",
    fill = "Faixa Etária",
    linetype = "Faixa Etária"
  ) +
  theme_bw(base_size = 15) +
  theme(
    axis.text = element_text(size = 14),
    axis.title = element_text(size = 16),
    legend.position = "bottom",
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12)
  )


