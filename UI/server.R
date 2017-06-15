library(shiny)
library(shinyAce)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  
  # loads circos image preview
  output$image <- renderUI({
    input$reloadImageButton
    img(src="circos.png", width=500)
  })
  
  ntext <- eventReactive(input$configUpdateButton, {
  text <- input$code
   write.table(file="test.txt", text)
  })
  
  output$showEditor <- renderUI({
    content <- readChar("test.txt", file.info("test.txt")$size)
    aceEditor("code", mode="r", value=content)
  })
  
 
  
  
  output$nText <- renderText({
    ntext()
  })
  
  output$shinyUI <- renderUI({
    input$eval
    return(isolate(eval(parse(text=input$code))))
  }) 
  
})
