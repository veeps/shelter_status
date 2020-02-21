library(maps)
library(mapproj)
library(tidyr)
library(ggplot2)
library(tibble)
library(magrittr)
library(purrr)
library(data.table)
library(dplyr)

### Read in clean data
tweets <- read.csv("../Data/requesting_help.csv", stringsAsFactors = FALSE) %>%
  as_tibble()

head(tweets)

#Install key package helpers:
source("https://raw.githubusercontent.com/LucasPuente/geocoding/master/geocode_helpers.R")
#Install modified version of the geocode function
#(that now includes the api_key parameter):
source("https://raw.githubusercontent.com/LucasPuente/geocoding/master/modified_geocode.R")


#specify what I'm extracting from Googlemap API

geocode_apply<-function(x){
  geocode(x, source = "google", output = "all", api_key="FILL")
}

#geocode user locations
geocode_results<-sapply(tweets$location, geocode_apply, simplify = F)
length(geocode_results)
class(geocode_results)

##cleaning geocode
condition_a <- sapply(geocode_results, function(x) x["status"]=="OK")
geocode_results_a<-geocode_results[condition_a] #remove everything without status OK
length(geocode_results_a)

condition_b <- lapply(geocode_results, lapply, length)
condition_b2<-sapply(condition_b, function(x) x["results"]=="1") #remove everything with status ANY
geocode_results<-geocode_results[condition_b2]
length(geocode_results)


## clean misformatting
source("https://raw.githubusercontent.com/LucasPuente/geocoding/master/cleaning_geocoded_results.R")
results_b<-lapply(geocode_results, as.data.frame)


results_c <-lapply(results_b,function(x) subset(x, select=c("results.formatted_address",
                                                            "results.geometry.location")))

results_d<-lapply(results_c,function(x) data.frame(Location=x[1,"results.formatted_address"],
                                                   lat=x[1,"results.geometry.location"],
                                                   lng=x[2,"results.geometry.location"]))

results_e<-rbindlist(results_d)

#add in original location column
results_f<-results_e[,location:=names(results_d)]


results_tweets <- results_f %>% inner_join(tweets)

#write results into CSV for future
write.csv(results_tweets, file="../location_data.csv")


#filter for US locations only
american_results<-subset(results_f,
                         grepl(", USA", results_f$Location)==TRUE)


#generate blank map
albers_proj<-maps::map("state", proj="albers", param=c(39, 45), 
                 col="#999999", fill=FALSE, bg="#ffffff", lwd=0.5, add=FALSE, resolution=1)

#add points to map
points(mapproject(american_results$lng, american_results$lat), col=NA, bg="#D3D3D3", pch=21, cex=1.0)
