library(shiny)
library(ggplot2)
library(tibble)
library(magrittr)
library(tidyverse)
library(dplyr)
library(scales)
library(DT)


# Define UI ----
ui <- fluidPage(div(style="padding-left: 30px", 
                    titlePanel("Identifying People in Need During a Disaster")),
                
                # fluidRow (div(style="padding: 50px",
                #               dataTableOutput("table_tweets"))
                # )
               
                # Define the sidebar with one input
                sidebarPanel(
                  selectInput(inputId="var_disaster",
                              label = "Variable",
                              choices=c("Hurricane", "Fire"))
                ),

                mainPanel(dataTableOutput("table_tweets"))
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
  #output$table_tweets <- renderDataTable(Summary, options=list(info = FALSE, paging = FALSE, searching = FALSE))
  
  #reactive axis and labels
  output$table_tweets <- reactive({
    if ("Hurricane" %in% input$var_disaster) return(renderDataTable(Summary_hurricane))
    if ("Fire" %in% input$var_disaster) return(renderDataTable(Summary_fire))
  })

#   yaxis2_joe <- reactive({
#     if ( "Avg Engagements" %in% input$var_joe) return(averages_Type_Joe$Avg.engagements)
#     if ( "Avg Engagement Rate" %in% input$var_joe) return(averages_Type_Joe$Avg.engagement.rate)
#     if ( "Avg Clicks" %in% input$var_joe) return(averages_Type_Joe$Avg.clicks)
#     if ( "Total Engagements" %in% input$var_joe) return(averages_Type_Joe$Total.engagements)
#     if ( "Total Clicks" %in% input$var_joe) return(averages_Type_Joe$Total.clicks)
#   })
#   
#   graph_title_joe <- reactive({
#     if ( "Avg Engagements" %in% input$var_joe) return("Joe average engagements per tweet")
#     if ( "Avg Engagement Rate" %in% input$var_joe) return("Joe average engagement rate per tweet")
#     if ( "Avg Clicks" %in% input$var_joe) return("Joe average clicks per tweet")
#     if ( "Total Engagements" %in% input$var_joe) return("Joe total engagements per tweet")
#     if ( "Total Clicks" %in% input$var_joe) return("Joe total clicks per tweet")
#   })
#   
#   y_label <- reactive({
#     if ( "Avg Engagements" %in% input$var_joe) return("Avg engagements per tweet")
#     if ( "Avg Engagement Rate" %in% input$var_joe) return("Avg engagement rate per tweet")
#     if ( "Avg Clicks" %in% input$var_joe) return("Avg clicks per tweet")
#     if ( "Total Engagements" %in% input$var_joe) return("Total engagements per tweet")
#     if ( "Total Clicks" %in% input$var_joe) return("Total clicks per tweet")
#   })
#   
#   
#   output$plot1_joe <- renderPlot({
#     
#     # Render a barplot for content summary
#     ggplot(Summary_Content_Joe, aes(fill=Content, y=yaxis1_joe(), x=Content)) + 
#       geom_bar(position="dodge", stat="identity") +
#       labs(title=graph_title_joe(), caption="Data pulled from Twitter Analytics between 12/01/2018-01/31/2019")+
#       labs(y=y_label())
#   })
#   
#   
#   output$plot2_joe <- renderPlot({
#     
#     #render barplot by type
#     ggplot(averages_Type_Joe, aes(fill=Content, y=yaxis2_joe(), x=Type)) + 
#       geom_bar( stat="identity") + ggtitle("HITRECORD average clicks per tweet by post type") +
#       labs(title=graph_title_joe(), caption="Data pulled from Twitter Analytics between 12/01/2018-01/31/2019", y=y_label())
#     
#   })
#   
}

# Run the app ----
shinyApp(ui = ui, server = server)
  
  
  
  