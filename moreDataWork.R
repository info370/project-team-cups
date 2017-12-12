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
if(!require(plyr)){install.packages("plyr"); require(plyr)} 
if(!require(shinyWidgets)){install.packages("shinyWidgets"); require(shinyWidgets)} 

total.no.years <- read.csv("./data/finalDataNoYears.csv")
all.data <- read.csv('./data/dataYears13to17.csv')
neighborhood.all.data <- read.csv("./data/neighborhoodAllData.csv")
zoneFar <- read_csv("./data/zoneFAR.csv")
colnames(zoneFar)[1] <- "Existing_Z"

##### SPLIT DATA INTO RESIDENTIAL AND COMMERCIAL ####

# Split into Residential, Commercial, Mixed Commercial + Residential, and Industrial Zoning
residential <- neighborhood.all.data %>% filter (ZONING == 'RSL/TC'| ZONING == 'SM/R-65'| ZONING == 'HR'| ZONING == 'SF 5000' | ZONING == 'LR3 PUD' | ZONING == 'LR3')
mixedCommercialRes <- neighborhood.all.data %>% filter(ZONING == 'SM-NR 55/75 2.0'| ZONING == 'SM-NR-85'| ZONING == 'MR-RC'| ZONING == 'LR1' | ZONING == 'LR2 RC' | ZONING == 'LR3 RC')
industrial <- neighborhood.all.data %>% filter(ZONING == 'IC-65'| ZONING == 'IC-45')
commercial <- neighborhood.all.data %>% filter(ZONING == 'NC3-40'| ZONING == 'NC3P-40' | ZONING == 'NC2P-40' | ZONING == 'NC2P-30' | ZONING == 'NC2-40' | ZONING == 'NC3-65' | ZONING == 'NC3-65' | ZONING == 'NC3P-85 5.75' | ZONING == 'NC3P-65' | ZONING == 'NC1-40' | ZONING == 'NC1-65' | ZONING == 'NC1-30' | ZONING == 'NC3P-85' | ZONING == 'C1-65' | ZONING == 'C2-65'| ZONING == 'C1-40' | ZONING == 'NC2-65' | ZONING == 'NC2P-65' | ZONING == 'NC1P-30' | ZONING == 'NC3-85' | ZONING == 'NC3-125' | ZONING == 'NC2P-65 4.0'| ZONING == 'NC3-65 2.0'| ZONING == 'NC2P-65 3.0' |  ZONING == 'NC3P-85 2.0' | ZONING == 'NC3P-85 2.0' | ZONING == 'NC3P-85 2.0'| ZONING == 'NC3P-65 2.0' | ZONING == 'NC3P-65 4.0' | ZONING == 'NC3-30' | ZONING == 'C2-30'| ZONING == 'NC2-30' | ZONING == 'NC1P-40' | ZONING == 'C2-40'| ZONING == 'NC3P-65 3.0'| ZONING == 'NC3P-85 4.75' | ZONING == 'NC3-85 4.75' | ZONING == 'NC3P-160' | ZONING == 'NC2P-65 0.75' | ZONING == 'C1-30' | ZONING == 'C1-40 0.75')

residential <- join(residential, zoneFar, by="Existing_Z", type="inner")
residential <- residential[residential$TotalVal<=10000000,]
mixedCommercialRes <- join(mixedCommercialRes, zoneFar, by="Existing_Z", type="inner")
industrial <- join(industrial, zoneFar, by="Existing_Z", type="inner")
commercial <- join(commercial, zoneFar, by="Existing_Z", type="inner")


## RESIDENTIAL MODEL ###
split_proportion = 0.8
outcome <- residential %>% dplyr::select(TotalVal)
train_ind <- createDataPartition(outcome$TotalVal, p = split_proportion, list = FALSE)
mha_train <- residential[train_ind,] 
mha_test <- residential[-train_ind,] 

mha_test_x <- residential %>% dplyr::select(-TotalVal) 
mha_test_y <- residential %>% dplyr::select(TotalVal)

ctrl <- trainControl(method = "cv", number=5) 

# Train model
mha_model_lm <- train(TotalVal ~ RollYr + CurrentZoning + LOTSQFT + UV_NAME + FAR, 
                      data = residential, 
                      method = "lm", 
                      trControl=ctrl) 

mha_model_lm$finalModel

