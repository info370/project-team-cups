library(shiny)
library(shinythemes)

ui <- fluidPage( theme = shinytheme("flatly"),
   navbarPage("",
     
  ## HOME PAGE ##   
   tabPanel("Home",
        titlePanel("About Mandatory Housing Affordability in Seattle")
            ),
   ## OVERVIEW OF SEATTLE ##  
   tabPanel("Overview of Seattle",
      titlePanel("Overview of Seattle")
   ),
   ## SELECT NEIGHBORHOOD ##  
   tabPanel("Select Neighborhood",
      titlePanel("Neighborhood Graphs"),
   
   # Sidebar with a drop down input 
    fluidRow(
      column(3,
        selectInput("neighborhood", "Select a Neighborhood:", 
                    choices=c("Admiral" = "Admiral", "Aurora-Licton Springs" = "Aurora-Licton Springs", 
                              "Ballard" = "Ballard", "Ballard-Interbay-Northend" = "Ballard-Interbay-Northend",
                              "Belltown" = "Belltown", "Bitter Lake Village" = "Bitter Lake Village",
                              "Capitol Hill" = "Capitol Hill", "Chinatown-International District" = "Chinatown-International District",
                              "Columbia City" = "Columbia City", "Commercial Core" = "Commercial Core", "Crown Hill" = "Crown Hill",
                              "Denny Triangle" = "Denny Triangle", "Eastlake" = "Eastlake", "First Hill" = "First Hill", "Fremont" = "Fremont",
                              "Greater Duwamish" = "Greater Duwamish", "Greenlake" = "Greenlake", "Greenwood-Phinney Ridge" = "Greenwood-Phinney Ridge",
                              "Lake City" = "Lake City", "Madison-Miller" = "Madison-Miller", "Morgan Junction" = "Morgan Junction",
                              "North Beacon Hill" = "North Beacon Hill", "North Rainier" = "North Rainier", "Northgate" = "Northgate", "Othello" = "Othello",
                              "Pike/Pine" = "Pike/Pine", "Pioneer Square" = "Pioneer Square", "Rainier Beach" = "Rainier Beach", "Ravenna" = "Ravenna", "Roosevelt" = "Roosevelt",
                              "South Lake Union" = "South Lake Union", "South Park" = "South Park", "University Campus" = "University Campus", 
                              "University District Northwest" = "University District Northwest", "Upper Queen Anne" = "Upper Queen Anne", "Uptown" = "Uptown",
                              "Wallingford" = "Wallingford", "West Seattle Junction" = "West Seattle Junction", "Westwood-Highland Park" = "Westwood-Highland Park"
                              ))
      )
    )
   ),
  
  ## ABOUT OUR PROJECT ##
  tabPanel("About Our Project",
      titlePanel("About Our Project"),
      mainPanel("")
  ),
  
  ## ABOUT US ##
  tabPanel("About Our Team",
       titlePanel("About Our Team"),
       mainPanel("We are a group of 4 data scientists in training with at the University of Washington.")
   )
)
   
)

## SERVER ##

server <- function(input, output, session) {
  
}

# Run the application 
shinyApp(ui = ui, server = server)

