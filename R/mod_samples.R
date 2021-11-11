#' samples UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 

mod_samples_ui <- function(id){
  ns <- NS(id)
  sidebarLayout(
    position = "left",
    sidebarPanel(
      width = 3,
      selectInput(ns("schema_in"), "Study", choices = unique(ref_samp_ids$schema)),
      selectInput(ns("table_in"), "Table", choices = NULL),
      # selectInput(ns("col_name_in"), "Variable", choice = NULL),
      actionButton(ns("getdata"), "Get Data"),
      hr(),
      verbatimTextOutput(ns("query"))
      # selectInput(ns("pulce_id_in"), "Pulce ID", choice = NULL),
      # radioButtons(ns("pct_in"), "Percent", choices = c("TRUE", "FALSE"))
    ),
    mainPanel(
      tabsetPanel(
        tabPanel(
          "Overall",
          plotOutput(ns("plot_overall"))
        ),
        tabPanel(
          "Per patient",
          plotOutput(ns("plot_perpatient"))
        )
      )
    )
  )
}

#' tests Server Functions
#'
#' @noRd 
#' 
#' @import dplyr
#' @importFrom magrittr %>%
#' @importFrom dbplyr in_schema
mod_samples_server <- function(id){
  moduleServer( id, function(input, output, session) {
    ns <- session$ns
    
    schema <- reactive({
      filter(ref_samp_ids, schema == input$schema_in)
    })
    observeEvent(schema(), {
      choices <- unique(schema()$table)
      updateSelectInput(inputId = "table_in", choices = choices)
    })
    
    table <- reactive({
      req(input$table_in)
      filter(schema(), table == input$table_in)
    })
    selection <- eventReactive(input$getdata, {
      req(input$table_in)
      table()
    })
    
    
    fetched_data <- reactive({
      tbl(
        pool,
        in_schema(
          schema = input$schema_in,
          table = input$table_in
        )
      )
    }) %>%
      bindEvent(input$getdata)
    
    output$query <- renderPrint({
      fetched_data() %>%
        show_query()
    }) %>% 
      bindCache(fetched_data())
    
    output$plot_overall <- renderPlot({
      p <- fetched_data() %>% 
        # dbplot::dbplot_bar(!!sym(selection()$col_name)) +
        ggplot(aes(!!sym(selection()$col_name))) +
        geom_bar() +
        coord_flip() +
        theme(legend.position="bottom")
      
      plot_with_labels(p, display_labels)
    }) %>% 
      bindCache(fetched_data())
    
    
    output$plot_perpatient <- renderPlot({
      p <- fetched_data() %>% 
        count(CV_ID_PULCE, !!sym(selection()$col_name)) %>% 
        ggplot(aes(!!sym(selection()$col_name))) +
        geom_bar() +
        coord_flip()
      
      plot_with_labels(p, display_labels)
    }) %>% 
      bindCache(fetched_data())
  })
}
    
## To be copied in the UI
# mod_samples_ui("samples_ui_1")
    
## To be copied in the server
# mod_samples_server("samples_ui_1")
