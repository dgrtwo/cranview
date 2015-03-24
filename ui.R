library(shiny)
library(httr)
library(jsonlite)

# get the list of all packages on CRAN
package_names = names(httr::content(httr::GET("http://crandb.r-pkg.org/-/desc")))

shinyUI(fluidPage(

  # Application title
  titlePanel("Package Downloads Over Time"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      HTML("Enter an R package to see the # of downloads over time from the RStudio CRAN Mirror.",
           "You can enter multiple packages to compare them"),
      selectInput("package", 
                  label = "Packages:",
                  selected = sample(package_names, 2), # initialize the graph with a random package
                  choices = package_names,
                  multiple = TRUE),      
      radioButtons("transformation", 
                 "Data Transformation:",
                 c("Daily" = "daily", "Weekly" = "weekly", "Cumulative" = "cumulative")),
      HTML("Created using the <a href='https://github.com/metacran/cranlogs'>cranlogs</a> package.",
           "This app is not affiliated with RStudio or CRAN.",
           "You can find the code for the app <a href='https://github.com/dgrtwo/cranview'>here</a>,",
           "or read more about it <a href='http://varianceexplained.org/r/cran-view/'>here</a>.")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("downloadsPlot")
    )
  )
))
