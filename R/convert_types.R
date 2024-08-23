#' Convert column types in a data frame
#'
#' @param data A data frame
#' @param type_list A named list specifying column names and their desired types
#' @return A data frame with converted column types
#' @export
convert_types <- function(data, type_list) {
  for (col in names(type_list)) {
    data[[col]] <- switch(type_list[[col]],
                          "numeric" = as.numeric(data[[col]]),
                          "integer" = as.integer(data[[col]]),
                          "character" = as.character(data[[col]]),
                          "factor" = as.factor(data[[col]]),
                          "date" = as.Date(data[[col]]),
                          data[[col]])  # default: no conversion
  }
  data
}