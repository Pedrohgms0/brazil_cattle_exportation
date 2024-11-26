# Lista das bibliotecas necessárias
bibliotecas <- c("ggplot2", "dplyr", "scales", "rnaturalearth", "rnaturalearthdata", "viridis", "countrycode", "sf", "gridExtra", "cowplot")

# Instalar as bibliotecas que não estão instaladas
instalar <- bibliotecas[!(bibliotecas %in% installed.packages()[,"Package"])]
if(length(instalar)) install.packages(instalar)

# Carregar as bibliotecas
lapply(bibliotecas, library, character.only = TRUE)

# Carregar os dados
dados_bovinos <- read.csv("Dados_Bovinos_completos_Limpos.csv")

# Verificar os primeiros registros para entender a estrutura
head(dados_bovinos)

# Verificando se há algum problema com o valor_fob
dados_bovinos$valor_fob <- gsub(",", "", dados_bovinos$valor_fob)  # Remove vírgulas
dados_bovinos$valor_fob <- as.numeric(dados_bovinos$valor_fob)  # Converte para numérico

# Verificar se a coluna valor_fob está convertida corretamente
summary(dados_bovinos$valor_fob)

# Agrupar os dados por país de destino
dados_agrupados <- dados_bovinos %>%
  group_by(country_of_destination) %>%
  summarise(Total_FOB = sum(valor_fob, na.rm = TRUE))

# Verificar os dados agrupados
head(dados_agrupados)

##########################################
##                                      ##
##              GRAFICO 1               ##
##                                      ##
##########################################

# Carregar o mapa mundial
mapa_mundi <- ne_countries(scale = "medium", returnclass = "sf")

# Verificar os dados do mapa
head(mapa_mundi)

# Usar countrycode para garantir que os nomes dos países estão em ISO3
dados_agrupados$country_of_destination <- countrycode(dados_agrupados$country_of_destination,
                                                       origin = "country.name",
                                                       destination = "iso3c")

# Verificar os valores únicos para garantir que a conversão foi feita corretamente
unique(dados_agrupados$country_of_destination)

# Realizar o merge entre os dados e o mapa usando o código ISO3
mapa_fob <- mapa_mundi %>%
  left_join(dados_agrupados, by = c("iso_a3" = "country_of_destination"))

# Verificar o merge
head(mapa_fob)

# Convertemos o valor FOB para milhões de dólares
mapa_fob_milhoes <- mapa_fob %>%
  mutate(Total_FOB_Milhoes = Total_FOB / 1e6)  # Dividir por 1 milhão para ficar em milhões de dólares

# Agora, vamos plotar o gráfico com o novo valor FOB em milhões de dólares
ggplot(data = mapa_fob_milhoes) +
  geom_sf(aes(fill = Total_FOB_Milhoes), color = "gray80", lwd = 0.1) +
  scale_fill_viridis(option = "C", trans = "log", na.value = "gray80", name = "Valor FOB (Milhões de US$)") +
  scale_fill_continuous(labels = scales::label_number(scale = 1, suffix = "M", accuracy = 0.1)) + # Remover notação científica e exibir em milhões
  theme_minimal() +
  labs(title = "Mapa Mundi com Valor FOB por País",
       subtitle = "Valores em milhões de dólares por país de destino",
       caption = "Fonte: Dados de exportação") +
  theme(legend.position = "right", 
        axis.text = element_blank(), 
        axis.ticks = element_blank())

# Agrupar os dados por país de destino e somar os valores FOB
top_10_paises <- dados_bovinos %>%
  group_by(country_of_destination) %>%
  summarise(Total_FOB = sum(as.numeric(valor_fob), na.rm = TRUE)) %>%
  arrange(desc(Total_FOB)) %>%
  head(10) %>%
  mutate(Total_FOB_Milhoes = Total_FOB / 1e6)  # Converter para milhões de dólares

# Verificar os top 10 países
top_10_paises

