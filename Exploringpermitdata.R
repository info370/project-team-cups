data = read.csv("/Users/nathanbombardier/Downloads/Building_Permits___Current.csv")
View(data)

library(dplyr)

data.demo <- filter(data, Permit.Type == 'Demolition')
?as.Date
data.demo$appYear <- format(as.Date(data.demo$Application.Date, format="%m/%d/%Y"),"%Y")

View(data.demo)

data.demo.count <- count(data.demo, appYear) %>% 
       filter(appYear >= 2013 )

plot(data.demo.count)
