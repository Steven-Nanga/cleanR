#' Remove duplicate rows from a data frame
#'
#' @importFrom dplyr distinct across all_of
#'
#' @param data A data frame
#' @param cols Character vector of column names to consider when identifying
#'   duplicates. Defaults to all columns.
#' @return A data frame with duplicates removed
#' @export
remove_duplicates <- function(data, cols = NULL) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }

  if (is.null(cols)) {
    cols <- names(data)
  }

  if (!is.character(cols) || length(cols) == 0) {
    stop("`cols` must be a non-empty character vector.", call. = FALSE)
  }

  missing_cols <- setdiff(cols, names(data))
  if (length(missing_cols) > 0) {
    stop("Column(s) not found in data: ", paste(missing_cols, collapse = ", "), call. = FALSE)
  }

  data %>% distinct(across(all_of(cols)), .keep_all = TRUE)
}