predict_mha_lm <- predict(mha_model_lm, mha_test_x)
postResample(predict_mha_lm, mha_test_y$TotalVal)
grid <- mha_test %>% gather_predictions(mha_model_lm)
residual <- resid(mha_model_lm)

# residuals 
plot(resid(mha_model_lm))
# We have demonstrated by looking at residuals that our model for residential housing could be improved


## MIX COMMERCIAL RES ##
split_proportion = 0.8
outcome_MCR <- mixedCommercialRes %>% dplyr::select(TotalVal)
train_ind_MCR <- createDataPartition(outcome$TotalVal, p = split_proportion, list = FALSE)
MCR_train <- mixedCommercialRes[train_ind,] 
MCR_test <- mixedCommercialRes[-train_ind,] 

MCR_test_x <- mixedCommercialRes %>% dplyr::select(-TotalVal) 
MCR_test_y <- mixedCommercialRes %>% dplyr::select(TotalVal)

ctrl <- trainControl(method = "cv", number=5) 

# Train model
MCR_model_lm <- train(TotalVal ~ RollYr + CurrentZoning + LOTSQFT + UV_NAME + FAR, 
                      data = mixedCommercialRes, 
                      method = "lm", 
                      trControl=ctrl) 

MCR_model_lm$finalModel

predict_MCR_lm <- predict(MCR_model_lm, MCR_test_x)
postResample(predict_MCR_lm, MCR_test_y$TotalVal)
grid_MCR <- MCR_test %>% gather_predictions(MCR_model_lm)
residual_MCR <- resid(MCR_model_lm)

# residuals 
plot(resid(MCR_model_lm))

## INDUSTRIAL ##
split_proportion = 0.8
outcome_indus <- industrial %>% dplyr::select(TotalVal)
train_ind_indus <- createDataPartition(outcome$TotalVal, p = split_proportion, list = FALSE)
indus_train <- industrial[train_ind,] 
indus_test <- industrial[-train_ind,] 

indus_test_x <- industrial %>% dplyr::select(-TotalVal) 
indus_test_y <- industrial %>% dplyr::select(TotalVal)

ctrl <- trainControl(method = "cv", number=5) 

# Train model
indus_model_lm <- train(TotalVal ~ RollYr + CurrentZoning + LOTSQFT + UV_NAME + FAR, 
                        data = industrial, 
                        method = "lm", 
                        trControl=ctrl) 

indus_model_lm$finalModel

predict_indus_lm <- predict(indus_model_lm, indus_test_x)
postResample(predict_indus_lm, indus_test_y$TotalVal)
grid_indus <- indus_test %>% gather_predictions(indus_model_lm)
residual_indus <- resid(indus_model_lm)

# residuals 
plot(resid(indus_model_lm))

## COMMERCIAL ##
split_proportion = 0.8
outcome_com <- commercial %>% dplyr::select(TotalVal)
train_ind_com <- createDataPartition(outcome$TotalVal, p = split_proportion, list = FALSE)
com_train <- commercial[train_ind,] 
com_test <- commercial[-train_ind,] 

com_test_x <- commercial %>% dplyr::select(-TotalVal) 
com_test_y <- commercial %>% dplyr::select(TotalVal)

ctrl <- trainControl(method = "cv", number=5) 

# Train model
com_model_lm <- train(TotalVal ~ RollYr + CurrentZoning + LOTSQFT + UV_NAME + FAR, 
                      data = commercial, 
                      method = "lm", 
                      trControl=ctrl) 

com_model_lm$finalModel

predict_com_lm <- predict(com_model_lm, com_test_x)
postResample(predict_com_lm, com_test_y$TotalVal)
grid_com <- com_test %>% gather_predictions(com_model_lm)
residual_com <- resid(com_model_lm)

# residuals 
plot(resid(com_model_lm))


### PREDICTING RESIDENTIAL ####

# Rezone
reZonePrediction <- function() {
  residentialfuture <- residential %>% filter(RollYr == '2017')
  residential2017 <-residential %>% filter(RollYr == '2017')
  residentialfuture$RollYr <- 2018
  residentialfuture$MHA_ZONING <- gsub("M1", "", residentialfuture$MHA_ZONING)
  residentialfuture$MHA_ZONING <- gsub("[(M)]", "", residentialfuture$MHA_ZONING)
  residentialfuture$MHA_ZONING <- gsub("[()]", "", residentialfuture$MHA_ZONING)
  
  residentialfuture$ZONING <- residentialfuture$MHA_ZONING 
  
  totalfuture <- rbind(residentialfuture, residential)
  mha_test_x <- totalfuture %>% dplyr::select(-TotalVal) 
  mha_test_y <- totalfuture %>% dplyr::select(TotalVal)
  
  predict_mha_lm <- predict(mha_model_lm, mha_test_x)
  postResample(predict_mha_lm, mha_test_y$TotalVal)
  grid <- totalfuture %>% gather_predictions(mha_model_lm)
  return(grid)
}


