#charger les donnes pour le dashboard
load("dashboard_data.RData")

library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(leaflet)

# UI du dashboard
ui <- dashboardPage(
  dashboardHeader(title = "Dashboard COVID-19 à l'Union Européenne"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Carte interactive", tabName = "map", icon = icon("globe")),
      menuItem("Évolution temporelle", tabName = "line", icon = icon("chart-line")),
      menuItem("Graphique par pays", tabName = "bar", icon = icon("bar-chart")),
      menuItem("Tableau interactif", tabName = "table", icon = icon("table"))
    )
  ),
  dashboardBody(
    tabItems(
      #onglet pour la carte:
      tabItem(tabName = "map",
              h2("Carte des morts par COVID-19"),
              plotlyOutput("map", height = 600)
      ),
      
      #onglet pour la courbe épidémique
      tabItem(tabName = "line",
              h2("Évolution des morts totales"),
              plotlyOutput("line_plot", height = 600)
      ),
      
      #onglet pour le graphique des barres empilées
      tabItem(tabName = "bar",
              h2("Cas confirmés et morts par pays"),
              plotlyOutput("bar_plot", height = 600)
      ),
      
      #onglet pour la table intéractive
      tabItem(tabName = "table",
              h2("Tableau interactif des données COVID-19"),
              DTOutput("table", height = 600)
      )
    )
  )
)

# Server dashboard
server <- function(input, output) {
  
  
  output$map <- renderPlotly({
    choropleth_map
  })
  
  
  output$line_plot <- renderPlotly({
    courbe_epidemique
  })
  
  
  output$bar_plot <- renderPlotly({
    graph_barres_empilées
  })
  
  
  output$table <- renderDT({
    datatable(
      interactive_table,
      options = list(
        pageLength = 10,
        autoWidth = TRUE,
        dom = 'Bfrtip',
        buttons = c('copy', 'csv', 'excel', 'pdf', 'print')
      ),
      class = 'cell-border stripe hover',
      rownames = FALSE
    )
  })
}

# execution du dashboard:
shinyApp(ui, server)
