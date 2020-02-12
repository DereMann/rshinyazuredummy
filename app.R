#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(DBI)

DRIVERNAME <- switch(Sys.info()[['sysname']],
                     Windows = 'SQL Server',
                     Linux = 'ODBC Driver 17 for SQL Server')
DBCONN <- DBI::dbConnect(
    odbc::odbc(),
    Driver = DRIVERNAME,
    Server = 'tcp:jrz-shinytestdb.database.windows.net,1433',
    Database = 'jrzshinyTestDB',
    UID = Sys.getenv("userid"),
    PWD = Sys.getenv("pwd")
)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Old Faithful Geyser Data"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30)
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("distPlot"),
           DT::dataTableOutput("sampletable")
        )
    )
)

createDataTable <- function(dt, escape = TRUE) {
    
    mytable <- reactive(DT::datatable(dt,
                                      extensions=c('Scroller', 'Buttons'),
                                      escape = escape,
                                      options = list(dom = 'Bfrtip',
                                                     scrollY = 680,
                                                     scroller = TRUE,
                                                     scrollX=TRUE,
                                                     buttons = c('copy', 'csv', 'excel'))))
    
    return(mytable)
}

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$distPlot <- renderPlot({
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')
    })
    
    
    output$sampletable <- DT::renderDataTable(server = FALSE,{
        dt <- dbGetQuery(DBCONN,"SELECT * FROM testtable")
        createDataTable(dt)()
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
