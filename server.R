library(shiny)
library(stringr)
library(dplyr)
library(ggplot2)
library(lubridate)
library(cranlogs)
library(zoo)
library(scales)

get_initial_release_date = function(packages)
{
    min_date = Sys.Date() - 1
    
    for (pkg in packages)
    {
        # api data for package. we want the initial release - the first element of the "timeline"
        pkg_data = httr::GET(paste0("http://crandb.r-pkg.org/", pkg, "/all"))
        pkg_data = httr::content(pkg_data)
        
        initial_release = pkg_data$timeline[[1]]
        min_date = min(min_date, as.Date(initial_release))    
    }
    
    min_date
}

shinyServer(function(input, output) {
  downloads <- reactive({
      packages <- input$package
      cran_downloads0 <- failwith(NULL, cran_downloads, quiet = TRUE)
      cran_downloads0(package = packages, 
                      from    = get_initial_release_date(packages), 
                      to      = Sys.Date()-1)
  })
    
  output$downloadsPlot <- renderPlot({
      d <- downloads()
      if (input$transformation=="weekly") {
          d$count=rollapply(d$count, 7, sum, fill=NA)
      } else if (input$transformation=="cumulative") {
          d = d %>%
                group_by(package) %>%
                transmute(count=cumsum(count), date=date) 
      }

      ggplot(d, aes(date, count, color = package)) + geom_line() +
          xlab("Date") +
          scale_y_continuous(name="Number of downloads", labels = comma)
  })

})
