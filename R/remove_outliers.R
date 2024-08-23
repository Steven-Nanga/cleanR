#' Remove outliers from numeric columns
#'
#' @param data A data frame
#' @param cols Numeric columns to check for outliers
#' @param method Method to use for outlier detection ("iqr" or "zscore")
#' @param threshold Threshold for outlier detection
#' @return A data frame with outliers removed
#' @export
remove_outliers <- function(data, cols, method = "iqr", threshold = 1.5) {
  for (col in cols) {
    if (method == "iqr") {
      Q1 <- quantile(data[[col]], 0.25, na.rm = TRUE)
      Q3 <- quantile(data[[col]], 0.75, na.rm = TRUE)
      IQR <- Q3 - Q1
      lower_bound <- Q1 - threshold * IQR
      upper_bound <- Q3 + threshold * IQR
      data <- data[data[[col]] >= lower_bound & data[[col]] <= upper_bound, ]
    } else if (method == "zscore") {
      z_scores <- scale(data[[col]])
      data <- data[abs(z_scores) <= threshold, ]
    }
  }
  data
}