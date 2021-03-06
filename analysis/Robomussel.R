#load libraries
library(plyr)
library(dplyr)
library(reshape2)
library(tidyr)

library(ggplot2)

source("./analysis/TempcyclesAnalysis.R")

#ROBOMUSSEL ANALYSIS

#SITES
# WaOr Tatoosh Island, WA 1660.1 48.39 124.74
# WaOr Boiler Bay, OR 1260.7 44.83 124.05
# WaOr Strawberry Hill, OR 1196 44.25 124.12
# CenCal Hopkins, CA 327.1 36.62 121.90
# CenCal Piedras Blancas, CA 208.11 35.66 121.28
# CenCal Cambria, CA 185.66 35.54 121.10
# SoCal Lompoc, CA 84.175 34.72 120.61
# SoCal Jalama, CA 57.722 34.50 120.50
# SoCal Alegria, CA 37.284 34.47 120.28
# SoCal Coal Oil Point (COP), CA 0 34.41 119.88

#-----------------
#Site data
site.dat= read.csv("./data//musselREADME.csv")

#Load robomussel data
te.max <- readRDS("./data/tedat.rds")
#te.max= read.csv("tedat.csv")

#Fix duplicate CP in WA
te.max[which(te.max$lat==48.45135),"site"]<-"CPWA"

#----------------------
#PLOTS

#Time series
#clim2 = clim2 %>% group_by(Year,Site) %>% summarise(Min= mean(Min, na.rm=TRUE),Max= mean(Max, na.rm=TRUE),Mean= mean(Mean, na.rm=TRUE) )

#count by site, subsite, year
te.count = te.max %>% group_by(year,site, subsite) %>% summarise( count=length(MaxTemp_C)  )
te.count= as.data.frame(te.count)

#subset sites
te.max2= subset(te.max, te.max$site %in% c("SD","BB","PD") ) # "HS",
#te.max2= subset(te.max, te.max$lat %in% c(48.39137,44.83064,35.66582,34.46717) )

# USWACC	48.5494	-123.0059667	Colins Cove
# USWACP	48.45135	-122.9617833	Cattle Point
#* USWASD	48.39136667	-124.7383667	Strawberry Point
#* USORBB	44.83064	-124.06005	Boiler Bay
#* USCAPD	35.66581667	-121.2867167	Piedras
# USCAAG	34.46716667	-120.2770333	Alegria


#time series
te.max1= subset(te.max2, te.max2$year==2002)

#restrict to summer
#May 1 through September: 121:273 
te.max1= subset(te.max1, te.max1$doy>120 & te.max1$doy<274)

#ggplot(data=te.max1, aes(x=doy, y = MaxTemp_C, color=subsite ))+geom_line() +theme_bw()+facet_wrap(~site)
#by tidal height
#ggplot(data=te.max1, aes(x=doy, y = MaxTemp_C, color=height ))+geom_line() +theme_bw()+facet_wrap(~site)

#FIG 1A
#by lat
fig2a<- ggplot(data=te.max1, aes(x=doy, y = MaxTemp_C, color=subsite ))+geom_line(alpha=0.8) +theme_bw()+
  facet_wrap(~lat, nrow=1)+ guides(color=FALSE)+labs(x = "Day of year",y="Maximum daily temperature (°C)")

# AJI - Applied lowess smoothing to see the trends.
fig2a_alt <-   te.max1 %>% as.data.frame() %>% ggplot(aes(doy,MaxTemp_C,group=subsite,color=subsite)) + 
  stat_smooth(se = FALSE) + 
  ggtitle("Maximum Temperatures by Latitude")+ theme_bw()+
  facet_wrap(~lat, nrow=1)+ guides(color=FALSE)+
  xlab("Day of year") + ylab("Maximum daily temperature (°C)")
#------------------
#FREQUENCY
# https://github.com/georgebiogeekwang/tempcycles/

#power spectrum
#x: frequency (1/days)
#y: log amplitude

fseq= exp(seq(log(0.001), log(1), length.out = 400))

sites= c("SD","BB","PD") #levels(te.max2$site)
subsites=  levels(te.max2$subsite)

