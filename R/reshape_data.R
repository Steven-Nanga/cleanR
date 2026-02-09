#' Reshape data between long and wide formats
#'
#' A convenience wrapper around \code{tidyr::pivot_longer} and
#' \code{tidyr::pivot_wider} for converting data between long and wide layouts.
#'
#' @importFrom tidyr pivot_longer pivot_wider
#' @importFrom dplyr all_of
#'
#' @param data A data frame
#' @param direction Direction to reshape: \code{"long"} or \code{"wide"}.
#' @param cols For \code{"long"}: character vector of column names to pivot into
#'   longer format.
#' @param names_to For \code{"long"}: name of the new column that will hold the
#'   original column names. Defaults to \code{"name"}.
#' @param values_to For \code{"long"}: name of the new column that will hold the
#'   values. Defaults to \code{"value"}.
#' @param names_from For \code{"wide"}: column whose unique values will become
#'   new column names.
#' @param values_from For \code{"wide"}: column whose values will fill the new
#'   columns.
#' @return A reshaped data frame
#' @export
#'
#' @examples
#' # Wide to long
#' wide_df <- data.frame(id = 1:3, height = c(5.5, 6.0, 5.8), weight = c(150, 180, 165))
#' reshape_data(wide_df, direction = "long", cols = c("height", "weight"))
#'
#' # Long to wide
#' long_df <- data.frame(
#'   id = c(1, 1, 2, 2),
#'   measurement = c("height", "weight", "height", "weight"),
#'   value = c(5.5, 150, 6.0, 180)
#' )
#' reshape_data(long_df, direction = "wide", names_from = "measurement", values_from = "value")
reshape_data <- function(data,
                         direction,
                         cols = NULL,
                         names_to = "name",
                         values_to = "value",
                         names_from = NULL,
                         values_from = NULL) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }

  if (!direction %in% c("long", "wide")) {
    stop('`direction` must be either "long" or "wide".', call. = FALSE)
  }

  if (direction == "long") {
    if (is.null(cols) || length(cols) == 0) {
      stop('`cols` must be provided when direction = "long".', call. = FALSE)
    }

    missing_cols <- setdiff(cols, names(data))
    if (length(missing_cols) > 0) {
      stop("Column(s) not found in data: ", paste(missing_cols, collapse = ", "), call. = FALSE)
    }

    result <- pivot_longer(data, cols = all_of(cols),
                           names_to = names_to, values_to = values_to)

  } else {
    if (is.null(names_from) || is.null(values_from)) {
      stop('`names_from` and `values_from` must be provided when direction = "wide".',
           call. = FALSE)
    }

    all_needed <- c(names_from, values_from)
    missing_cols <- setdiff(all_needed, names(data))
    if (length(missing_cols) > 0) {
      stop("Column(s) not found in data: ", paste(missing_cols, collapse = ", "), call. = FALSE)
    }

    result <- pivot_wider(data, names_from = all_of(names_from),
                          values_from = all_of(values_from))
  }

  as.data.frame(result)
}
