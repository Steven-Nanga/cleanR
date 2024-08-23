#' Standardize categorical variables
#'
#' @importFrom dplyr mutate across all_of
#' @importFrom stringr str_trim str_to_lower str_replace_all
#'
#' @param data A data frame
#' @param cols Categorical columns to standardize
#' @return A data frame with standardized categorical variables
#' @export
standardize_categories <- function(data, cols) {
  data %>%
    mutate(across(all_of(cols), ~str_trim(.) %>%
                    str_to_lower() %>%
                    str_replace_all("[^[:alnum:]]", "_")))
}