# Residential No Rezone
noRezonePredictionRes <- function() {
  residentialNoZone <- residential %>% filter(RollYr == '2017')
  residentialNoZone$RollYr <- 2018
  residentialNoZone$MHA_ZONING <- gsub("M1", "", residentialNoZone$MHA_ZONING)
  residentialNoZone$MHA_ZONING <- gsub("[(M)]", "", residentialNoZone$MHA_ZONING)
  residentialNoZone$MHA_ZONING <- gsub("[()]", "", residentialNoZone$MHA_ZONING)  
  
  mha_test_xResNoZone <- residentialNoZone %>% dplyr::select(-TotalVal) 
  mha_test_yResNoZone <- residentialNoZone %>% dplyr::select(TotalVal)
  
  predict_mha_lmResNoZone <- predict(mha_model_lm, mha_test_xResNoZone)
  postResample(predict_mha_lmResNoZone, mha_test_yResNoZone$TotalVal)
  gridResNoZone <- residentialNoZone %>% gather_predictions(mha_model_lm)
  
  gridResNoZone$TotalVal <- gridResNoZone$pred
  gridResNoZone <- gridResNoZone[,2:25]
  totalResNoZone <- rbind(gridResNoZone, residential)
  return(totalResNoZone)
}


### MIXED COMMERCIAL AND RESIDENTIAL PREDICTIONS ####

# Mixed no rezone
mixedNoRezone <- function() {
  mixNoZone <- mixedCommercialRes %>% filter(RollYr == '2017')
  mixNoZone$RollYr <- 2018
  mixNoZone$MHA_ZONING <- gsub("M1", "", mixNoZone$MHA_ZONING)
  mixNoZone$MHA_ZONING <- gsub("[(M)]", "", mixNoZone$MHA_ZONING)
  mixNoZone$MHA_ZONING <- gsub("[()]", "", mixNoZone$MHA_ZONING)  
  
  mha_test_xMixNoZone <- mixNoZone %>% dplyr::select(-TotalVal) 
  mha_test_yMixNoZone <- mixNoZone %>% dplyr::select(TotalVal)
  
  predict_mha_lmMixNoZone <- predict(MCR_model_lm, mha_test_xMixNoZone)
  postResample(predict_mha_lmMixNoZone, mha_test_yMixNoZone$TotalVal)
  gridMixNoZone <- mixNoZone %>% gather_predictions(MCR_model_lm)
  
  gridMixNoZone$TotalVal <- gridMixNoZone$pred
  gridMixNoZoned <- gridMixNoZone[,2:25]
  totalMixNoZone <- rbind(gridMixNoZoned, mixedCommercialRes)
  return(totalMixNoZone)
}

# Mixed with Rezone
mixedRezone <- function() {
  mixRezone <-mixedCommercialRes %>% filter(RollYr == '2017')
  mixRezone$RollYr <- 2018
  mixRezone$MHA_ZONING <- gsub("M1", "", mixRezone$MHA_ZONING)
  mixRezone$MHA_ZONING <- gsub("[(M)]", "", mixRezone$MHA_ZONING)
  mixRezone$MHA_ZONING <- gsub("[()]", "", mixRezone$MHA_ZONING)
  
  mixRezone$Existing_Z <- mixRezone$MHA_ZONING 
  mha_test_xRezone <- mixRezone %>% dplyr::select(-TotalVal) 
  mha_test_yRezone <- mixRezone %>% dplyr::select(TotalVal)
  
  predict_mha_lmRezone <- predict(MCR_model_lm, mha_test_xRezone)
  postResample(predict_mha_lmRezone, mha_test_yRezone$TotalVal)
  gridRezone <- mixRezone %>% gather_predictions(MCR_model_lm)
  
  gridRezone$TotalVal <- gridRezone$pred
  gridRezone <- gridRezone[,2:25]
  totalMixRezone <- rbind(gridRezone, mixedCommercialRes)
  return(totalMixRezone)
}

