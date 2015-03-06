
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Package Downloads Over Time"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      HTML("Enter an R package to see the # of downloads over time from the RStudio CRAN Mirror."),
      textInput("package", "Package:", "shiny"),
      # submitButton("View Downloads"),
      sliderInput("num_weeks",
                  "Number of weeks:",
                  min = 1,
                  max = 52,
                  value = 12),
      checkboxInput("by_week", "Summarize by week", value = TRUE),
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
