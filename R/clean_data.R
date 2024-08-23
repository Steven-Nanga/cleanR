#' Clean data by applying multiple cleaning functions
#'
#' @param data A data frame
#' @param duplicate_cols Columns to consider when removing duplicates
#' @param categorical_cols Categorical columns to standardize
#' @param type_list A named list specifying column types to convert
#' @param outlier_cols Numeric columns to check for outliers
#' @param outlier_method Method for outlier detection
#' @param outlier_threshold Threshold for outlier detection
#' @return A cleaned data frame
#' @export
clean_data <- function(data, 
                       duplicate_cols = NULL, 
                       categorical_cols = NULL,
                       type_list = NULL,
                       outlier_cols = NULL,
                       outlier_method = "iqr",
                       outlier_threshold = 1.5) {
  
  if (!is.null(duplicate_cols)) {
    data <- remove_duplicates(data, duplicate_cols)
  }
  
  if (!is.null(categorical_cols)) {
    data <- standardize_categories(data, categorical_cols)
  }
  
  if (!is.null(type_list)) {
    data <- convert_types(data, type_list)
  }
  
  if (!is.null(outlier_cols)) {
    data <- remove_outliers(data, outlier_cols, outlier_method, outlier_threshold)
  }
  
  return(data)
}