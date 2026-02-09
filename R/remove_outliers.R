#' Remove outliers from numeric columns
#'
#' Rows with NA values in the checked columns are preserved (not removed).
#'
#' @param data A data frame
#' @param cols Character vector of numeric column names to check for outliers
#' @param method Method to use for outlier detection ("iqr" or "zscore")
#' @param threshold Threshold for outlier detection (default 1.5 for IQR, 3 for z-score)
#' @return A data frame with outliers removed
#' @export
remove_outliers <- function(data, cols, method = "iqr", threshold = 1.5) {
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

  non_numeric <- cols[!vapply(data[cols], is.numeric, logical(1))]
  if (length(non_numeric) > 0) {
    stop("Column(s) must be numeric: ", paste(non_numeric, collapse = ", "), call. = FALSE)
  }

  if (!method %in% c("iqr", "zscore")) {
    stop('`method` must be one of "iqr" or "zscore".', call. = FALSE)
  }

  for (col in cols) {
    if (method == "iqr") {
      q1 <- quantile(data[[col]], 0.25, na.rm = TRUE)
      q3 <- quantile(data[[col]], 0.75, na.rm = TRUE)
      iqr_val <- q3 - q1
      lower_bound <- q1 - threshold * iqr_val
      upper_bound <- q3 + threshold * iqr_val
      keep <- data[[col]] >= lower_bound & data[[col]] <= upper_bound
      data <- data[keep | is.na(keep), , drop = FALSE]
    } else if (method == "zscore") {
      z_scores <- scale(data[[col]])
      keep <- abs(z_scores) <= threshold
      data <- data[keep | is.na(keep), , drop = FALSE]
    }
  }
  data
}
