#' Convert column types in a data frame
#'
#' @param data A data frame
#' @param type_list A named list specifying column names and their desired types.
#'   Supported types: "numeric", "integer", "character", "factor", "date", "logical".
#' @param date_format Optional date format string (e.g. "\%Y-\%m-\%d") used when
#'   converting to date type. Defaults to NULL which lets \code{as.Date} guess.
#' @return A data frame with converted column types
#' @export
convert_types <- function(data, type_list, date_format = NULL) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  if (!is.list(type_list) || is.null(names(type_list))) {
    stop("`type_list` must be a named list.", call. = FALSE)
  }

  missing_cols <- setdiff(names(type_list), names(data))
  if (length(missing_cols) > 0) {
    stop("Column(s) not found in data: ", paste(missing_cols, collapse = ", "), call. = FALSE)
  }

  valid_types <- c("numeric", "integer", "character", "factor", "date", "logical")
  invalid_types <- setdiff(unlist(type_list), valid_types)
  if (length(invalid_types) > 0) {
    stop("Unsupported type(s): ", paste(invalid_types, collapse = ", "),
         ". Supported types: ", paste(valid_types, collapse = ", "), call. = FALSE)
  }

  for (col in names(type_list)) {
    data[[col]] <- switch(type_list[[col]],
                          "numeric" = as.numeric(data[[col]]),
                          "integer" = as.integer(data[[col]]),
                          "character" = as.character(data[[col]]),
                          "factor" = as.factor(data[[col]]),
                          "date" = if (!is.null(date_format)) {
                            as.Date(data[[col]], format = date_format)
                          } else {
                            as.Date(data[[col]])
                          },
                          "logical" = as.logical(data[[col]]),
                          data[[col]])
  }
  data
}
