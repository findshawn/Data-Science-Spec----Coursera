library(shiny)

ui <- shinyUI(fluidPage(
   
   titlePanel("Slider App"),
   
   sidebarLayout(

      sidebarPanel(
         h1("Move the Slider!"),
         sliderInput("slider2", "Slide Me!",0,100,0)
      ),

      mainPanel(
         h3("Slider Value:"),
         textOutput("text1")
      )
   )
))


server <- shinyServer(function(input, output) {
   
   output$text1 <- renderText(input$slider2 + 10)

})

# Run the application 
shinyApp(ui = ui, server = server)