# No Rezone Commercial
commercialNoRezone <- function() {
  commercialNoZone <- commercial %>% filter(RollYr == '2017')
  commercialNoZone$RollYr <- 2018
  commercialNoZone$MHA_ZONING <- gsub("M1", "", commercialNoZone$MHA_ZONING)
  commercialNoZone$MHA_ZONING <- gsub("[(M)]", "", commercialNoZone$MHA_ZONING)
  commercialNoZone$MHA_ZONING <- gsub("[()]", "", commercialNoZone$MHA_ZONING)  
  
  mha_test_xComNoZone <- commercialNoZone %>% dplyr::select(-TotalVal) 
  mha_test_yComNoZone <- commercialNoZone %>% dplyr::select(TotalVal)
  
  predict_mha_lmComNoZone <- predict(com_model_lm, mha_test_xComNoZone)
  postResample(predict_mha_lmComNoZone, mha_test_yComNoZone$TotalVal)
  gridComNoZone <- commercialNoZone %>% gather_predictions(com_model_lm)
  
  gridComNoZone$TotalVal <- gridComNoZone$pred
  gridComNoZoned <- gridComNoZone[,2:25]
  totalComNoZone <- rbind(gridComNoZoned, commercial)
  return(totalComNoZone)
}

# Commercial Rezone
commercialRezone <- function() {
  comRezone <-commercial %>% filter(RollYr == '2017')
  comRezone$RollYr <- 2018
  comRezone$MHA_ZONING <- gsub("M1", "", comRezone$MHA_ZONING)
  comRezone$MHA_ZONING <- gsub("[(M)]", "", comRezone$MHA_ZONING)
  comRezone$MHA_ZONING <- gsub("[()]", "", comRezone$MHA_ZONING)
  
  comRezone$ZONING <- comRezone$MHA_ZONING 
  mha_test_xComRezone <- comRezone %>% dplyr::select(-TotalVal) 
  mha_test_ComRezone <- comRezone %>% dplyr::select(TotalVal)
  
  predict_mha_lmComRezone <- predict(com_model_lm, mha_test_xComRezone)
  postResample(predict_mha_lmComRezone, mha_test_ComRezone$TotalVal)
  gridComRezone <- comRezone %>% gather_predictions(com_model_lm)
   
  gridComRezone$TotalVal <- gridComRezone$pred
  gridComRezone <- gridComRezone[,2:25]
  totalComRezone <- rbind(gridComRezone, commercial)
  return(totalComRezone)
}



## Industrial No Rezone
# No Rezone Commercial
industrialNoRezone <- function() {
  industrialNoZone <- industrial %>% filter(RollYr == '2017')
  industrialNoZone$RollYr <- 2018
  industrialNoZone$MHA_ZONING <- gsub("M1", "", industrialNoZone$MHA_ZONING)
  industrialNoZone$MHA_ZONING <- gsub("[(M)]", "", industrialNoZone$MHA_ZONING)
  industrialNoZone$MHA_ZONING <- gsub("[()]", "", industrialNoZone$MHA_ZONING)  
  
  mha_test_xIndNoZone <- industrialNoZone %>% dplyr::select(-TotalVal) 
  mha_test_yIndNoZone <- industrialNoZone %>% dplyr::select(TotalVal)
  
  predict_mha_lmIndNoZone <- predict(indus_model_lm, mha_test_xIndNoZone)
  postResample(predict_mha_lmIndNoZone, mha_test_yIndNoZone$TotalVal)
  gridIndNoZone <- industrialNoZone %>% gather_predictions(indus_model_lm)
  
  gridIndNoZone$TotalVal <- gridIndNoZone$pred
  gridIndNoZone <- gridIndNoZone[,2:25]
  totalIndNoZone <- rbind(gridIndNoZone, industrial)
  return(totalIndNoZone)
}


