
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(stringr)
library(dplyr)
library(ggplot2)
library(lubridate)
library(cranlogs)
library(zoo)

shinyServer(function(input, output) {
  downloads <- reactive({
      end_date <- Sys.Date() - 1
      start_date <- end_date - input$num_weeks * 7 + 1
      
      packages <- input$package
      cran_downloads0 <- failwith(NULL, cran_downloads, quiet = TRUE)
      cran_downloads0(package = packages,
                      from = start_date,
                    to = end_date)
  })
    
  output$downloadsPlot <- renderPlot({
      d <- downloads()
      if (input$by_week) {
          d$count=rollmean(d$count, 7, na.pad=TRUE)
      }

      ggplot(d, aes(date, count, color = package)) + geom_line() +
          xlab("Date") +
          ylab("Number of downloads")
  })

})
