#' samp_cohort UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 

h_samp <- tbl(pool, "h_samp")

sample_choice <- 
  h_samp %>% 
  select(CV_CAT_SAMP_TYPE) %>% 
  distinct() %>% 
  pull()

mod_samp_cohort_ui <- function(id){
  ns <- NS(id)
  tagList(
    tabsetPanel(
      tabPanel(
        "Unique Patients",
        plotOutput(ns("barplot_unique"))
      ),
      tabPanel(
        "Total Samples",
        plotOutput(ns("barplot"))
      )
    ),
    selectizeInput(
      ns("sample_select"),
      label = "Sample Types",
      choices = sample_choice,
      multiple = TRUE
    ),
    downloadButton(ns("downloadData"), "Download Cohort")
  )
}
    
#' samp_cohort Server Functions
#'
#' @noRd 
#' @import dplyr
#' @importFrom ggplot2 coord_flip xlab ylab
#' @importFrom dbplot dbplot_bar
#' @importFrom dbplyr in_schema
#' @importFrom magrittr %>%
#' 
mod_samp_cohort_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    output$barplot <- renderPlot({
      h_samp %>% 
        dbplot::dbplot_bar(CV_CAT_SAMP_TYPE) +
        xlab("Samples") +
        ylab("Count") +
        coord_flip()
    })
    
    output$barplot_unique <- renderPlot({
      h_samp %>% 
        distinct(CV_ID_PULCE, CV_CAT_SAMP_TYPE) %>% 
        dbplot::dbplot_bar(CV_CAT_SAMP_TYPE) +
        xlab("Samples") +
        ylab("Count") +
        coord_flip()
    })
    
    cohort_ids <- eventReactive(input$sample_select, {
      h_samp %>% 
        distinct(CV_ID_PULCE, CV_CAT_SAMP_TYPE) %>% 
        filter(CV_CAT_SAMP_TYPE %in% !!input$sample_select) %>% 
        select(pulce_id = CV_ID_PULCE, sample_type = CV_CAT_SAMP_TYPE)
    })
    
    output$downloadData <- downloadHandler(
      filename = function() {
        paste("cohort_", Sys.Date(), ".csv", sep = "")
      },
      content = function(file) {
        write.csv(cohort_ids(), file, row.names = FALSE)
      }
    )
  })
}
    
## To be copied in the UI
# mod_samp_cohort_ui("samp_cohort_ui_1")
    
## To be copied in the server
# mod_samp_cohort_server("samp_cohort_ui_1")
