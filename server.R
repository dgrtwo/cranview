library(shiny)
library(stringr)
library(dplyr)
library(ggplot2)
library(lubridate)
library(cranlogs)
library(zoo)
library(scales)
library(plotly)

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

get_some_info = function(packages)
{
    info <- list()
    for (pkg in packages)
    {
        # api data for package. we want the initial release - the first element of the "timeline"
        pkg_data = httr::GET(paste0("http://crandb.r-pkg.org/", pkg, "/all"))
        pkg_data = httr::content(pkg_data)
        
        info[[pkg]]$title   <- pkg_data$title
        info[[pkg]]$version <- pkg_data$latest 
        info[[pkg]]$cran    <- paste("https://CRAN.R-project.org/package=", pkg, sep = "")
    }
    
       info
}


shinyServer(function(input, output, session) {

    observe({
        release_date <- min(get_initial_release_date(input$package))
        updateDateRangeInput(session, "dateRange",
                             label = "Date range: yyyy-mm-dd",
                             start = release_date,
                             end = Sys.Date()-1,
                             max = Sys.Date())  
    })
    

    downloads <- reactive({
        packages <- input$package
        cran_downloads0 <- failwith(NULL, cran_downloads, quiet = TRUE)
        cran_downloads0(package = packages, 
                        from    = input$dateRange[1], 
                        to      = input$dateRange[2])
      })
    
    
    output$downloadsPlot <- renderPlotly({
        d <- downloads()
        packages <- input$package
        packages <- packages[order(packages)]
        if (input$transformation == "weekly") {
            d$count = rollapply(d$count, 7, sum, fill = NA)
        } else if (input$transformation == "cumulative") {
            d = d %>%
                group_by(package) %>%
                transmute(count = cumsum(count), date = date) 
        }
        g <- ggplot(d, aes(date, count, color = package)) + 
                geom_line() +
                xlab("Date") +
                scale_y_continuous(name = "Number of downloads", labels = comma)
        g <- ggplotly(g) %>% config(displayModeBar = F)
      
        for (i in 1:length(packages)){
            g$x$data[[i]]$text <- paste("date:", d$date[d$package == packages[i]], 
                                        "<br>count:", d$count[d$package == packages[i]], 
                                        "<br>package:", packages[i])
        }
        g
        })
    
    output$packageinfo <- renderUI({
        packages <- input$package
        info <- get_some_info(packages)
        text <- ""
        for (pkg in packages)
        {
            text <- paste(text, 
                          paste("<a href='https://CRAN.R-project.org/package=",pkg, "'>", pkg, "</a>", 
                                "<br>Title: ", info[[pkg]]$title,
                                "<br>Latest version: ", info[[pkg]]$version, "<br>",
                                sep = ""))
        }
        HTML(text)
    }) 

})
