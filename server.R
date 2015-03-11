
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(dplyr)
library(ggplot2)
library(lubridate)
library(cranlogs)

# if package not found, keep the same one up
last <- NULL
last_package <- ""

shinyServer(function(input, output) {
  downloads <- reactive({
      end_date <- Sys.Date() - 1
      start_date <- end_date - input$num_weeks * 7 + 1
      
      ret <- cran_downloads(package = input$package,
                            from = start_date,
                            to = end_date)
      if (is.null(ret$downloads)) {
          return(last)
      }
      d <- ret$downloads[[1]] %>% mutate(day = as.Date(day))
      last <<- d
      last_package <<- input$package
      d
  })
    
  output$downloadsPlot <- renderPlot({
      d <- downloads()
      if (input$by_week) {
          d <- d %>%
              mutate(date = floor_date(day, "week")) %>%
              group_by(date) %>%
              summarize(downloads = sum(downloads))
      } else {
          d <- d %>% rename(date = day)
      }

      ggplot(d, aes(date, downloads)) + geom_line() +
          ggtitle(paste("Downloads for", last_package)) +
          xlab("Date") +
          ylab("Number of downloads")
  })

})
