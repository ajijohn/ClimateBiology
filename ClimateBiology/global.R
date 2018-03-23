library(dplyr)
library(reshape2)
library(tidyr)

library(ggplot2)

site.dat= read.csv("https://github.com/ajijohn/ClimateBiology/blob/master/data/musselREADME.csv")
#Load robomussel data
te.max <- readRDS("tedat.rds")

#Load meta for names
te.meta <- read.csv("musselREADME.csv")
te.meta = te.meta %>% mutate(location=paste0(location, ", ", region))
namemap = unique(te.meta[,c("location", "latitude")])

# add location names
te.max = te.max %>% left_join(namemap, c('lat' = 'latitude'))

#count by site, subsite, year
te.count <- te.max %>% group_by(year,site, subsite) %>% summarise( count=length(MaxTemp_C)  )
te.count= as.data.frame(te.count)

#time series
te.max<-subset(te.max, te.max$year==2002)

#restrict to summer
#May 1 through September: 121:273 
te.max <-subset(te.max, te.max$doy>120 & te.max$doy<274)