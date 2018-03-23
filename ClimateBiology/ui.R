library(leaflet)

# Use a fluid Bootstrap layout
fluidPage(    
  
  # Give the page a title
  titlePanel("Climate Biology"),
  
  # Generate a row with a sidebar
  sidebarLayout(      
    
    # Define the sidebar with one input
    sidebarPanel(
      checkboxGroupInput("sites", "Sites:", 
                  choices=unique(te.max$location),
                  selected = unique(te.max$location)[1]),
      hr(),
      helpText("Data from Helmuth et. al."), 
      hr(), 
      leafletOutput('map')
    ),
    
    # Create a spot for ggplot
    mainPanel(
      plotOutput("climbPlot", height="800px")  
    )
    
  )
)