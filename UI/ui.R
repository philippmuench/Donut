library(shiny)
library(shinydashboard)
library(shinyAce)


dashboardPage(
  dashboardHeader(),
  dashboardSidebar(),
  dashboardBody(
    # Boxes need to be put in a row (or column)
    fluidRow(
      box( width = 12,
           solidHeader = TRUE,
        title = "Preview",
        uiOutput("image"),
        br(),
        actionButton("reloadImageButton", "reload image"),
        actionButton("runCircosButton", "run circos"),
        actionButton("eval", "Update UI"),
        actionButton("configUpdateButton", "Update config")
      ),
      box( 
           htmlOutput("showEditor"),
           htmlOutput("test"),
           verbatimTextOutput("nText")
           )
    )
  )
)
