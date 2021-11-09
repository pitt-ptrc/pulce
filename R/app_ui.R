#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  setup_theme()
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic 
    navbarPage(
      theme = get_pitt_theme(),
      "PULCE",
      tabPanel("About", mod_about_ui("about_ui_1")),
      tabPanel("Access", mod_access_ui("access_ui_1")),
      tabPanel("Enroll", mod_enroll_ui("enroll_ui_1")),
      tabPanel(
        "Dashboard",
        navlistPanel(
          # fluid = FALSE,
          widths = c(2, 10),
          "Harmonized",
          tabPanel("Demographics", mod_demo_ui("demo_ui_1")),
          "Per Study",
          tabPanel("Care", mod_care_ui("care_ui_1")),
          tabPanel("Repeated Tests", mod_tests_ui("tests_ui_1")),
          tabPanel("Samples", mod_samples_ui("samples_ui_1")),
          tabPanel("Models")
        )
      )
    )
  )
}

#' Add external Resources to the Application
#' 
#' This function is internally used to add external 
#' resources inside the Shiny application. 
#' 
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){
  
  add_resource_path(
    'www', app_sys('app/www')
  )
 
  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'egggolemreg'
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert() 
  )
}

