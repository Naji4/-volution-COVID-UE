library(dplyr)
library(readr)

folder_path <- "C:/Users/moha_/Documents/covid_data"
# lister toutes les archives csv dans le dossier
file_list <- list.files(path = folder_path, pattern = "\\.csv$", full.names = TRUE)
# function pour lire tous les donnnees et forcer les col a etre des caracteres comme type
read_as_character <- function(file) {
  read_csv(file, col_types = cols(.default = "c"))  # Forzar todas las columnas como character
}

# lire et combiner les archives 
covid_data <- file_list %>%
  lapply(read_as_character) %>%  # lire les archives comme lists des df
  bind_rows()                    # combinaison en un seul df

# reconversion de la var 'last_update' en format datetime'
covid_data <- covid_data %>%
  mutate(`Last Update` = as.POSIXct(Last_Update, format = "%Y-%m-%d %H:%M:%S", tz = "UTC") %>%
           coalesce(as.POSIXct(Last_Update, format = "%m/%d/%Y %H:%M", tz = "UTC")))

# pour connaitre a quoi il rassemble: (3.708.419 lignes, 21 colonnes)
dim(covid_data)
str(covid_data)
tail(covid_data)
head(covid_data)
colnames(covid_data)

# regarder des valeures uniques dans des col clés
unique(covid_data$Country_Region) #noms des tous les pays dispo
unique(covid_data$Last_Update) #toutes les dates dispo, 1000 dates differentes

# comparaison des colonnes semblantes, les plus pertinentes
identical(covid_data$Last_Update, covid_data$`Last Update`)  # ¿Son idénticas?
# car elle sont pas indentiques on filtre pour voir c'est quoi les diffs
covid_data %>%
  filter(Last_Update != `Last Update`) %>%
  select(Last_Update, `Last Update`) %>%
  head()

#management des valeurs nuls
sum(is.na(covid_data$Last_Update))  
unique(covid_data$Last_Update)

covid_data$`Last Update`
str(covid_data$`Last Update`)
sum(is.na(covid_data$`Last Update`))
#on voit que 'Last Update' est indentique à Last_Update, donc on elimine un

#-------------------------------------------------------------------------
# Creation d'un nouveau data frame pour les pays de l'europe
european_countries <- c(
  "Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czechia", "Denmark",
  "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland",
  "Italy", "Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands",
  "Poland", "Portugal", "Romania", "Slovakia", "Slovenia", "Spain", "Sweden"
)
population_data <- data.frame(
  Country_Region = eu_countries,
  Population = c(
    8917205, 11555997, 6948445, 4047200, 1214558, 10701777, 5889575, 1331057,
    5533366, 67564251, 83900471, 10300434, 9655361, 5021529, 58112786, 1886198,
    2793474, 645397, 514100, 17533405, 38268000, 10196709, 19132604, 5460102,
    2100126, 47329981, 10549379
  )
)

# filtrer les donnees par pays europeens
european_data <- covid_data %>%
  filter(Country_Region %in% european_countries) %>%
  select(
    Country_Region,        
    Last_Update,             
    Confirmed,             
    Deaths,              
    Lat,             
    Long_            
  )
european_data <- european_data %>%
  left_join(population_data, by = "Country_Region")

european_data <- european_data %>%
  mutate(
    Deaths = as.numeric(Deaths),
    Confirmed = as.numeric(Confirmed),
    Lat = as.numeric(Lat),
    Long_ =as.numeric(Long_)
  )
#quelques tests et traitements pour comprendre la BD:
min(european_data$Last_Update, na.rm = TRUE)
max(european_data$Last_Update, na.rm = TRUE) 

# filtrer pour avoir la derniere mise a jour par pays
latest_data <- european_data %>%
  group_by(Country_Region) %>%
  filter(Last_Update == max(Last_Update, na.rm = TRUE)) %>%
  ungroup()

# sum des morts totales a la derniere dates enrregistres, par pays
latest_by_country <- latest_data %>%
  group_by(Country_Region, Last_Update) %>%
  summarise(
    Total_Deaths = sum(Deaths, na.rm = TRUE),  
    Population = max(Population, na.rm = TRUE)  
  ) %>%
  ungroup()
# calculer les coordonees moyennes par pays
coordinates_by_country <- european_data %>%
  group_by(Country_Region) %>%
  summarise(
    Avg_Lat = mean(Lat, na.rm = TRUE),  
    Avg_Long = mean(Long_, na.rm = TRUE)  
  ) %>%
  ungroup()
# on rajoute les coordonees dans le df 
latest_by_country <- latest_by_country %>%
  left_join(coordinates_by_country, by = "Country_Region")

#-----------------------------------------------------------------------
# avec latest_by_country on cree le premier graphique - LA CARTE DE L'UE

library(plotly)

choropleth_map <- plot_ly(
  data = latest_by_country, 
  type = 'choropleth',  
  locations = ~Country_Region,  #col avec les noms des pays
  locationmode = 'country names',  
  z = ~Total_Deaths, # ce qu'on veut représenter
  text = ~paste(
    "<b>Pays :</b> ", Country_Region, "<br>",
    "<b>Nombre total de morts :</b> ", Total_Deaths, "<br>",
    "<b>Population :</b> ", Population
  ),  # info qui s'affiche quand on passe le curseur
  colorscale = 'Reds',  #echelle des couleurs
  colorbar = list(title = "Morts totales")
) %>%
  layout(
    title = "Carte des décès par COVID-19 dans l'Union Européenne",
    geo = list(
      projection = list(type = 'natural earth'),  
      showframe = FALSE,  # sans marc
      showcoastlines = TRUE  
    )
  )

#print du graph:
choropleth_map

