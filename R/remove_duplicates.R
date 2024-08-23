#' Remove duplicate rows from a data frame
#'
#' @importFrom dplyr distinct across all_of
#'
#' @param data A data frame
#' @param cols Columns to consider when identifying duplicates
#' @return A data frame with duplicates removed
#' @export
remove_duplicates <- function(data, cols = NULL) {
  if (is.null(cols)) {
    cols <- names(data)
  }
  data %>% distinct(across(all_of(cols)), .keep_all = TRUE)
}