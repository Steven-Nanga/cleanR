#' Handle missing values in a data frame
#'
#' Provides several strategies for dealing with \code{NA} values: remove rows
#' containing them, or impute with mean, median, mode, or a constant value.
#'
#' @importFrom dplyr mutate across all_of
#'
#' @param data A data frame
#' @param cols Character vector of column names to handle. Defaults to all columns.
#' @param method Method for handling missing values. One of:
#'   \describe{
#'     \item{\code{"remove"}}{Remove rows that contain \code{NA} in the specified columns.}
#'     \item{\code{"mean"}}{Replace \code{NA} with the column mean (numeric columns only).}
#'     \item{\code{"median"}}{Replace \code{NA} with the column median (numeric columns only).}
#'     \item{\code{"mode"}}{Replace \code{NA} with the most frequent value.}
#'     \item{\code{"constant"}}{Replace \code{NA} with the value given in \code{fill_value}.}
#'   }
#' @param fill_value Value to use when \code{method = "constant"}. Ignored otherwise.
#' @return A data frame with missing values handled
#' @export
handle_missing <- function(data, cols = NULL, method = "remove", fill_value = NULL) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }

  valid_methods <- c("remove", "mean", "median", "mode", "constant")
  if (!method %in% valid_methods) {
    stop('`method` must be one of: ', paste(valid_methods, collapse = ", "), call. = FALSE)
  }

  if (method == "constant" && is.null(fill_value)) {
    stop('`fill_value` must be provided when method = "constant".', call. = FALSE)
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

  if (method == "remove") {
    complete <- complete.cases(data[, cols, drop = FALSE])
    data <- data[complete, , drop = FALSE]
    return(data)
  }

  if (method %in% c("mean", "median")) {
    non_numeric <- cols[!vapply(data[cols], is.numeric, logical(1))]
    if (length(non_numeric) > 0) {
      stop("Column(s) must be numeric for method '", method, "': ",
           paste(non_numeric, collapse = ", "), call. = FALSE)
    }
  }

  for (col in cols) {
    na_idx <- is.na(data[[col]])
    if (!any(na_idx)) next

    replacement <- switch(method,
      "mean" = mean(data[[col]], na.rm = TRUE),
      "median" = stats::median(data[[col]], na.rm = TRUE),
      "mode" = {
        tbl <- table(data[[col]])
        names(tbl)[which.max(tbl)]
      },
      "constant" = fill_value
    )

    # For mode, coerce replacement to match column type
    if (method == "mode" && is.numeric(data[[col]])) {
      replacement <- as.numeric(replacement)
    }

    data[[col]][na_idx] <- replacement
  }

  data
}
