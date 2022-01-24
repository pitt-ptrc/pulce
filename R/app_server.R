#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  # Your application server logic 
  mod_about_server("about_ui_1")
  mod_access_server("access_ui_1")
  mod_enroll_server("enroll_ui_1")
  
  # dashboard
  mod_demo_server("demo_ui_1")
  mod_samp_cohort_server("samp_cohort_ui_1")
  mod_tests_server("tests_ui_1")
  mod_samples_server("samples_ui_1")
  mod_care_server("care_ui_1")
}
