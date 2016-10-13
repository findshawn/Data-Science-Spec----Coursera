library(shiny)
library(ggplot2)

shinyServer(function(input, output) {

  output$plot <- renderPlot({
    
    mtcars$model <- row.names(mtcars)
        
    # plot of hp and fuel efficiency (mpg)
    ggplot(data = subset(mtcars,cyl == input$cyl),aes(x = mpg, y = hp, label=model)) +
        #geom_point(aes(size = wt,colour = qsec)) +
        #geom_text(aes(label=model),hjust = 0, nudge_x = 0.05, check_overlap = TRUE) +
        #scale_colour_gradient(low = 'cyan2',high = 'blue') +
        #scale_size_area() +
        labs(x = 'Miles per Gallon', y = 'Horsepower', colour = '1/4 mile time',size = 'Weight (1000 lbs)') +
        theme(text = element_text(size=16)) +
        geom_label(aes(fill = qsec,check_overlap = TRUE), colour = "white", fontface = "bold",vjust="inward",hjust="inward") +
        scale_fill_gradient(high = 'blue',low = 'cyan2',name = "1/4 mile time (s)")
    
  })

})