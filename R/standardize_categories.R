#' Standardize categorical variables
#'
#' Trims whitespace, converts to lowercase, and replaces non-alphanumeric
#' characters with underscores.
#'
#' @importFrom dplyr mutate across all_of
#' @importFrom stringr str_trim str_to_lower str_replace_all
#'
#' @param data A data frame
#' @param cols Character vector of categorical column names to standardize
#' @return A data frame with standardized categorical variables
#' @export
standardize_categories <- function(data, cols) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  if (!is.character(cols) || length(cols) == 0) {
    stop("`cols` must be a non-empty character vector.", call. = FALSE)
  }

  missing_cols <- setdiff(cols, names(data))
  if (length(missing_cols) > 0) {
    stop("Column(s) not found in data: ", paste(missing_cols, collapse = ", "), call. = FALSE)
  }

  data %>%
    mutate(across(all_of(cols), ~str_trim(.) %>%
                    str_to_lower() %>%
                    str_replace_all("[^[:alnum:]]", "_")))
}
