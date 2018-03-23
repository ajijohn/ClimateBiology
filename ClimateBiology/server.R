#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(reshape2)
library(tidyr)

library(ggplot2)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  # te.max <- readRDS("tedat.rds")
  # #count by site, subsite, year
  # te.count <- te.max %>% group_by(year,site, subsite) %>% summarise( count=length(MaxTemp_C)  )
  # te.count= as.data.frame(te.count)
  # 
  # #subset sites
  # te.max2 <- subset(te.max, te.max$site %in% c("SD","BB","PD") ) # "HS",
  # #te.max2= subset(te.max, te.max$lat %in% c(48.39137,44.83064,35.66582,34.46717) )
  # 
  # # USWACC	48.5494	-123.0059667	Colins Cove
  # # USWACP	48.45135	-122.9617833	Cattle Point
  # #* USWASD	48.39136667	-124.7383667	Strawberry Point
  # #* USORBB	44.83064	-124.06005	Boiler Bay
  # #* USCAPD	35.66581667	-121.2867167	Piedras
  # # USCAAG	34.46716667	-120.2770333	Alegria
  # 
  # 
  # #time series
  # te.max1<-subset(te.max2, te.max2$year==2002)
  # 
  # #restrict to summer
  # #May 1 through September: 121:273 
  # te.max1<-subset(te.max1, te.max1$doy>120 & te.max1$doy<274)
  
  output$climbPlot <- renderPlot({
    
    ggplot(data=subset(te.max1, te.max1$site %in% c(input$sites)), aes(x=doy, y = MaxTemp_C, color=subsite))+geom_line(alpha=0.8) +
           theme_bw() + guides(color=FALSE)+labs(x = "Day of year",y="Maximum daily temperature (°C)") + ggtitle(paste(input$sites))
    
  })
  
})
