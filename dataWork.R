if(!require(mlbench)){install.packages("mlbench"); require(mlbench)} 
if(!require(tidyverse)){install.packages("tidyverse"); library(tidyverse)} 
if(!require(modelr)){install.packages("modelr"); library(modelr)} 
if(!require(ModelMetrics)){install.packages("ModelMetrics"); require(ModelMetrics)}
if(!require(recipes)){install.packages("recipes"); require(recipes)}
if(!require(DEoptimR)){install.packages("DEoptimR"); require(DEoptimR)}
if(!require(caret)){install.packages("caret"); require(caret)}
if(!require(dplyr)){install.packages("dplyr"); require(dplyr)}
if(!require(gam)){install.packages("gam"); require(gam)} 
if(!require(prophet)){install.packages("prophet"); require(prophet)} 
if(!require(plotly)){install.packages("plotly"); require(plotly)} 
if(!require(shinycssloaders)){install.packages("shinycssloaders"); require(shinycssloaders)} 

HomePrices <- read_csv("./data/Neighborhood_Zhvi_AllHomes.csv")
all.homes <- HomePrices %>% filter(City == 'Seattle')

PredictNeighborhoodSalePrice <- function(neighborhood) {
  data <- all.homes %>% filter(RegionName == neighborhood)
  getCol <- data[,8:266]
  names <- colnames(getCol)
  prices <- as.numeric(getCol[1,])
  newdata <- data.frame(names,prices)
  colnames(newdata) <- c("ds", "y")
  newdata$ds <- as.Date(paste(newdata$ds,"-01",sep=""))
  
  model <- prophet(newdata)
  future <- make_future_dataframe(model, periods = 60, freq = "month")
  forecast <- predict(model, future) %>% select(ds, yhat) 
  forecast$ds <- as.Date(forecast$ds)
  
  join.data <- left_join(forecast, newdata, by = "ds")
  colnames(join.data) <- c("Date", "Predicted", "Actual")
  return(join.data)
}