pow.out= array(NA, dim=c(length(sites),length(subsites),length(fseq) ) )

for(site.k in 1:length(sites))
{
  te.dat= te.max2[which(te.max2$site==sites[site.k]),]
  subsites1= levels(te.dat$subsite)
  
  for(subsite.k in  1:length(subsites)) {
    te.dat1= te.dat[which(te.dat$subsite==subsites1[subsite.k]),]
    
    pow.out[site.k, subsite.k,] <- spec_lomb_phase(te.dat1$MaxTemp_C, te.dat1$j, freq=fseq)$cyc_range
      }
}

dimnames(pow.out)[[1]]<- sites
dimnames(pow.out)[[2]]<- 1:75

#to long format
for(site.k in 1:length(sites)){
  pow1= pow.out[site.k,,]
  pow1= na.omit(pow1)
  pow1m= melt(pow1)
  pow1m$site= sites[site.k]

  if(site.k==1)pow=pow1m
  if(site.k>1)pow=rbind(pow,pow1m)
}

colnames(pow)[1:3]=c("subsite","freq","cyc_range")

#correct freq values
pow$freq= fseq[pow$freq]

#sort by frequency
pow= pow[order(pow$site, pow$subsite, pow$freq),]
pow$subsite= factor(pow$subsite)

#freq, amp plot

#add latitude
site.dat1=  te.max %>% group_by(site) %>% summarise( lat=lat[1],zone=zone[1],tidal.height..m.=tidal.height..m.[1],substrate=substrate[1] )
match1= match(pow$site, site.dat1$site)
pow$lat= site.dat1$lat[match1]

fig2b<- ggplot(data=pow, aes(x=log(freq), y = log(cyc_range/2), color=subsite))+geom_line(alpha=0.8) +theme_classic()+facet_wrap(~lat, nrow=1)+ guides(color=FALSE)+
 geom_vline(xintercept=-2.639, color="gray")+geom_vline(xintercept=-1.946, color="gray")+geom_vline(xintercept=-3.40, color="gray")+geom_vline(xintercept=-5.9, color="gray")+
labs(x = "log (frequency) (1/days)",y="log (amplitude)")
  
#add lines for 1 week, 2 week, month, year

#===================================================
#Quilt plot

#round lat
te.max$lat.lab= round(te.max$lat,2)

#mean daily maximum by month
te.month = te.max %>% group_by(lat, month, lat.lab) %>% summarise( max=max(MaxTemp_C), mean.max=mean(MaxTemp_C), q75= quantile(MaxTemp_C, 0.75), q95= quantile(MaxTemp_C, 0.95) ) 

fig2<- ggplot(te.month) + 
  aes(x = month, y = as.factor(lat.lab) ) + 
  geom_tile(aes(fill = mean.max)) + 
  coord_equal()+
  scale_fill_gradientn(colours = rev(heat.colors(10)), name="temperature (°C)" )+
  #scale_fill_distiller(palette="Spectral", na.value="white", name="max temperature (°C)") + 
  theme_bw(base_size = 18)+xlab("month")+ylab("latitude (°)")+ theme(legend.position="bottom") #+ coord_fixed(ratio = 4)

#==================================================
# EXTREMES

library(ismev) #for gev
library(reshape)
library(maptools) #for mapping
library(evd) #for extremes value distributions
library(extRemes)
library(fExtremes) # generate gev

sites= levels(te.max$site) #c("SD","BB","PD")
subsites=  levels(te.max$subsite)

gev.out= array(NA, dim=c(length(sites),length(subsites),13 ) )

