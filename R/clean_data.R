#' Clean data by applying multiple cleaning functions
#'
#' A wrapper that applies cleaning steps in order: handle missing values,
#' remove duplicates, standardize categories, convert types, remove outliers,
#' and apply column transformations.
#'
#' When \code{report = TRUE}, a step-by-step report is printed showing what
#' changed at each stage, and the function returns a list with both the cleaned
#' data and the report.
#'
#' @param data A data frame
#' @param missing_cols Columns to handle missing values in (NULL to skip)
#' @param missing_method Method for missing value handling (see \code{\link{handle_missing}})
#' @param missing_fill Fill value when \code{missing_method = "constant"}
#' @param duplicate_cols Columns to consider when removing duplicates
#' @param categorical_cols Categorical columns to standardize
#' @param type_list A named list specifying column types to convert
#' @param date_format Optional date format string passed to \code{\link{convert_types}}
#' @param outlier_cols Numeric columns to check for outliers
#' @param outlier_method Method for outlier detection ("iqr" or "zscore")
#' @param outlier_threshold Threshold for outlier detection
#' @param transform_cols_list Character vector of numeric columns to transform (NULL to skip)
#' @param transform_method Transformation method (see \code{\link{transform_cols}})
#' @param transform_new_col Logical; if TRUE, keep originals and add transformed columns
#' @param report Logical; if TRUE, print a step-by-step cleaning report and return
#'   a list with \code{$data} (the cleaned data frame) and \code{$report} (the report).
#'   If FALSE (default), return only the cleaned data frame.
#' @return If \code{report = FALSE}, a cleaned data frame. If \code{report = TRUE},
#'   a list with elements \code{data} and \code{report}.
#' @export
clean_data <- function(data,
                       missing_cols = NULL,
                       missing_method = "remove",
                       missing_fill = NULL,
                       duplicate_cols = NULL,
                       categorical_cols = NULL,
                       type_list = NULL,
                       date_format = NULL,
                       outlier_cols = NULL,
                       outlier_method = "iqr",
                       outlier_threshold = 1.5,
                       transform_cols_list = NULL,
                       transform_method = "log",
                       transform_new_col = FALSE,
                       report = FALSE) {

  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }

  original_data <- data
  steps <- list()

  # Helper: snapshot changes after a step
  record_step <- function(step_name, before, after) {
    list(
      step         = step_name,
      rows_before  = nrow(before),
      rows_after   = nrow(after),
      rows_diff    = nrow(after) - nrow(before),
      cols_before  = ncol(before),
      cols_after   = ncol(after),
      cols_added   = setdiff(names(after), names(before)),
      cols_removed = setdiff(names(before), names(after)),
      na_before    = sum(is.na(before)),
      na_after     = sum(is.na(after))
    )
  }

  if (!is.null(missing_cols)) {
    before <- data
    data <- handle_missing(data, missing_cols, method = missing_method,
                           fill_value = missing_fill)
    if (report) steps <- c(steps, list(record_step("Handle Missing Values", before, data)))
  }

  if (!is.null(duplicate_cols)) {
    before <- data
    data <- remove_duplicates(data, duplicate_cols)
    if (report) steps <- c(steps, list(record_step("Remove Duplicates", before, data)))
  }

  if (!is.null(categorical_cols)) {
    before <- data
    data <- standardize_categories(data, categorical_cols)
    if (report) steps <- c(steps, list(record_step("Standardize Categories", before, data)))
  }

  if (!is.null(type_list)) {
    before <- data
    data <- convert_types(data, type_list, date_format = date_format)
    if (report) steps <- c(steps, list(record_step("Convert Types", before, data)))
  }

  if (!is.null(outlier_cols)) {
    before <- data
    data <- remove_outliers(data, outlier_cols, outlier_method, outlier_threshold)
    if (report) steps <- c(steps, list(record_step("Remove Outliers", before, data)))
  }

  if (!is.null(transform_cols_list)) {
    before <- data
    data <- transform_cols(data, transform_cols_list, method = transform_method,
                           new_col = transform_new_col)
    if (report) steps <- c(steps, list(record_step("Transform Columns", before, data)))
  }

  if (report) {
    overall <- compare_data(original_data, data, print_report = FALSE)
    overall$steps <- steps

    # Print the step-by-step report
    cat("\n")
    cat(strrep("=", 56), "\n")
    cat("           cleanR Step-by-Step Cleaning Report\n")
    cat(strrep("=", 56), "\n")

    for (i in seq_along(steps)) {
      s <- steps[[i]]
      cat("\n Step ", i, ": ", s$step, "\n", sep = "")
      cat(strrep("-", 56), "\n")

      # Rows
      if (s$rows_diff != 0) {
        cat("   Rows: ", s$rows_before, " -> ", s$rows_after,
            "  (", ifelse(s$rows_diff > 0, "+", ""), s$rows_diff, ")\n", sep = "")
      } else {
        cat("   Rows: ", s$rows_before, " (no change)\n", sep = "")
      }

      # Columns
      if (length(s$cols_added) > 0) {
        cat("   Columns added: ", paste(s$cols_added, collapse = ", "), "\n", sep = "")
      }
      if (length(s$cols_removed) > 0) {
        cat("   Columns removed: ", paste(s$cols_removed, collapse = ", "), "\n", sep = "")
      }

      # NAs
      na_diff <- s$na_after - s$na_before
      if (na_diff != 0) {
        cat("   NAs: ", s$na_before, " -> ", s$na_after,
            "  (", ifelse(na_diff > 0, "+", ""), na_diff, ")\n", sep = "")
      }
    }

    # Overall summary
    cat("\n", strrep("=", 56), "\n", sep = "")
    cat(" Overall: ", nrow(original_data), " rows, ", ncol(original_data), " cols -> ",
        nrow(data), " rows, ", ncol(data), " cols\n", sep = "")
    total_na_before <- sum(is.na(original_data))
    total_na_after <- sum(is.na(data))
    cat(" NAs: ", total_na_before, " -> ", total_na_after, "\n", sep = "")
    cat(strrep("=", 56), "\n\n")

    return(invisible(list(data = data, report = overall)))
  }

  data
}
