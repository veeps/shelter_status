library(shiny)
library(ggplot2)
library(tibble)
library(magrittr)
library(tidyverse)
library(dplyr)
library(scales)
library(maps)
library(mapproj)


# Define UI ----
ui <- fluidPage(div(style="padding-left: 30px", 
                    titlePanel("Identifying People in Need During a Disaster")),
                
                # fluidRow (div(style="padding: 50px",
                #               dataTableOutput("table_tweets"))
                # )
               
                # Define the sidebar with one input
                sidebarPanel(
                  selectInput(inputId="var_disaster",
                              label = "Disaster Type",
                              choices=c("Hurricane", "Fire"))
                ),

                mainPanel(dataTableOutput("table_tweets")
                ),
                
                fluidRow (plotOutput("us_map", width = "950px", height = "600px"))
)


# Define server logic ----
server <- function(input, output) {
  
  #read in data file
  df <- read_csv("../Data/location_data.csv") %>%
    as_data_frame() 
  
  # #get summary table for hurricane
  Summary_hurricane <- df %>%
    filter(disaster == "hurricane") %>%
    filter(requesting_help == 1) %>%
    select(
      screen_name, text, location
    ) %>%
    distinct()
    
  # #get summary table for fire
    Summary_fire <- df %>%
      filter(disaster == "fire") %>%
    filter(requesting_help == 1) %>%
      select(
        screen_name, text, location
      ) %>%
      distinct()


  
  #render data table
  output$table_tweets <- renderDataTable(var_disaster(), options=list(info = FALSE, paging = FALSE, searching = FALSE))
  
  #reactive axis and labels
  var_disaster <- reactive({
    if ("Hurricane" %in% input$var_disaster) return(Summary_hurricane)
    if ("Fire" %in% input$var_disaster) return(Summary_fire)
  })
  
  var_map <- reactive({
    if ("Hurricane" %in% input$var_disaster) return(df %>% filter(disaster == "hurricane") %>% filter(requesting_help == 1))
    if ("Fire" %in% input$var_disaster) return(df %>% filter(disaster == "fire") %>% filter(requesting_help == 1))
  })


  output$us_map <- renderPlot({

    # Render a map of tweet locations
    albers_proj<-maps::map("state", proj="albers", param=c(50, 45), 
                           col="#999999", fill=FALSE, bg="#ffffff", lwd=1, add=FALSE, resolution=1)
    
    # Filter for US locations
    american_results<-subset(var_map(),
                             grepl(", USA", df$Location)==TRUE)
    
    points(mapproject(american_results$lng, american_results$lat), col=NA, bg="#72dda5",  pch=21, cex=2.0)
    
  })
  
}

# Run the app ----
shinyApp(ui = ui, server = server)
  
  
  
  