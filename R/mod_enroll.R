#' enroll UI Function
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
mod_enroll_ui <- function(id){
  ns <- NS(id)
  tagList(
    shinyjs::useShinyjs(),
    shinyjs::hidden(
      div(
        id = ns("thankyou_msg"),
        fluidRow(
          tags$body("Thanks, your response was submitted successfully!")
        )
      )
    ),
    div(
      id = ns("form"),
      fluidRow(
        column(
          width = 3,
          wellPanel(
            tags$body("Principal Investigator"),
            tags$hr(),
            textInput(ns("pi_first_name"), "PI First Name", ""),
            textInput(ns("pi_last_name"), "PI Last Name", ""),
            textInput(ns("pi_contact"), "PI Contact Email", ""),
            textInput(ns("pitt_id"), "PI Pitt Email", ""),
            checkboxInput(ns("is_pi"), "Are you the PI?", FALSE),
            textOutput(ns("greeting"))
          )
        ),
        column(
          width = 3,
          wellPanel(
            tags$body("Study"),
            tags$hr(),
            textInput(ns("study_name"), "Study name", ""),
            selectInput(
              ns("study_type"),
              label = "Study type",
              choices = c(
                "cohort",
                "case-control",
                "cross-sectional",
                "panel",
                "experiment",
                "other",
                "unsure"
              ),
              multiple = FALSE
            ),
            selectInput(
              ns("study_domain"),
              label = "Study Domain",
              choices = c(
                "pulmonary",
                "allergy",
                "critical_care",
                "genetic",
                "other"
              ),
              multiple = TRUE
            ),
            selectInput(
              ns("data_source"),
              label = "Data Source",
              choices = c(
                "observational",
                "experimental",
                "administrative",
                "survey",
                "other"
              ),
              multiple = TRUE
            ),
            selectInput(
              ns("data_format"),
              label = "Data Format",
              choices = c(
                "access",
                "excel",
                "sql_database",
                "csv",
                "redcap",
                "other"
              ),
              multiple = TRUE
            ),
            checkboxInput(ns("biosamples"), "Contains biosamples?")
          )
        ),
        column(
          width = 6,
          wellPanel(
            tags$body("Description"),
            tags$hr(),
            textInput(
              ns("topic"),
              # label = "Link",
              span("Topic, in a few words"
              ),
              value = "eg: HIV"
            ),
            textAreaInput(
              ns("short_description"),
              label = "One sentence summary",
              rows = 2,
              width = '100%',
              value = "a short description"
            ),
            textInput(
              ns("url"),
              # label = "Link",
              span("Link to description"
                   # tags$br(),
                   # tags$a(
                   #   "(for example)",
                   #   href = "https://clinicaltrials.gov/ct2/show/NCT02238327",
                   #   target = "_blank"
                   # )
              ),
              value = "eg: https://clinicaltrials.gov/ct2/show/NCT02238327"
            ),
            textAreaInput(
              ns("long_description"),
              # label = "Please provide a longer description or a link",
              span("Or provide a longer description",
                   # tags$br(),
                   tags$a(
                     "(See our style guide)",
                     href = "https://docs.google.com/document/d/1OaHGzmWrmnXYVJPVyXYUKQoLknL-aw8Um6BKmFMO5zE/edit?usp=sharing",
                     target = "_blank"
                   ),
              ),
              rows = 5,
              value = "a longer description"
            ),
            fileInput(
              ns("upload_data"), 
              span("Optional: Upload data",
                   # tags$br(),
                   tags$a(
                     "(See our migration guide)",
                     href = "https://docs.google.com/document/d/14Ows7NXdpPOuefR-0bg2nUY86U4DecRzMFC-X09PoYI/edit?usp=sharing",
                     target = "_blank"
                   )
              ),
              accept = c('text/csv', 'text/comma-separated-values,text/plain', '.csv', '.xlsx', '.accdb', 'rds')
            ),
            div(
              actionButton(ns("submit"), "Submit"),
              style="float:right",
              style="display:inline-block"
              
            )
          )
        )
      )
    )
    # end of form
    # FOR checking submission works
    # fluidRow(
    #   DT::dataTableOutput(ns("test_registration"))
    # )
  )
}

#' enroll Server Functions
#'
#' @noRd 
#' 
#' @import shinyvalidate
#' @importFrom dplyr tbl

mod_enroll_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    # Define the table we want to save the form data to
    table <- "pulce_enroll_request"
    
    # Define fn to get submission time
    submission_time <- function() {
      as.integer(Sys.time())
    }
    
    # Define the fields we want to save from the form
    # I think sapply() later reorders/selects the named list `input` object 
    # as `fields` col vec module var
    # Drop last element, timestamp?
    fields <- head(colnames(tbl(pool, table)), -1)
    
    # 0. Create validation functions
    
    # From https://www.nicebread.de/validating-email-adresses-in-r/
    is_valid_email <- function(x) {
      grepl("^\\s*[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}\\s*$", as.character(x), ignore.case=TRUE)
    }
    is_valid_pitt_email <- function(x) {}
    
    # 1. Create an InputValidator object
    iv <- shinyvalidate::InputValidator$new()
    
    # 2. Add validation rules
    # PI
    iv$add_rule("pi_first_name", sv_required())
    iv$add_rule("pi_last_name", sv_required())
    iv$add_rule("pi_contact", sv_required())
    iv$add_rule("pi_contact", ~ if (!is_valid_email(.)) "Not a valid email")
    iv$add_rule("pitt_id", sv_required())
    iv$add_rule("pitt_id", ~ if (!is_valid_email(.)) "Not a valid email")
    iv$add_rule("is_pi", sv_required())
    # iv$add_rule("pitt_email", if (!is_valid_pitt_email(.), "Not a Pitt email"))
    
    # STUDY
    iv$add_rule("study_name", sv_required())
    iv$add_rule("study_type", sv_required())
    iv$add_rule("study_domain", sv_required())
    iv$add_rule("data_source", sv_required())
    iv$add_rule("data_format", sv_required())
    iv$add_rule("biosamples", sv_required())
    
    # DESCRIPTION
    iv$add_rule("short_description", sv_required())
    
    
    # 3. Start displaying errors in the UI
    iv$enable()
    
    # Whenever a field is filled, aggregate all form data
    # sapply() here reorders/selects the named list `input` object as `fields` col vec module var
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
    # output$test_registration <- DT::renderDataTable({
    #   input$submit
    #   loadData(table)
    # })
    
    output$greeting <- renderText({
      # 4. Don't proceed if any input is invalid
      req(iv$is_valid())
      
      paste0("Nice to meet you, ", input$user_first_name, " <", input$email, ">!")
    })
  })
}

## To be copied in the UI
# mod_enroll_ui("enroll_ui_1")

## To be copied in the server
# mod_enroll_server("enroll_ui_1")
