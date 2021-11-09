#' demo UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
#' @importFrom gt gt_output
mod_demo_ui <- function(id){
  ns <- NS(id)
  tagList(
    tabsetPanel(
      tabPanel(
        "All Subjects",
        fluidRow(
          column(
            4,
            plotOutput(ns("age_all"))
          ),
          column(
            8,
            plotOutput(ns("cat_all"))
          )
        )
      ),
      tabPanel(
        "By Study",
        fluidRow(
          column(
            4,
            plotOutput(ns("age_by_study"))
          ),
          column(
            8,
            plotOutput(ns("cat_by_study"))
          )
        )
      ),
      tabPanel(
        "Summary Tables",
        fluidRow(
          column(
            4,
            gt_output(ns("demo_table_all"))
          ),
          column(
            8,
            gt_output(ns("demo_table_by_study"))
          )
        )
      )
    )
  )
}
    
#' demo Server Functions
#'
#' @noRd 
#' @import dplyr
#' @import ggplot2
#' @importFrom tibble tibble
#' @importFrom tidyr pivot_longer pivot_wider
#' @importFrom magrittr %>%
#' @importFrom dbplyr in_schema
#' @importFrom gt gt render_gt
#' @importFrom gtsummary tbl_summary bold_labels as_gt
mod_demo_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    output$cat_all <- renderPlot({
      tbl(pool, "h_demo") %>% 
        distinct(h_id, name, value) %>% 
        filter(name %in% c("h_race", "h_sex")) %>%
        ggplot(aes(value)) +
        geom_bar() +
        facet_grid(cols = vars(name),
                   scales = "free_x") +
        labs(caption = "Note: 'NA' includes values that could not be harmonized.")
    })
    
    output$cat_by_study <- renderPlot({
      tbl(pool, "h_demo") %>%
        distinct(h_data_source, h_id, name, value) %>%
        filter(name %in% c("h_race", "h_sex")) %>%
        ggplot(aes(value)) +
        geom_bar() +
        facet_grid(rows = vars(h_data_source), 
                   cols = vars(name),
                   scales = "free_x") +
        labs(caption = "Note: 'NA' includes values that could not be harmonized.")
    })
    
    output$age_all <- renderPlot({
      tbl(pool, "h_demo") %>% 
        distinct(h_id, age_consent, first_consent) %>% 
        filter(first_consent == "TRUE") %>% 
        ggplot(aes(age_consent)) +
        geom_histogram(binwidth = 1) +
        labs(caption = "Note: age at first consent across studies")
    })
    
    output$age_by_study <- renderPlot({
      tbl(pool, "h_demo") %>% 
        distinct(h_data_source, h_id, age_consent) %>% 
        ggplot(aes(age_consent)) +
        geom_histogram(binwidth = 1) +
        facet_grid(rows = vars(h_data_source), 
                   scales = "free_x")
    })
    

# gt tables ---------------------------------------------------------------
    
    # create tibble good for gt
    # 
    # islands_tbl <- 
    #   tibble(
    #     name = names(islands),
    #     size = islands
    #   ) %>%
    #   arrange(desc(size)) %>%
    #   slice(1:10)
    # 
    # # Create a display table showing ten of
    # # the largest islands in the world
    # gt_tbl <- gt(islands_tbl)
    
    output$demo_table_all <-
      render_gt(
        tbl(pool, "h_demo") %>% 
          pivot_wider(names_from = name, values_from = value) %>% 
          filter(first_consent == "TRUE") %>%
          # We have to `distinct` some consented at the same time to multiple studies
          # group_by(h_id) %>% 
          # filter(n() == 2)
          distinct(age_consent, h_race, h_sex, h_hisp) %>% 
          collect() %>% 
          tbl_summary() %>% 
          bold_labels() %>% 
          as_gt()
      )
    
    output$demo_table_by_study <-
      render_gt(
        tbl(pool, "h_demo") %>% 
          pivot_wider(names_from = name, values_from = value) %>% 
          # filter(first_consent == "TRUE") %>%
          distinct(h_data_source, age_consent, h_race, h_sex, h_hisp) %>% 
          collect() %>% 
          tbl_summary(
            by = h_data_source
          ) %>% 
          bold_labels() %>% 
          as_gt()
      )
 
  })
}
    
## To be copied in the UI
# mod_demo_ui("demo_ui_1")
    
## To be copied in the server
# mod_demo_server("demo_ui_1")
