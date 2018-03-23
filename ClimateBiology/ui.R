# Rely on the 'WorldPhones' dataset in the datasets
# package (which generally comes preloaded).


# Use a fluid Bootstrap layout
fluidPage(    
  
  # Give the page a title
  titlePanel("Climate Biology"),
  
  # Generate a row with a sidebar
  sidebarLayout(      
    
    # Define the sidebar with one input
    sidebarPanel(
      selectInput("sites", "Sites:", 
                  choices=unique(te.max1$site)),
      hr(),
      helpText("Data from Hemuth et. al.")
    ),
    
    # Create a spot for ggplot
    mainPanel(
      plotOutput("climbPlot")  
    )
    
  )
)