library(dplyr)
library(reshape2)
library(tidyr)

library(ggplot2)

site.dat= read.csv("https://github.com/ajijohn/ClimateBiology/blob/master/data/musselREADME.csv")
#Load robomussel data
te.max <- readRDS("tedat.rds")

te.max <- readRDS("tedat.rds")
#count by site, subsite, year
te.count <- te.max %>% group_by(year,site, subsite) %>% summarise( count=length(MaxTemp_C)  )
te.count= as.data.frame(te.count)

#subset sites
te.max2 <- subset(te.max, te.max$site %in% c("SD","BB","PD") ) # "HS",
#te.max2= subset(te.max, te.max$lat %in% c(48.39137,44.83064,35.66582,34.46717) )

# USWACC	48.5494	-123.0059667	Colins Cove
# USWACP	48.45135	-122.9617833	Cattle Point
#* USWASD	48.39136667	-124.7383667	Strawberry Point
#* USORBB	44.83064	-124.06005	Boiler Bay
#* USCAPD	35.66581667	-121.2867167	Piedras
# USCAAG	34.46716667	-120.2770333	Alegria


#time series
te.max1<-subset(te.max2, te.max2$year==2002)

#restrict to summer
#May 1 through September: 121:273 
te.max1<-subset(te.max1, te.max1$doy>120 & te.max1$doy<274)