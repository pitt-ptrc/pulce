#' care UI Function
#'
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
#' @importFrom gt gt_output

mod_care_ui <- function(id){
  ns <- NS(id)
  sidebarLayout(
    position = "left",
    sidebarPanel(
      width = 3,
      selectInput(ns("schema_in"), "Study", choices = unique(ref_care_ids$schema)),
      selectInput(ns("table_in"), "Table", choices = NULL),
      # selectInput(ns("col_name_in"), "Variable", choice = NULL),
      actionButton(ns("getdata"), "Get Data"),
      hr(),
      verbatimTextOutput(ns("query"))
      # selectInput(ns("pulce_id_in"), "Pulce ID", choice = NULL),
      # radioButtons(ns("pct_in"), "Percent", choices = c("TRUE", "FALSE"))
    ),
    mainPanel(
      fluidRow(
        column(
          3,
          plotOutput(ns("plot_age_at_treat"))
        ),
        column(
          9,
          plotOutput(ns("plot_dxtx"))
        )
        # column(
        #   4,
        #   gt_output(ns("table_txdx"))
        # )
      )
    )
    
  )
}

#' care Server Functions
#'
#' @noRd 
#' 
#' @import dplyr
#' @importFrom magrittr %>%
#' @importFrom dbplyr in_schema
mod_care_server <- function(id){
  moduleServer( id, function(input, output, session) {
    ns <- session$ns
    
    schema <- reactive({
      filter(ref_care_ids, schema == input$schema_in)
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
    
    output$query <- renderPrint({
      tbl(
        pool,
        in_schema(
          schema = input$schema_in,
          table = input$table_in
        )
      ) %>%  
        show_query()
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
    
    output$plot_dxtx <- renderPlot({
      p <- fetched_data() %>% 
        count(CV_CAT_TREAT_TYPE, CV_CAT_DIAG_TYPE) %>% 
        ggplot(aes(CV_CAT_TREAT_TYPE, CV_CAT_DIAG_TYPE, fill = n)) +
        geom_tile() +
        scale_fill_distiller(palette = "Spectral") +
        theme(axis.text.x = element_text(angle = 340, hjust = 0.2))
      
      plot_with_labels(p, display_labels)
    }) %>% 
      bindCache(fetched_data())
    
    output$plot_age_at_treat <- renderPlot({
      tbl(
        pool,
        in_schema(
          schema = unique(selection()$schema),
          table = unique(selection()$table)
        )
      ) %>% 
        ggplot(aes(year)) +
        geom_histogram(binwidth = 1) +
        coord_flip()
    })
  })
}


## To be copied in the UI
# mod_care_ui("care_ui_1")
    
## To be copied in the server
# mod_care_server("care_ui_1")
