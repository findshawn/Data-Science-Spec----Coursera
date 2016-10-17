library(shiny)
library(ggplot2)

shinyUI(fluidPage(

    # Application title
    titlePanel("Vehicle Performance by Number of Cylinders"),
    #br(),
    
    # Intro
    h3("Introduction:"),
    p("Select the number of cylinders from 4,6,8, and the graph will show you the vehicles accordingly."),
    p("Light blue color represents fast cars and dark blue represents slow cars."),
    p("Horizontal axis shows the fuel efficiency in miles-per-gallon. Vertical axis shows horsepower (how strong the engine is)."),
    #br(),
    
    # Conclusion
    h3("Conclusion:"),
    p("As you select different number of cylinders, you can see that the more cylinders a vehicle has, the higher horsepower it tends to have."),
    p("Also notice that faster cars tend to have high horsepower, but not necessarily high miles-per-gallon. This is because faster cars (sport cars) tend to be lighter in weight, thus require less gasoline to accelerate."),
    br(),
    
    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            selectInput(
                inputId = "cyl", 
                label = h3("Number of Cylinders"), 
                choices = sort(unique(mtcars$cyl))
            ),
            br(),
            p('Source: mtcars')
        ),
        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("plot")
        )
    )
))


