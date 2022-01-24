#' theme 
#'
#' @description A utils function
#'
#' @return The return value, if any, from executing the utility.
#'
#'
#' @importFrom bslib bs_theme font_google
#' @importFrom thematic thematic_shiny font_spec
#' @import ggplot2
#'
#' @noRd

setup_theme <- function(){
  ggplot2::theme_set(ggplot2::theme_minimal(base_size = 18))
  # thematic::thematic_shiny(font = thematic::font_spec("Pacifico", scale = 2))
  # thematic::thematic_shiny(
  #   bg = "auto", 
  #   fg = "#003594", 
  #   accent = "auto", 
  #   font = "auto"
  # )
}

get_pitt_theme <- function(){
  # bs_theme(
  #   # Controls the default grayscale palette
  #   bg = "#FFFFFF",
  #   fg = "#75787B",
  #   # Controls the accent (e.g., hyperlink, button, etc) colors
  #   primary = "#003594",
  #   secondary = "#FFB81C",
  #   base_font = c("Open Sans", "sans-serif"),
  #   code_font = c("Courier", "monospace"),
  #   # heading_font = "'Helvetica Neue', Helvetica, sans-serif",
  #   heading_font = bslib::font_google("Rubik", local = TRUE),
  #   # Can also add lower-level customization
  #   "input-border-color" = "#EA80FC"
  # )
  theme <- bs_theme(
    bootswatch = "flatly",
    # Controls the default grayscale palette
    # bg = "#FFFFFF",
    # fg = "#75787B",
    # Controls the accent (e.g., hyperlink, button, etc) colors
    primary = "#003594",
    success = "#E3A417",
    base_font = c("Open Sans", "sans-serif"),
    code_font = c("Courier", "monospace"),
    # heading_font = "'Helvetica Neue', Helvetica, sans-serif",
    heading_font = bslib::font_google("Rubik", local = TRUE),
    # Can also add lower-level customization
    # "input-border-color" = "#EA80FC"
  )
  
  bslib::bs_add_rules(theme, ".navbar-brand { color: #e3a417 !important; }")
}


# layout customization ----------------------------------------------------

# tabPanel <- function(...) {
#   shiny::tabPanel(..., class = "p-3 border border-top-0 rounded-bottom")
# }


