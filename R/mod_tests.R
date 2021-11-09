#' tests UI Function
#'
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
#' 

mod_tests_ui <- function(id){
  ns <- NS(id)
  sidebarLayout(
    position = "left",
    sidebarPanel(
      width = 3,
      selectInput(ns("schema_in"), "Study", choices = unique(ref_ids$schema)),
      selectInput(ns("table_in"), "Table", choices = NULL),
      # selectInput(ns("col_name_in"), "Variable", choice = NULL),
      actionButton(ns("getdata"), "Get Data"),
      hr(),
      tags$body("Note: IDs are filtered for subjects adequate repeated measures. Identifiers are removed and dates shifted."),
      hr(),
      verbatimTextOutput(ns("query")),
      selectInput(ns("pulce_id_in"), "Pulce ID", choice = NULL),
      radioButtons(ns("pct_in"), "Percent", choices = c("TRUE", "FALSE"))
    ),
    mainPanel(
      plotOutput(ns("plot"))
    )
  )
  # fluidPage(
  #   inputPanel(
  #     selectInput(ns("schema_in"), "Study", choices = unique(ref_ids$schema)),
  #     selectInput(ns("table_in"), "Table", choices = NULL),
  #     # selectInput(ns("col_name_in"), "Variable", choice = NULL),
  #     actionButton(ns("getdata"), "Get Data")
  #   ),
  #   verbatimTextOutput(ns("query")),
  #   inputPanel(
  #     selectInput(ns("pulce_id_in"), "Pulce ID", choice = NULL),
  #     radioButtons(ns("pct_in"), "Percent", choices = c("TRUE", "FALSE"))
  #   ),
  #   plotOutput(ns("plot"))
  # )
}

#' tests Server Functions
#'
#' @noRd 
#' 
#' @import dplyr
#' @importFrom magrittr %>%
#' @importFrom dbplyr in_schema
mod_tests_server <- function(id){
  moduleServer( id, function(input, output, session) {
    ns <- session$ns
    
    schema <- reactive({
      filter(ref_ids, schema == input$schema_in)
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
    
    pulce_ids <- reactive({
      tbl(pool,
          in_schema(schema = selection()$schema,
                    table = selection()$table)) %>%
        group_by(CV_ID_PULCE, CV_CAT_TEST_TYPE) %>%
        filter(n() > 15) %>%
        ungroup() %>%
        distinct(CV_ID_PULCE) %>%
        pull()
    })
    
    observeEvent(pulce_ids(), {
      choices <- pulce_ids()
      updateSelectInput(inputId = "pulce_id_in", choices = choices)
    })
    
    output$query <- renderPrint({
      tbl(
        pool,
        in_schema(
          schema = selection()$schema,
          table = selection()$table
        )
      ) %>%  show_query()
    })
    
    output$plot <- renderPlot({
      
      plot_ann <- function(){
        
        get_treat_ann <-
          function(schema_cols,
                   str_col = c("CV_DT_TREAT", "CV_CAT_TREAT_TYPE"),
                   str_tbl = "cv_care",
                   str_sch = selection()$schema,
                   id_pulce = input$pulce_id_in
                   # str_sch = "m_breathelt",
                   # id_pulce = "/hkLLUJMyU6z"
                   ) {
            
            treat_ann_ref <- get_tbl_ref(schema_cols,
                                         str_col,
                                         str_tbl,
                                         str_sch)
            
            if (count(treat_ann_ref) == 1) {
              tbl(pool, in_schema(str_sch, str_tbl)) %>%
                # ccare %>%
                # filter(CV_ID_PULCE == !!input$pulce_id_in) %>%
                filter(CV_ID_PULCE == id_pulce) %>%
                pull(str_col)
            } else {
              NULL
            }
          }
        
        treat_types <- get_treat_ann(schema_cols, str_col = "CV_CAT_TREAT_TYPE")
        treat_dates <- get_treat_ann(schema_cols, str_col = "CV_DT_TREAT")
        
        list(
          if (!is.null(treat_dates)) 
            annotate(
              geom = "vline",
              x = treat_dates,
              xintercept = treat_dates,
              alpha = 0.5
            ),
          if (!is.null(treat_types)) 
            annotate(
              geom = "text",
              x = treat_dates,
              y = 0,
              label = treat_types,
              # angle = 90,
              vjust = 0,
              hjust = -0.1,
              # text=element_text(size=6)
            )
        )
      }
      
      p <- tbl(
        pool,
        in_schema(
          schema = selection()$schema,
          table = selection()$table
        )
      ) %>% 
        filter(pct == !!input$pct_in) %>% 
        filter(CV_ID_PULCE == !!input$pulce_id_in) %>% 
        ggplot(
          aes(
            # x = !!sym(selection()$col_name), 
            x = CV_DT_TEST,
            y = CV_VAL_TEST_VALUE,
            color = CV_CAT_TEST_TYPE,
            linetype = CV_CAT_TEST_STAGE
          )
        ) +
        geom_line()
      
      p <- plot_with_labels(p, display_labels)
      
      p +
        plot_ann() +
        labs(title = paste0("Longitudinal PFT Tests for Subject:  ", input$pulce_id_in))
    })
  })
}

## To be copied in the UI
# mod_tests_ui("tests_ui_1")
    
## To be copied in the server
# mod_tests_server("tests_ui_1")
