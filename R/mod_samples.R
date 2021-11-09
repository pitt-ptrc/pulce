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
    
    # pulce_ids <- reactive({
    #   tbl(pool,
    #       in_schema(schema = selection()$schema,
    #                 table = selection()$table)) %>%
    #     group_by(CV_ID_PULCE, CV_CAT_TEST_TYPE) %>%
    #     filter(n() > 15) %>%
    #     ungroup() %>%
    #     distinct(CV_ID_PULCE) %>%
    #     pull()
    # })
    # observeEvent(pulce_ids(), {
    #   choices <- pulce_ids()
    #   updateSelectInput(inputId = "pulce_id_in", choices = choices)
    # })
    
    output$query <- renderPrint({
      tbl(
        pool,
        in_schema(
          schema = selection()$schema,
          table = selection()$table
        )
      ) %>%  show_query()
    })
    
    output$plot_overall <- renderPlot({
      p <- tbl(
        pool,
        in_schema(
          schema = selection()$schema,
          table = selection()$table
        )
      ) %>% 
        # dbplot::dbplot_bar(!!sym(selection()$col_name)) +
        ggplot(aes(!!sym(selection()$col_name))) +
        geom_bar() +
        coord_flip() +
        theme(legend.position="bottom")
      
      plot_with_labels(p, display_labels)
    })
    
    
    output$plot_perpatient <- renderPlot({
      p <- tbl(
        pool,
        in_schema(
          schema = selection()$schema,
          table = selection()$table
        )
      ) %>% 
        count(CV_ID_PULCE, !!sym(selection()$col_name)) %>% 
        ggplot(aes(!!sym(selection()$col_name))) +
        geom_bar() +
        coord_flip()
      
      plot_with_labels(p, display_labels)
    })
  })
}
    
## To be copied in the UI
# mod_samples_ui("samples_ui_1")
    
## To be copied in the server
# mod_samples_server("samples_ui_1")
