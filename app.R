library(shiny)
library(shinythemes)
if(!require(prophet)){install.packages("prophet"); require(prophet)} 
if(!require(plotly)){install.packages("plotly"); require(plotly)} 
if(!require(shinycssloaders)){install.packages("shinycssloaders"); require(shinycssloaders)} 

source("./dataWork.R")
source("./moreDataWork.R")

ui <- fluidPage( theme = shinytheme("flatly"),
                 navbarPage("",
                            
                            ## HOME PAGE ##   
                            tabPanel("Home",
                                     titlePanel("Mandatory Housing Affordability in Seattle"),
                                     tags$h3("General Context"),
                                     
                                     tags$p("With more than 1,100 new residents per week, it’s safe to say that Seattle is experiencing unprecedented growth. This increase in demand has serious consequences for current and potential residents. With more people coming into the city with well paying jobs, the more property owners can ask of purchasers or renters in both residential and commercial buildings. In fact, rental rates have increased by an astounding fifty seven percent over six years (Seattle Times). While median household income has only risen by approximately twenty percent over the same period (American Community Survey)."),
                                     
                                     tags$p("To address the issue of affordability, the Mayor Murray’s Administration proposed what is called Mandatory Housing and Affordability (MHA) in 2013. MHA has two main mechanisms. First, it induces growth by changing the zoning laws in specific areas to allow for higher development capacity. Areas impacted will increase by at least 10’ of allowed height at a minimum. In certain neighborhoods, like the University District, MHA adds over 100’ of allowed height. Second, it requires developers to contribute to affordable housing whenever a new building is constructed - hence the ‘A’ for affordability. This requirement is enacted through a fee per square foot of new development OR by setting aside a certain number of rent-restricted units based on the 60% Area Median Income (AMI). The City estimates that MHA will produce approximately 6,000 units of rent-restricted housing over the next 10 years."),
                                     
                                     tags$h3("Decision Makers"),
                                     
                                     tags$p("Our project will produce results to be considered by the Seattle City Council and the Mayor . There are currently nine members of the City Council, representing seven voting districts as well as two at-large members representing the whole city. Generally, the members of the Council have been favorable of MHA, passing each proposal unanimously - although amendments generally are more contested. Jenny Durkhan, the new mayor, has also stated her support of MHA. The same goes for newly elected Theresa Mosqueda in the City Council."),
                                     
                                     tags$p("It is clear that the general MHA policy will continue to be implemented. The question isn’t whether or not these up-zones will be implemented, but rather what form they will take when it reaches the Mayor’s desk."),
                                     
                                     tags$h3("The Decision"),
                                     
                                     tags$p("MHA has been enacted in several neighborhoods already - such as the University District, Downtown Seattle, Lower Queen Anne, and the International District. Eventually this policy will be applied to all of the ‘urban villages’ (the core of approximately 30 main neighborhoods throughout the city,) along with other commercial areas. Before much of this occurs, the city will further analyze the impact of the zoning change by completing an Environmental Impact Statement (EIS). This identifies several different options for the city consider when it comes to applying this change."),
                                     
                                     tags$p("The main options are no-action (where the city stops all changes in zoning), an initial MHA zoning increase, an opportunity/displacement based MHA zoning, or the “Preferred Alternative” (a combination of the latter two)."),
                                     
                                     tags$p("Our project will be an examination of the impact the Preferred Alternative on property value in Seattle. We will model predicted value under the assumptions that A) the Preferred Alternative is implemented and B) the Preferred Alternative is not implemented. By comparing these two alternatives in terms of predicted property value we can illuminate crucial differences between these two options in different neighborhoods across the city."),
                                     
                                     tags$p("If the projected property value under the Preferred alternative is too large - there likely will be a significant increase in displacement due to increased rent prices and property tax. However if it is too small, then it’s likely that the zoning change will not incentivize new, dense development. Our model will allow users to see for themselves how this change may impact prices in the city as a whole and each neighborhood individually."),
                                     
                                     tags$h3("What Our Tool does"),
                                     
                                     tags$p("There were two aims for our model. The first is to predict property value change in the near future. The second is to see how changing in zoning under the Preferred Alternative will impact this property change versus no action taken. We did not only want to see how this change occurred city-wide but also within each individual neighborhood."),
                                     
                                     tags$p("For us to make a prediction of the future we decided to run a linear regression model. This linear regression model took into account a variety of factors to predict property value."),
                                     
                                     tags$p("To examine the veracity of our linear regression we examined the residual plot. However, due to the nature of development, there are some really strong right-hand skews in our models. Some of the other residual plots have patterns such as a ‘flare’ at the higher indexed items on the plot."),
                                     
                                     tags$h3("Factors Included in Our Model"),
                                     tags$ul(
                                       tags$li("Property value by year (King County Assessor’s Office)"),
                                       tags$ul(
                                         tags$li("Value of property assessed by the King County Assessor’s office for taxing purposes.")
                                       ),
                                       
                                       tags$li("Lot square footage (King County Assessor’s Office)"),
                                       tags$ul(
                                         tags$li("Total area within the parcel of land")
                                       ),
                                       
                                       tags$li("Current zoning (King County Assessor’s Office)"),
                                       tags$ul(
                                         tags$li("Land use regulations regarding the height, bulk, and usage of the property")
                                       ),
                                       
                                       tags$li("Future zoning (Seattle Department of Planning and Development)"),
                                       tags$ul(
                                         tags$li("Land use regulations under assumption that the MHA Preferred Alternative is implemented")
                                       ),
                                       
                                       tags$li("Floor Area Ratio (Seattle Department of Planning and Development)"),
                                       tags$ul(
                                         tags$li("Ratio of square footage developed over square footage of parcel")
                                       ),
                                       tags$li("Neighborhood name (Seattle Department of Planning and Development)"),
                                       tags$ul(
                                         tags$li("Name of one of the 30 or so ‘Urban Villages’ throughout the city where rezones are occurring, such as University District, South Lake Union, etc.")
                                       )),
                                     
                                     tags$h3("Data"),
                                     tags$h4("Data Collecting and Cleaning"),
                                     tags$p("Initially we had several GIS Shapefiles (i.e. polygons on a coordinate system with sets of attributes in table form) as well as tables in .csv form."),
                                     
                                     tags$p("The GIS files we had were parcels within King County, Seattle Neighborhoods, and MHA zoning. First we only selected parcels that fell within Seattle. At this point the attributes of each shape did not match - so we had to use a geometric analysis called ‘Identity’ which essentially joins the shapes that overlap with an output of a shape with all the same attributes. The output of this function was a Parcel shapefile that had attributes for which neighborhood and the MHA zoning that covered it. The last GIS operation we had to do was exporting the shapefile to .xml format so that we could import it into RStudio."),
                                     
                                     tags$p("After importing our parcel data we were able to join other tables using the a PIN value attached to each parcel. These included a table of past value assessments from back to 1996 from the King County Assessor’s office. At this point we had a lot of interesting data for each parcel, such as historical property value, square footage, neighborhood name, current zoning, rezone type, and others. We also had a lot of other columns that were far less relevant to our question that we ended up cutting from our data frame."),
                                     
                                     tags$p("Later when we were modeling we still were lacking some key information. One important missing factor was development capacity - basically how big the building can be.Initially we wanted to assign a height and maximum lot coverage to each zoning type, however we later found a more accessible and simple factor called Floor Area Ratio (FAR). This factor is the maximum ratio of total developed square footage to total parcel square footage. A building with a FAR of 1.0 can cover the whole lot at one story or half the lot at two stories, etc. To find the FAR for each zoning type we had to manually enter the information from several different .pdf documents published by the Department of Planning and Development."),
                                     
                                     tags$h3("Limitations of Our Model"),
                                     tags$h4("Assumption"),
                                     tags$p("A key assumption that we made is that rent price would increase with the increase in property value. Since we are trying to make a case to the decision makers, the Seattle City Council, that with the increase in property value, the rent would also increase, affecting the majority of the population. If we didn’t make this assumption, we could not connect the bridge between rent prices and affecting the residents in Seattle."),
                                     
                                     
                                     tags$p("In addition, we had to make an assumption that property value in Seattle is constantly increasing. Again, we had to use this assumption to draw the bridge between the increased prices and affecting the residents. There could be a sudden catastrophe, such as an earthquake, that destroys all the houses in Seattle, therefore decreasing the property value of all the properties. However, we didn’t account for all these unpredictable catastrophes. We tried to eliminate factors that could not be calculated to create our model."),
                                     
                                     tags$p("Another assumption we had to make is that affordability fees would not affect property value increases. This is a rather poor assumption but due to the limitations of our data we were unable to model the impact of these fees. It’s likely that our estimations for property value increases are rather liberal due to this omission."),
                                     
                                     tags$h4("Limitations"),
                                     tags$p("While conducting our research, we came across a significant obstacle of finding the right data. For example, we initially could not find the right data for MHA zoning map for Seattle. We eventually extracted the data from the City’s GIS portal. In addition, we contacted Zillow to get some data that might be relevant to our study - however, they did not respond to our emails or requests and we had to work around not using their data. 
                                            Ironically, we also ran into the problem of finding too much data with the MHA property information. We had hundreds of thousands of rows of data, but some had null values and most were unnecessary columns.")
                                     
                                     ),
                            tabPanel("Overview of Seattle",
                                     titlePanel("Overview of Seattle"),
                                     # Sidebar for input widgets       
                                     sidebarLayout(
                                       sidebarPanel(
                                         # Select one Washington city - dropdown menu
                                         #    selectInput("house", label = "Type in address", choices = all.homes$RegionName, multiple = F, selected = "Admiral"),
                                         tags$p("The following graphs show the past and predicted values of assessed property values within Seattle urban villages up until 2018. Each tab explores the predicted values under the assumption that either no rezone occurs OR that the Mandatory Housing Affordability Preferred Alternative rezone is implemented. The four different types of properties examined are residential, mixed-use, commercial, and industrial.")
                                       ), 
                                       
                                       # Main panel for output visuals
                                       mainPanel(
                                         tabsetPanel(
                                           tabPanel("Residential No Rezone",
                                                    fluidRow(plotlyOutput("residentialNoZone"))
                                                    ,
                                                    plotlyOutput("residentialNoZoneLine") %>% withSpinner()
                                           ),
                                           tabPanel("Residential Rezone",
                                                    fluidRow(plotlyOutput("residentialPlot"))
                                                    ,
                                                    plotlyOutput("residential") %>% withSpinner()
                                           ),
                                           
                                            tabPanel("Mixed No Rezone",
                                                     fluidRow(plotlyOutput("noZoneMixedPlot"))
                                                     ,
                                                     plotlyOutput("noZoneMixedScatter") %>% withSpinner()
                                            )
                                           ,
                                            
                                            tabPanel("Mixed Rezone",
                                                     fluidRow(plotlyOutput("overviewPlotMixed"))
                                                     ,
                                                     plotlyOutput("scatterMixed.plot") %>% withSpinner()
                                            )
                                           ,
                                             tabPanel("Commercial No Rezone",
                                                      fluidRow(plotlyOutput("commercialNoZoned"))
                                                      ,
                                                      plotlyOutput("commercialNoZoneTwo") %>% withSpinner()
                                             )
                                            ,
                                             tabPanel("Commercial Rezone",
                                                      fluidRow(plotlyOutput("commercialRezoned"))
                                                      ,
                                                      plotlyOutput("commercialRezonedTwo") %>% withSpinner()
                                             )
                                            ,
                                             tabPanel("Industrial No Rezone",
                                                      fluidRow(plotlyOutput("industrialNoZone"))
                                                      ,
                                                      plotlyOutput("industrialNoZoneTwo") %>% withSpinner()
                                             )
                                           ,
                                             tabPanel("Industrial Rezone",
                                                      fluidRow(plotlyOutput("industrialZone"))
                                                      ,
                                                      plotlyOutput("industrialZoneTwo") %>% withSpinner()
                                             )
                                         )
                                       )
                                     )
                            ), 
                            
                            tabPanel("Predicted Neighborhood Prices",
                                     titlePanel("Select a Neighborhood"),
                                     # Sidebar for input widgets       
                                     sidebarLayout(
                                       sidebarPanel(
                                         # Select one Washington neighborhood - dropdown menu
                                         selectInput("neighborhood", label = "Select Your Desired Neighborhood", choices = all.homes$RegionName, multiple = F, selected = "Admiral"),
                                         tags$p("This shows predicted values up until 2022 for sales prices in neighborhoods for homes, or the median property value in each neighborhood, regardless of residential or commercial buidlings.")
                                       ), 
                                       
                                       # Main panel for output visuals
                                       mainPanel(
                                         plotlyOutput("neighborhood.plot") %>% withSpinner()
                                         
                                       )
                                     )
                            ), 
                            ## EXPLORE AN ADDRESS ##
                            tabPanel("Explore an Address",
                                     titlePanel("Enter an Address"),
                                     # Sidebar for input widgets       
                                     sidebarLayout(
                                       sidebarPanel(
                                         # Search bar for user input
                                         searchInput(
                                           inputId = "address", 
                                           placeholder = "Search your address", 
                                           btnSearch = icon("search"), 
                                           btnReset = icon("remove"), 
                                           width = "100%"
                                         ),
                                         tags$p("This shows predicted values for 2018 for the inputed address. Please enter a valid address with 
                                                abbreviated suffix (e.g. ST, AVE, BLVD). Our data does not contain every single address in Seattle.
                                                Here are some example addresses:"),
                                         tags$ul(
                                           tags$li("3901 FREMONT AVE N"),
                                           tags$li("2613 BOYLSTON AVE E"),
                                           tags$li("5515 A 28TH AVE NW")
                                        )
                    
                                       ), 
                                       
                                       # Main panel for output visuals
                                       mainPanel(
                                         tags$style(type="text/css",
                                                    ".shiny-output-error { visibility: hidden; }",
                                                    ".shiny-output-error:before { visibility: hidden; }"),
                                         plotlyOutput("address.plot") #%>% withSpinner()
                                       )
                                     
                            )), 
                            ## ABOUT US ##
                            tabPanel("About",
                                     titlePanel("About Us and Our Project"),
                                     mainPanel(
                                       tags$p("We are a group of 4 data scientists (in-training) at the University of Washington.
                                              This is our final artifact for INFO 370: Introduction to Data Science Fall 2017. We built this
                                              with R, RStudio, and its various libraries such as Shiny, Tidyverse, Caret, Prophet, ggplot, and plotly.
                                              Please visit our GitHub page for more information on our project."),
                                       tags$a(href="https://github.com/info370/project-team-cups", "GitHub Link Here!"),
                                       tags$h3("The Team"),
                                       tags$p("Zhanna Voloshina, Nathan Bombardier, Jenny Lee, & Joycie Yu")
                                       )
                                     )
                 )
                 
)

## SERVER ##
server <- function(input, output)  {
  
  output$neighborhood.plot <- renderPlotly({
    predict.data <- PredictNeighborhoodSalePrice(input$neighborhood)
    p <- plot_ly(data = predict.data, type = "scatter", mode = "lines", x = ~Date, y = ~Predicted, name = 'Predicted', line = list(color = 'rgb(255, 128, 0)'), width = 4) %>% add_trace(y = ~Actual, name = 'Actual', line = list(color = 'rgb(228, 13, 13)', width = 3)) %>%  
      layout(xaxis = list(title = "Date"), yaxis = list(title = "Median Sale Price ($)"),
             title = "Median and Predicted Median Sale Price", margin = list(t=120))
    return(p)
  })
  
  output$residentialNoZone <- renderPlotly({
    resNoZone <- noRezonePredictionRes()
    ggplot(resNoZone, aes(RollYr, TotalVal)) + 
      geom_point() + geom_smooth(method="lm", fill=NA)
  })
  
  output$residentialNoZoneLine <- renderPlotly({
    resNoZone <- noRezonePredictionRes()
    ggplot(resNoZone, aes(RollYr, TotalVal)) + geom_smooth(method="lm", fill='red')
  })
  
  output$residentialPlot <- renderPlotly({
    totalfuture <- reZonePrediction()
    ggplot(totalfuture, aes(RollYr, TotalVal)) + 
      geom_point() + geom_smooth(method="lm", fill=NA)
    
  }
  )
  output$residential <- renderPlotly({
    grid <- reZonePrediction()
    ggplot(grid, aes(RollYr, TotalVal)) + geom_smooth(method="lm", fill='red')
  })
  
   
   output$overviewPlotMixed <- renderPlotly({
     totalMixRezone <- mixedRezone()
     ggplot(totalMixRezone, aes(RollYr, TotalVal)) + geom_point(alpha = 0.1) + geom_smooth(method="lm", fill=NA)
   })
   
   output$scatterMixed.plot <- renderPlotly ({
     totalMixRezone <- mixedRezone()
     ggplot(totalMixRezone, aes(RollYr, TotalVal)) + geom_smooth(method="lm", fill='red') 
   })
   
   output$noZoneMixedPlot <- renderPlotly({
     totalMixNoZone <- mixedNoRezone()
     ggplot(totalMixNoZone, aes(RollYr, TotalVal)) + geom_point(alpha = 0.1) + geom_smooth(method="lm", fill=NA)
   })
   
   output$noZoneMixedScatter <- renderPlotly({
     totalMixNoZone <- mixedNoRezone()
     ggplot(totalMixNoZone, aes(RollYr, TotalVal)) + geom_smooth(method="lm", fill='red') 
   })
   
    output$commercialNoZoned <- renderPlotly ({
      totalComNoZoned <- commercialNoRezone()
      ggplot(totalComNoZoned, aes(RollYr, TotalVal)) + geom_point(alpha = 0.1) + geom_smooth(method="lm", fill=NA)
    })
    
    output$commercialNoZoneTwo <- renderPlotly ({
      totalComNoZone <- commercialNoRezone()
      ggplot(totalComNoZone, aes(RollYr, TotalVal)) + geom_smooth(method="lm", fill='red') 
    })
    
    output$commercialRezoned <- renderPlotly({
      totalComRezone <- commercialNoRezone()
      ggplot(totalComRezone, aes(RollYr, TotalVal)) + geom_point(alpha = 0.1) + geom_smooth(method="lm", fill=NA)
    })
    
    output$commercialRezonedTwo <- renderPlotly({
      totalComRezone <- commercialNoRezone()
      ggplot(totalComRezone, aes(RollYr, TotalVal)) + geom_smooth(method="lm", fill='red') 
    })
    
    
    output$industrialNoZone <- renderPlotly ({
      totalIndusNoZone <- industrialNoRezone()
     ggplot(totalIndusNoZone, aes(RollYr, TotalVal)) + geom_point(alpha = 0.1) +  geom_smooth(method="lm", fill =NA)
    })
    
    output$industrialNoZoneTwo <- renderPlotly ({
      totalIndusNoZone <- industrialNoRezone()
      ggplot(totalIndusNoZone, aes(RollYr, TotalVal)) + geom_smooth(method="lm", fill='red') 
    })
    
     output$industrialZone <- renderPlotly({
      totalIndusZone <- industrialRezone()
      ggplot(totalIndusZone, aes(RollYr, TotalVal)) + geom_point(alpha = 0.1) +  geom_smooth(method="lm", fill =NA)
     })
     
     output$industrialZoneTwo <- renderPlotly({
      totalIndusZone <- industrialRezone()
       ggplot(totalIndusZone, aes(RollYr, TotalVal)) + geom_smooth(method="lm", fill='red') 
    })
     
     output$address.plot <- renderPlotly({
       add.pred <- PredictAddressSalePrice(input$address)
       ggplot(add.pred, aes(RollYr, pred, color = 'red', xlab="Year", ylab="Predicted Total Appraised Value")) + geom_line() + ggtitle("2013 - 2018 Predicted Total Appraised Value") 
     })
}

# Run the application 
shinyApp(ui = ui, server = server)
