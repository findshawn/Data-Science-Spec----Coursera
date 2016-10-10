library(shiny)
library(ggplot2)

shinyUI(fluidPage(

    # Application title
    titlePanel("Vehicle Performance by Number of Cylinders"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            selectInput(
                inputId = "cyl", 
                label = h3("# Cylinders"), 
                choices = sort(unique(mtcars$cyl))
            )
        ),
    
        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("plot")
        )
    )
))

