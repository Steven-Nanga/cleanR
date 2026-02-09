#' Apply mathematical transformations to numeric columns
#'
#' Transforms specified numeric columns using common mathematical operations.
#' Transformed columns can either replace the originals or be added as new
#' columns with a suffix.
#'
#' @param data A data frame
#' @param cols Character vector of numeric column names to transform
#' @param method Transformation to apply. One of:
#'   \describe{
#'     \item{\code{"log"}}{Natural logarithm (or custom base via \code{base}).
#'       Columns must contain only positive values.}
#'     \item{\code{"log1p"}}{Computes \code{log(1 + x)}, safe for zeros.}
#'     \item{\code{"sqrt"}}{Square root. Columns must contain non-negative values.}
#'     \item{\code{"square"}}{Raises values to the power of 2.}
#'     \item{\code{"normalize"}}{Min-max normalization to the 0-1 range.}
#'     \item{\code{"standardize"}}{Z-score standardization (mean 0, sd 1).}
#'     \item{\code{"inverse"}}{Computes \code{1 / x}. Columns must not contain zeros.}
#'   }
#' @param base Base for logarithm when \code{method = "log"}. Defaults to
#'   \code{exp(1)} (natural log).
#' @param new_col Logical. If \code{TRUE}, transformed values are placed in new
#'   columns named \code{<original>_<method>}. If \code{FALSE} (default),
#'   originals are overwritten.
#' @return A data frame with transformed columns
#' @export
transform_cols <- function(data, cols, method = "log", base = exp(1), new_col = FALSE) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }

  valid_methods <- c("log", "log1p", "sqrt", "square", "normalize", "standardize", "inverse")
  if (!method %in% valid_methods) {
    stop('`method` must be one of: ', paste(valid_methods, collapse = ", "), call. = FALSE)
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

  for (col in cols) {
    values <- data[[col]]
    non_na <- values[!is.na(values)]

    # Safety checks for specific methods
    if (method == "log" && any(non_na <= 0)) {
      stop("Column '", col, "' contains non-positive values. ",
           "Use method 'log1p' for data with zeros.", call. = FALSE)
    }
    if (method == "sqrt" && any(non_na < 0)) {
      stop("Column '", col, "' contains negative values.", call. = FALSE)
    }
    if (method == "inverse" && any(non_na == 0)) {
      stop("Column '", col, "' contains zeros; cannot compute inverse.", call. = FALSE)
    }

    transformed <- switch(method,
      "log"         = log(values, base = base),
      "log1p"       = log1p(values),
      "sqrt"        = sqrt(values),
      "square"      = values^2,
      "normalize"   = {
        min_val <- min(non_na)
        max_val <- max(non_na)
        if (min_val == max_val) {
          warning("Column '", col, "' has constant values; normalization returns 0.")
          rep(0, length(values))
        } else {
          (values - min_val) / (max_val - min_val)
        }
      },
      "standardize" = {
        col_mean <- mean(non_na)
        col_sd <- stats::sd(non_na)
        if (col_sd == 0) {
          warning("Column '", col, "' has zero variance; standardization returns 0.")
          rep(0, length(values))
        } else {
          (values - col_mean) / col_sd
        }
      },
      "inverse"     = 1 / values
    )

    target_col <- if (new_col) paste0(col, "_", method) else col
    data[[target_col]] <- transformed
  }

  data
}
