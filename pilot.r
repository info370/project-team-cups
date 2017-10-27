library(dplyr)

# reading data and cleaning out rows with NA values
food.info <- read.csv('food.csv', stringsAsFactors = FALSE)
no.na.food <- na.omit(food.info)
no.na.food$Cost <- as.numeric(as.character(no.na.food$Cost))

# total HFS spends on food
total.sum <- sum(no.na.food$Cost)

# types of food categories
categories <- unique(no.na.food$Category)

# percentage of food that is local
all.local <- no.na.food %>% select(Category, Vendor, Local, Fair, Ecological, Humane, Cost, Facility) %>% filter(Local == 'yes')
sum.all.local <- sum(all.local$Cost)
local.percentage <- (sum.all.local/total.sum) * 100
# 14.45879 % of total expenditure is Local

# percentage of food that is fair trade
all.fair <- no.na.food %>% select(Category, Vendor, Local, Fair, Ecological, Humane, Cost, Facility) %>% filter(Fair == 'yes')
sum.all.fair <- sum(all.fair$Cost)
fair.percentage <- (sum.all.fair/total.sum) * 100
# O% of total expenditure is fair trade food

# percentage of food that is ecological
all.ecological <- no.na.food %>% select(Category, Vendor, Local, Fair, Ecological, Humane, Cost, Facility) %>% filter(Ecological == 'yes')
sum.all.ecological <- sum(all.ecological$Cost)
ecological.percentage <- (sum.all.ecological/total.sum) * 100
# 9.026991 % of total expenditure is ecological food

# percentage of food that is humane
all.humane <- no.na.food %>% select(Category, Vendor, Local, Fair, Ecological, Humane, Cost, Facility) %>% filter(Humane == 'yes')
sum.all.humane <- sum(all.humane$Cost)
humane.percentage <- (sum.all.humane/total.sum) * 100
# 5.696258 % of total expenditure is humane food

#sum of all four, percentage that takes up
sum.all.four <- sum.all.ecological + sum.all.fair + sum.all.local + sum.all.humane
total.expenditure <- (sum.all.four/total.sum) * 100

# percentage that local, ecological, and humane 
three.req <- no.na.food %>% select(Category, Vendor, Local, Fair, Ecological, Humane, Cost, Facility) %>% filter(Ecological == 'yes' & Humane == 'yes' & Local == 'yes')
sum.all.three <- sum(three.req$Cost)
eco.local.humane <- (sum.all.three/total.sum) * 100
# dairy from the Medosweet vendor is local, humane, and ecological. It takes up 0.2870039 % of expenditure on food