for(site.k in 1:length(sites))
{
  te.dat= te.max[which(te.max$site==sites[site.k]),]
  subsites1= levels(te.dat$subsite)
  
  for(subsite.k in  1:length(subsites)) {
    te.dat1= te.dat[which(te.dat$subsite==subsites1[subsite.k]),]
    
    #add site data
    gev.out[site.k, subsite.k,12]= te.dat1$lat[1]
    #gev.out[site.k, subsite.k,13]= te.dat1$height[1]
    
    #Generalized extreme value distribution
      dat1= na.omit(te.dat1$MaxTemp_C)  ##CHECK na.omit appropraite?
      
    if(length(dat1)>365){
        
    mod.gev<- try(gev.fit(dat1, show=FALSE) ) #stationary
    if(class(mod.gev)!="try-error") gev.out[site.k, subsite.k,1]<-mod.gev$nllh
    if(class(mod.gev)!="try-error") gev.out[site.k, subsite.k,2:4]<-mod.gev$mle #add another for non-stat
    if(class(mod.gev)!="try-error") gev.out[site.k, subsite.k,5]<-mod.gev$conv #add another for non-stat
    
    #Generalized pareto distribution, for number of times exceeds threshold
    thresh= 35
    
    #stationary
    mod.gpd <- try(gpd.fit(dat1, thresh, npy=365)) #stationary 
    if(class(mod.gpd)!="try-error") gev.out[site.k, subsite.k,6]<-mod.gpd$rate
    
   ## nonstationary 
   # try(mod.gpd<-gpd.fit(dat1, 40, npy=92, ydat=as.matrix(te.dat1$year), sigl=1),silent = FALSE) 
    
    #RETURN LEVELS:  MLE Fitting of GPD - package extRemes
    mpers= c(10,20,50,100)
    for(m in 1:length(mpers)){
      pot.day<- try( fpot(dat1, threshold=35, npp=365.25, mper=mpers[m], std.err = FALSE) )
    
      if(class(pot.day)!="try-error") gev.out[site.k, subsite.k,6+m]=pot.day$estimate[1]
    }
    
    #proportion above threshold
    if(class(pot.day)!="try-error") gev.out[site.k, subsite.k,11]=pot.day$pat
    
    } #end check time series
  } #end subsites
} #end sites

#-------------------------
#PLOT
pow.out=gev.out

dimnames(pow.out)[[1]]<- sites
dimnames(pow.out)[[2]]<- 1:19
dimnames(pow.out)[[3]]<- c("gev.nllh", "gev.loc", "gev.scale", "gev.shape", "conv", "rate", "return10", "return20", "return50", "return100","pat","lat","height")

#to long format
for(site.k in 1:length(sites)){
  pow1= pow.out[site.k,,]
  #pow1= na.omit(pow1)
  pow1m= melt(pow1)
  pow1m$site= sites[site.k]
  
  if(site.k==1)pow=pow1m
  if(site.k>1)pow=rbind(pow,pow1m)
}

#--------------------
# ADD SITE INFO
names(pow)[1:2]=c("subsite","var")

pow$ssite= paste(pow$site,pow$subsite, sep=".")

pow.site= subset(pow, pow$var=="lat")
pow.site= pow.site[!duplicated(pow.site$ssite),]

match1= match(pow$ssite, pow.site$ssite)
pow$lat= pow.site$value[match1]

#====================
## PLOT

#dimnames(pow.out)[[3]]<- c("gev.nllh", "gev.loc", "gev.scale", "gev.shape", "conv", "rate", "return10", "return20", "return50", "return100","pat", "lat","height")

pow1= pow[pow$var %in% c("gev.loc", "gev.scale", "gev.shape", "pat", "return100"),]

#get rid of return100 outlier for ploting purposes
pow1= subset(pow1, pow1$value<300)

#revise labels
pow1$var <- factor(pow1$var, labels = c("location", "scale", "shape", "percent above threshold", "100 year return"))

#ggplot(data=pow1, aes(x=site, y = value, color=subsite))+geom_point()+theme_bw()+facet_wrap(~var, scales="free_y")
fig4= ggplot(data=pow1, aes(x=as.factor(lat), y = value, color=subsite))+geom_point()+
  theme_bw()+theme(axis.text.x=element_blank())+facet_wrap(~var, scales="free_y")+ guides(color=FALSE)+xlab("latitude (°C)")
#as factor not latitude

#setwd("C:\\Users\\Buckley\\Google Drive\\Buckley\\Work\\ExtremesPhilTrans\\figures\\")

#file<-paste("AustGEV.pdf" ,sep="", collapse=NULL)
#pdf(file,height = 8, width = 11)


#dev.off()