# Commercial Rezone
industrialRezone <- function() {
  indRezone <-industrial %>% filter(RollYr == '2017')
  indRezone$RollYr <- 2018
  indRezone$MHA_ZONING <- gsub("M1", "", indRezone$MHA_ZONING)
  indRezone$MHA_ZONING <- gsub("[(M)]", "", indRezone$MHA_ZONING)
  indRezone$MHA_ZONING <- gsub("[()]", "", indRezone$MHA_ZONING)
  
  indRezone$ZONING <- indRezone$MHA_ZONING 
  mha_test_xIndRezone <- indRezone %>% dplyr::select(-TotalVal) 
  mha_test_yIndRezone <- indRezone %>% dplyr::select(TotalVal)
  
  predict_mha_lmIndRezone <- predict(indus_model_lm, mha_test_xIndRezone)
  postResample(predict_mha_lmIndRezone, mha_test_yIndRezone$TotalVal)
  gridIndRezone <- indRezone %>% gather_predictions(indus_model_lm)
  
  gridIndRezone$TotalVal <- gridIndRezone$pred
  gridIndRezone <- gridIndRezone[,2:25]
  totalIndRezone <- rbind(gridIndRezone, industrial)
  return(totalIndRezone)
}


## Predict an Address
PredictAddressSalePrice <- function(address) {
  address <- toupper(address)
  data <- neighborhood.all.data %>% filter(ADDR_FULL == address)
  if (data$ZONING == 'RSL/TC'| data$ZONING == 'SM/R-65'| data$ZONING == 'HR'| data$ZONING == 'SF 5000' | data$ZONING == 'LR3 PUD' | data$ZONING == 'LR3' ) {
    model <- mha_model_lm
  } else if (data$ZONING == 'SM-NR 55/75 2.0'| data$ZONING == 'SM-NR-85'| data$ZONING == 'MR-RC'| data$ZONING == 'LR1' | data$ZONING == 'LR2 RC' | data$ZONING == 'LR3 RC') {
    model <- MCR_model_lm
  } else  if (data$ZONING == 'IC-65'| data$ZONING == 'IC-45'){
    model <- indus_model_lm
  } else if (data$ZONING == 'NC3-40'| data$ZONING == 'NC3P-40' | data$ZONING == 'NC2P-40' | data$ZONING == 'NC2P-30' | data$ZONING == 'NC2-40' | data$ZONING == 'NC3-65'
             | data$ZONING == 'NC3-65' | data$ZONING == 'NC3P-85 5.75' | data$ZONING == 'NC3P-65' | data$ZONING == 'NC1-40' | data$ZONING == 'NC1-65' | data$ZONING == 'NC1-30' |
             data$ZONING == 'NC3P-85' | data$ZONING == 'C1-65' | data$ZONING == 'C2-65'| data$ZONING == 'C1-40' | data$ZONING == 'NC2-65' | data$ZONING == 'NC2P-65' | data$ZONING == 'NC1P-30' 
             | data$ZONING == 'NC3-85' | data$ZONING == 'NC3-125' | data$ZONING == 'NC2P-65 4.0'| data$ZONING == 'NC3-65 2.0'| data$ZONING == 'NC2P-65 3.0' |  data$ZONING == 'NC3P-85 2.0' 
             | data$ZONING == 'NC3P-85 2.0' | data$ZONING == 'NC3P-85 2.0'| data$ZONING == 'NC3P-65 2.0' | data$ZONING == 'NC3P-65 4.0' | data$ZONING == 'NC3-30' | data$ZONING == 'C2-30'
             | data$ZONING == 'NC2-30' | data$ZONING == 'NC1P-40' | data$ZONING == 'C2-40'| data$ZONING == 'NC3P-65 3.0'| data$ZONING == 'NC3P-85 4.75' | data$ZONING == 'NC3-85 4.75' 
             | data$ZONING == 'NC3P-160' | data$ZONING == 'NC2P-65 0.75' | data$ZONING == 'C1-30' | data$ZONING == 'C1-40 0.75'){
    model <- com_model_lm
  }
    
  data <- data %>% filter(ADDR_FULL == address)
  data <- join(data, zoneFar, by="Existing_Z", type="inner")  
  yr2017 <- data %>% filter(RollYr == '2017')
  yr2017$RollYr <- 2018
  yr2017$ZONING <- yr2017$MHA_ZONING 
  future <- rbind(data, yr2017)
  future$ZONING <- gsub("M1", "", future$ZONING)
  future$ZONING <- gsub("[(M)]", "", future$ZONING)
  future$ZONING <- gsub("[()]", "", future$ZONING)
  
  mha_test_x <- future %>% dplyr::select(-TotalVal) 
  mha_test_y <- future %>% dplyr::select(TotalVal)
  
  predict_mha_lm <- predict(model, mha_test_x)
  postResample(predict_mha_lm, mha_test_y$TotalVal)
  grid <- future %>% gather_predictions(model)
  grid$RollYr <- as.numeric(grid$RollYr)
  return(grid)
}