#---------------------------------------------------------------------------
#COURBE EPIDEMIQUE 
#pour s'assurer d'inclure la premiere date de 2020:
selected_dates <- european_data %>%
  mutate(Year = format(Last_Update, "%Y"),  #extraction annee
         Month = format(Last_Update, "%m")) %>%  #extraction mois
  filter(
    (Month %in% c("02", "10") & Year != "2022") |  #filtrage fevrier et octobre,sauf 2022
      (Year == "2022" & Month == "03")  #pour 2022 prendre moi de mars
  ) %>%
  group_by(Year, Month) %>%
  summarise(
    Date = max(Last_Update, na.rm = TRUE)  #selectioner la dernier date valable
  ) %>%
  ungroup() %>%
  arrange(Date)

#inclure la premier date de 2022
selected_dates <- selected_dates %>%
  add_row(Year = "2020", Month = "03", Date = min(european_data$Last_Update, na.rm = TRUE))

#filtrer european_data (df) par les dates selectionnes (de notre interet):
european_data_selected <- european_data %>%
  filter(Last_Update %in% selected_dates$Date) %>%
  mutate(Date = as.Date(Last_Update))

#somme des morts totales par date:
deaths_over_time <- european_data_selected %>%
  group_by(Date) %>%
  summarise(Total_Deaths = sum(Deaths, na.rm = TRUE)) %>%
  arrange(Date)

#création du graph intéractif avec plotly 
courbe_epidemique <- plot_ly(
  data = deaths_over_time,
  x = ~Date,  
  y = ~Total_Deaths,  
  type = 'scatter',  
  mode = 'lines+markers', 
  marker = list(size = 10, color = 'brown'), 
  line = list(color = 'orange', width = 2), 
  text = ~paste(
    "Date: ", Date, "<br>",
    "Morts totales: ", Total_Deaths
  ),  #info qui apparait quand on passe le curseur
  hoverinfo = "text"  #pour montrer cette info
) %>%
  layout(
    title = "Évolution des décès totales par COVID-19 à l'UE",
    xaxis = list(title = "Date"),
    yaxis = list(title = "Nombre total de morts"),
    hovermode = "closest"
  )

#print du graph:
courbe_epidemique

#-------------------------------------------------------------------------
#création de graph à barres empilées qui compare les cas confirmés avec les décès
#au moment de la derniere mise à jour

#filtrer pour obtenir la dernier mise à jour par pays
latest_data_confirmed <- european_data %>%
  group_by(Country_Region) %>%
  filter(Last_Update == max(Last_Update, na.rm = TRUE)) %>%
  ungroup()

#somme des cas confirmes par pays 
confirmed_by_country <- latest_data_confirmed %>%
  group_by(Country_Region, Last_Update) %>%
  summarise(
    Total_Confirmed = sum(Confirmed, na.rm = TRUE)  # Sumar los casos confirmados
  ) %>%
  ungroup()

#création d'une copie de latest_by_country
latest_by_country_with_confirmed <- latest_by_country %>%
  left_join(confirmed_by_country %>% select(Country_Region, Total_Confirmed), 
            by = "Country_Region")

library(plotly)
#preparation des donnes pour le grpahique interactif
stacked_bar_interactive <- latest_by_country_with_confirmed %>%
  gather(key = "Metric", value = "Count", Total_Deaths, Total_Confirmed)

graph_barres_empilées <- plot_ly(
  data = stacked_bar_interactive,
  x = ~Count,
  y = ~reorder(Country_Region, Count),  
  type = 'bar',
  orientation = 'h', 
  color = ~Metric,  #differencier par métrique cas/morts
  colors = c("Total_Deaths" = "brown", "Total_Confirmed" = "orange"),
  text = ~paste(
    "Pays: ", Country_Region, "<br>",
    "Métrique: ", ifelse(Metric == "Total_Deaths", "Morts totales", "Cas confirmés"), "<br>",
    "Nombre: ", Count
  ),
  hoverinfo = "text"  #montrer le texte personnalisée quand on passe le curseur 
) %>%
  layout(
    title = "Cas confirmés et morts par pays (UE)",
    xaxis = list(title = "Nombre"),
    yaxis = list(title = "Pays"),
    barmode = 'stack',  
    legend = list(title = list(text = "Métrique")),
    margin = list(l = 100)  
  )

#print du graphique
graph_barres_empilées

#-------------------------------------------------------------------------------

#instaler et charger le package DT si il y est pas
if (!require(DT)) install.packages("DT")
library(DT)

#preparer les donnees pour la table:
interactive_table <- latest_by_country_with_confirmed %>%
  select(
    Country_Region,        
    Population,         
    Total_Confirmed,    
    Total_Deaths,     
    Avg_Lat, Avg_Long   
  ) %>%
  arrange(desc(Total_Confirmed))

#création de la rable:
datatable(
  interactive_table,
  options = list(
    pageLength = 10,         #montrer 10 lignes par page
    autoWidth = TRUE,        
    dom = 'Bfrtip',          #barre de recherche
    buttons = c('copy', 'csv', 'excel', 'pdf', 'print')  #exportation des données
  ),
  class = 'cell-border stripe hover',  
  rownames = FALSE,                    
  caption = htmltools::tags$caption(
    style = 'caption-side: bottom; text-align: center;',
    "Tableau interactif des données COVID-19 pour les pays de l'Union Européenne"
  )
)



#--------------------------------------------------------------------------------
#Pour la création d'un dashboard je sauvegarde en locale les df necessaires:
save(
  latest_by_country,
  latest_by_country_with_confirmed,
  deaths_over_time, 
  stacked_bar_interactive, 
  interactive_table, 
  file = "dashboard_data.RData"
)














