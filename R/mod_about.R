#' about UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_about_ui <- function(id){
  ns <- NS(id)
  tagList(
    sidebarLayout(
      sidebarPanel(
        tags$body("PULCE (PULmonary Centralized DatabasE) is a collection of de-identified databases from participating investigators primarily in the PACCM Division of the Department of Medicine and managed by the Pulmonary Translational Research Core (PTRC). It consists of:"),
        tags$ul(
          tags$li("Multiple raw de-identified study databases, with unique patient/subject IDs across studies."),
          tags$li("Single harmonized and validated database derived from the raw databases and following standard conventions"),
          tags$li("Dashboard for exploring both raw and harmonized databases through visualizations and models. Identifiers are removed and dates shifted."),
          tags$li("Securely managed access to query selected databases.")
        ),
        tags$a(
          "(See our data catalog)",
          href = "https://pitt-my.sharepoint.com/:b:/g/personal/mjb357_pitt_edu/EbFppLVvaSFIjJex9Ac6OHIBBuih6QNlI43Yk46OGrERtg?e=rs9f2d",
          target = "_blank"
        )
      ),
      mainPanel(
        plotOutput(ns("plot"))
      )
    )
  )
}

#' about Server Functions
#'
#' @noRd 
#' @import ggplot2
#' @importFrom magrittr %>%
#' @import ComplexUpset
mod_about_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    output$plot <- renderPlot({
      ComplexUpset::upset(
        pulce_id_table, 
        colnames(pulce_id_table)[-1],
        name = "Subject Overlap",
        themes = upset_default_themes(
          text = element_text(size = 20),
          axis.text = element_text(size = 20)
        )
      )
      # ggtitle('Study Databases, by absolute and overlap size.')
    }) %>% 
      bindCache(pulce_id_table)
    # output$sample_box <- shinydashboard::renderInfoBox({
    #   shinydashboard::infoBox(
    #     "Samples", studies$name[1],
    #     color = "yellow"
    #   )
    # })
  })
}

## To be copied in the UI
# mod_about_ui("about_ui_1")

## To be copied in the server
# mod_about_server("about_ui_1")
