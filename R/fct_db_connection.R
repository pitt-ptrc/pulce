#' db_connection 
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd
#' @importFrom DBI dbConnect dbGetQuery dbDisconnect
#' @importFrom magrittr %>%
#' @importFrom dplyr collect tbl select mutate if_else filter starts_with
#' @importFrom stringr str_c str_detect
#' @importFrom tibble deframe
#' @importFrom tidyr separate
#' @importFrom pool dbPool poolClose
#' 


get_db <- function(){
  
  dbinfo <- get_golem_config("dataconnection")
  
  pool::dbPool(
    odbc::odbc(),
    Driver = dbinfo$driver,
    Server = "paccmdb.database.windows.net",
    Database = "paccmdb",
    Uid = dbinfo$uid,
    Pwd = dbinfo$pwd,
    Encrypt = "yes",
    TrustServerCertificate = "no",
    timeout = 10
  )
}

pool <- get_db()

saveData <- function(data, table) {
  # Connect to the database
  db <- pool
  # Construct the update query by looping over the data fields
  query <- sprintf(
    "INSERT INTO %s (%s) VALUES ('%s')",
    table,
    paste(names(data), collapse = ", "),
    paste(data, collapse = "', '")
  )
  # Submit the update query and disconnect
  DBI::dbGetQuery(db, query)
  # DBI::dbDisconnect(db)
}

loadData <- function(table) {
  # Connect to the database
  db <- pool
  # Construct the fetching query
  query <- sprintf("SELECT * FROM %s", table)
  # Submit the fetch query and disconnect
  data <- dbGetQuery(db, query)
  # DBI::dbDisconnect(db)
  data
}

get_table <- function(table) {
  db <- pool
  table <- dplyr::tbl(db, table) %>% dplyr::collect()
  # DBI::dbDisconnect(db)
  table
}

studies <- get_table("pulce_studies")

studies_display <- studies %>%
  dplyr::mutate(link = dplyr::if_else(
    !is.na(link),
    true = paste0("<a href='",  link, "'>External Link</a>"),
    false = "None"
  )) %>% 
  dplyr::mutate(investigator = paste(pi_first_name, pi_last_name, " ")) %>% 
  dplyr::select(study = display_name, investigator, topic, description = long_description, link)

study_choices <- studies %>%
  dplyr::select(display_name, schema) %>%
  tibble::deframe()


# about data prep ---------------------------------------------------------

# dashboard data prep ---------------------------------------------------------------

# REFACTOR!!

get_schema_cols <- function(conn) {
  dplyr::tbl(conn, dbplyr::in_schema("information_schema", "columns")) %>% 
    dplyr::collect()
}

schema_cols <- get_schema_cols(pool)

# display names -----------------------------------------------------------

display_feat_dict <- c(
  AGE       = "Age",
  DOB       = "Birth",
  DOD       = "Death",
  ETH_HS    = "Ethnicity: Hispanic",
  HOSP      = "Hospital",
  LABSRC    = "Lab Source",
  LABSTG    = "Lab Stage",
  ORDER     = "Order",
  RACE      = "Race",
  SEX       = "Sex",
  STAGE     = "Stage",
  TYPE      = "Type",
  VALUE     = "Value"
)

display_ent_dict <- c(
  DIAG     = "Diagnosis",
  PULCE    = "PULCE",
  SAMP     = "Sample",
  SUBJ     = "Subject",
  TEST     = "Test",
  TREAT    = "Treatment"
)

display_data_dict <- c(
  AMT    = "Amount",
  CAT    = "Type",
  DT     = "Date",
  ID     = "ID",
  N      = "Count",
  VAL    = "Value"
)

display_labels <- schema_cols %>% 
  filter(stringr::str_detect(COLUMN_NAME, "^CV_")) %>% 
  tidyr::separate(
    COLUMN_NAME,
    sep = "_",
    into = c("cv", "cv_data", "cv_entity", "cv_feature"),
    extra = "merge",
    remove = FALSE
  ) %>% 
  mutate(display_feat = recode(cv_feature, !!!display_feat_dict)) %>%
  mutate(display_data = recode(cv_data, !!!display_data_dict)) %>%
  mutate(display_ent = recode(cv_entity, !!!display_ent_dict)) %>%
  select(starts_with("display"), starts_with("cv"), COLUMN_NAME) %>% 
  mutate(
    display_name = if_else(
      is.na(display_feat),
      stringr::str_c(display_ent, display_data, sep = " "),
      stringr::str_c(display_ent, display_feat, sep = " ")
    )
  ) %>% 
  select(COLUMN_NAME, display_name) %>% 
  deframe()

# TODO: better solution for nuisance labels
display_labels <- c(display_labels,
                    n = "Count",
                    age_consent = "Age at Consent",
                    h_race = "Race",
                    h_sex = "Sex",
                    h_hisp = "Hispanic")

plot_with_labels <- function(p, l) {
  swap <- function(x) {
    if (is.null(attr(x, "fallback"))) {
      as.character(l[x]) 
    } else {
      x
    }
  }
  p$labels <- lapply(p$labels, swap)
  return(p)
}


# table references --------------------------------------------------------

get_tbl_ref <- function(schema_cols, str_col, str_tbl, str_sch = "m_") {
  schema_cols %>%
    dplyr::filter(stringr::str_detect(TABLE_SCHEMA, str_sch)) %>%
    dplyr::filter(stringr::str_detect(COLUMN_NAME, str_col)) %>%
    dplyr::filter(stringr::str_detect(TABLE_NAME, stringr::regex(str_tbl, ignore_case = T))) %>%
    dplyr::select(schema = TABLE_SCHEMA,
                  table = TABLE_NAME,
                  col_name = COLUMN_NAME)
}

ref_demo_ids <- get_tbl_ref(schema_cols = schema_cols,
                            str_col = "ID_PULCE",
                            str_tbl = "subj")

ref_samp_ids <- get_tbl_ref(schema_cols = schema_cols,
                            str_col = "CAT_SAMP",
                            str_tbl = "samp")

ref_test_ids <- get_tbl_ref(schema_cols = schema_cols,
                            str_col = "CAT_TEST",
                            # str_tbl = "pft"
                            # temp patch
                            str_tbl = "pft_mod"
                            )

ref_ids <- get_tbl_ref(schema_cols = schema_cols,
                       str_col = "DT_TEST",
                       # str_tbl = "pft"
                       # temp patch
                       str_tbl = "pft_mod")

ref_care_ids <- get_tbl_ref(schema_cols = schema_cols,
                       str_col = "TREAT|DIAG",
                       # str_tbl = "pft"
                       # temp patch
                       str_tbl = "care")



# CV_ID prep --------------------------------------------------------------


# prep_ids <- function(con, schema, table, ...){
#   dplyr::tbl(con, dbplyr::in_schema(schema = schema, table = table)) %>% 
#     dplyr::select(CV_ID_PULCE) %>% 
#     dplyr::mutate(!!as.name(schema) := TRUE) %>% 
#     dplyr::collect()
# }
# 
# pulce_id_table_list <- purrr::pmap(ref_demo_ids, ~ prep_ids(pool, .x, .y)) 
# 
# pulce_id_table <- pulce_id_table_list %>%
#   purrr::reduce(dplyr::full_join, by = "CV_ID_PULCE") %>% 
#   replace(is.na(.), values = 0)

pulce_id_table <- tbl(pool, "pulce_id_study")

# close pool --------------------------------------------------------------



onStop(function() {
  pool::poolClose(pool)
  print("pool closing!")
})