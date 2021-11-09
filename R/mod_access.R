#' access UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList req
#' @importFrom shinyjs useShinyjs hidden show reset
#' @importFrom DT dataTableOutput
mod_access_ui <- function(id){
  ns <- NS(id)
  tagList(
    shinyjs::useShinyjs(),
    shinyjs::hidden(
      div(
        id = ns("thankyou_msg"),
        fluidRow(
          h3("Thanks, your response was submitted successfully!")
        )
      )
    ),
    sidebarLayout(
      sidebarPanel(
        tags$body("Request Access"),
        tags$hr(),
        div(
          id = ns("form"),
          selectInput(ns("study"),
                      "For which study?",
                      choices = study_choices,
                      multiple = TRUE), 
          textInput(ns("user_first_name"), "Your First Name", ""),
          textInput(ns("user_last_name"), "Your Last Name", ""),
          textInput(ns("email"), "Email", ""),
          checkboxInput(ns("is_pitt_id"), "Is this a Pitt account?", FALSE),
          textOutput(ns("greeting")),
          actionButton(ns("submit"), "Submit"),
        )
      ),
      mainPanel(
        DT::dataTableOutput(ns("pulce_studies"))
      )
    )
    # FOR Check submissions
    # fluidRow(
    #   DT::dataTableOutput(ns("test_pulce_user"), width = 300)
    # )
  )
}
    
#' access Server Functions
#'
#' @noRd 
#' 
#' @import shinyvalidate
#' @importFrom dplyr tbl


# # Define the table we want to save the form data to
# table <- "pulce_access_request"
# 
# # Define fn to get submission time
# submission_time <- function() {
#   Sys.time()
# }
# 
# # Define the fields we want to save from the form
# fields <- colnames(tbl(pool, table))


print("hello access mod")
# print(fields)

mod_access_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    # Define the table we want to save the form data to
    table <- "pulce_access_request"
    
    # Define fn to get submission time
    submission_time <- function() {
      as.integer(Sys.time())
    }
    
    # Define the fields we want to save from the form
    # Drop last element, timestamp?
    fields <- head(colnames(tbl(pool, table)), -1)
    
    print("hello access server")
    print(table)
    print(fields)

    # 0. Create validation functions
    
    # From https://www.nicebread.de/validating-email-adresses-in-r/
    is_valid_email <- function(x) {
      grepl("^\\s*[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}\\s*$", as.character(x), ignore.case=TRUE)
    }
    is_valid_pitt_email <- function(x) {
      grepl("^\\s*[A-Z0-9._%+-]+@[pitt]+\\.[A-Z]{2,}\\s*$", as.character(x), ignore.case=TRUE)
    }
    
    # 1. Create an InputValidator object
    iv <- shinyvalidate::InputValidator$new()
    
    # 2. Add validation rules
    iv$add_rule("study", sv_required())
    iv$add_rule("user_first_name", sv_required())
    iv$add_rule("user_last_name", sv_required())
    iv$add_rule("email", sv_required())
    # iv$add_rule("email", ~ if (!is_valid_email(.)) "Not a valid email")
    iv$add_rule("email", ~ if (!is_valid_pitt_email(.)) "Not a valid Pitt email")
    
    # 3. Start displaying errors in the UI
    iv$enable()
    
    # Whenever a field is filled, aggregate all form data
    formData <- reactive({
      data <- sapply(fields, function(x) input[[x]])
      data <- c(data, timestamp = submission_time())
      data
    })
    
    # When the Submit button is clicked, save the form data
    observeEvent(input$submit, {
      if (req(iv$is_valid())){
        saveData(formData(), table)
        shinyjs::reset("form")
        # shinyjs::hide("form")
        shinyjs::show("thankyou_msg")
      }
      # else {
      #   shinyjs::show("complete_msg")
      # }
    })
    
    # Show the previous responses
    # (update with current response when Submit is clicked)
    # FOR debugging
    # output$test_pulce_user <- DT::renderDataTable({
    #   input$submit
    #   loadData(table)
    # })
    
    output$pulce_studies <- DT::renderDataTable({
      studies_display
    }, escape = FALSE, options = list(dom = 't'))
    
    output$greeting <- renderText({
      # 4. Don't proceed if any input is invalid
      req(iv$is_valid())
      
      paste0("Nice to meet you, ", input$user_first_name, " <", input$email, ">!")
    })
  })
}
    
## To be copied in the UI
# mod_access_ui("access_ui_1")
    
## To be copied in the server
# mod_access_server("access_ui_1")