# Criar a tabela com os top 10 países
tabela_top_10 <- ggplot(top_10_paises, aes(x = reorder(country_of_destination, Total_FOB_Milhoes), y = Total_FOB_Milhoes)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +  # Gira a barra para melhor exibição
  scale_y_continuous(labels = scales::label_number(scale = 1, suffix = "M", accuracy = 0.1)) +
  labs(x = "País", y = "Valor FOB (Milhões de US$)", title = "Top 10 Países por Valor FOB") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Criar o gráfico do mapa
mapa_gráfico <- ggplot(data = mapa_fob_milhoes) +
  geom_sf(aes(fill = Total_FOB_Milhoes), color = "gray80", lwd = 0.1) +
  scale_fill_viridis(option = "C", trans = "log", na.value = "gray80", name = "Valor FOB (Milhões de US$)") +
  scale_fill_continuous(labels = scales::label_number(scale = 1, suffix = "M", accuracy = 0.1)) + 
  theme_minimal() +
  labs(title = "Mapa Mundi com Valor FOB por País",
       subtitle = "Valores em milhões de dólares por país de destino",
       caption = "Fonte: Dados de exportação") +
  theme(legend.position = "right", 
        axis.text = element_blank(), 
        axis.ticks = element_blank())

# Usar grid.arrange para combinar os gráficos
grid.arrange(mapa_gráfico, tabela_top_10, ncol = 2)

##########################################
##                                      ##
##              GRAFICO 2               ##
##                                      ##
##########################################

# Agrupar os dados por exportador, somar o valor FOB e ordenar
top_exportadores <- dados_bovinos %>%
  group_by(exportador) %>%
  summarise(Total_FOB = sum(as.numeric(valor_fob), na.rm = TRUE)) %>%
  arrange(desc(Total_FOB)) %>%
  top_n(10, Total_FOB)  # Filtra os top 10 exportadores com maior valor FOB

# Verificar os top 10 exportadores
head(top_exportadores)

# Criar o gráfico de barras para os top 10 exportadores
ggplot(top_exportadores, aes(x = reorder(exportador, Total_FOB), y = Total_FOB)) +
  geom_bar(stat = "identity", fill = viridis::viridis(10), color = "black", size = 0.5) + # Cores mais atraentes e borda preta
  coord_flip() +  # Gira as barras para facilitar a leitura
  scale_y_continuous(labels = scales::label_number(scale = 0.001, suffix = "", accuracy = 1)) +  # Formatar a escala de Y
  labs(
    x = "Exportador",
    y = "Valor FOB (Milhões de US$)",
    title = "Top 10 Exportadores por Valor FOB",
    subtitle = "Valores em milhões de dólares",
    caption = "Fonte: Dados de Exportação"
  ) +
  theme_minimal(base_size = 14) +  # Usar um tema minimalista com fonte maior
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Melhorar legibilidade no eixo X
    axis.text.y = element_text(size = 12),
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),  # Título centralizado e em negrito
    plot.subtitle = element_text(hjust = 0.5, size = 12),  # Subtítulo centralizado
    plot.caption = element_text(hjust = 1, size = 10),  # Legenda do gráfico à direita
    axis.title = element_text(size = 14, face = "bold"),  # Títulos dos eixos em negrito
    panel.grid.major = element_line(color = "gray90"),  # Cor das linhas de grade
    panel.grid.minor = element_blank()  # Remover linhas de grade menores
  )



##########################################
##                                      ##
##              GRAFICO 3               ##
##                                      ##
##########################################

# Agrupar por ano e somar o volume por ano
dados_ano_volume <- dados_bovinos %>%
  group_by(ano) %>%
  summarise(total_volume = sum(volume, na.rm = TRUE))

# Criar o gráfico combinado (barra + linha) para o volume
ggplot(dados_ano_volume, aes(x = ano)) +
  # Adicionando as barras (com valores de 'total_volume')
  geom_bar(aes(y = total_volume), stat = "identity", fill = "steelblue", alpha = 0.6) +
  # Adicionando a linha
  geom_line(aes(y = total_volume), color = "red", size = 1) +
  # Escala do eixo y (formato de números sem notação científica)
  scale_y_continuous(labels = scales::label_number(scale = 1, accuracy = 1)) +
  # Títulos e labels
  labs(
    title = "Volume de Exportação Anual",
    x = "Ano",
    y = "Volume (em toneladas)",  # Adapte conforme a unidade de medida
    caption = "Fonte: Dados de Exportação"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
    axis.text.y = element_text(size = 10)
  )


# Criar o gráfico combinado (barra + linha)
# Agrupar por ano e somar o valor FOB por ano
dados_ano_fob <- dados_bovinos %>%
  group_by(ano) %>%
  summarise(total_fob = sum(valor_fob, na.rm = TRUE))

# Criar o gráfico combinado (barra + linha)
ggplot(dados_ano_fob, aes(x = ano)) +
  # Adicionando as barras (com valores de 'total_fob')
  geom_bar(aes(y = total_fob), stat = "identity", fill = "steelblue", alpha = 0.6) +
  # Adicionando a linha
  geom_line(aes(y = total_fob), color = "red", size = 1) +
  # Escala do eixo y (formato de moeda)
  scale_y_continuous(labels = scales::label_dollar(scale = 1, suffix = "")) +
  # Títulos e labels
  labs(
    title = "Faturamento FOB Anual",
    x = "Ano",
    y = "Valor FOB (em dólares)",
    caption = "Fonte: Dados de Exportação"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
    axis.text.y = element_text(size = 10)
  )














