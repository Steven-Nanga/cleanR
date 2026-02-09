#' Compare two data frames and generate a summary of differences
#'
#' Produces a detailed report describing how \code{new_data} differs from
#' \code{old_data}, including changes to dimensions, missing values, column
#' types, duplicate counts, and value-level differences.
#'
#' @param old_data The original data frame (before cleaning)
#' @param new_data The modified data frame (after cleaning)
#' @param print_report Logical; if \code{TRUE} (default), print the report to
#'   the console. The report object is always returned invisibly.
#' @return A list of class \code{"cleanR_report"} containing:
#'   \describe{
#'     \item{dimensions}{Row and column counts before and after.}
#'     \item{missing_values}{NA counts per column before and after.}
#'     \item{type_changes}{Columns whose class changed.}
#'     \item{duplicate_changes}{Duplicate row counts before and after.}
#'     \item{value_changes}{Columns where values were modified (count of changed cells).}
#'   }
#' @export
compare_data <- function(old_data, new_data, print_report = TRUE) {
  if (!is.data.frame(old_data)) {
    stop("`old_data` must be a data frame.", call. = FALSE)
  }
  if (!is.data.frame(new_data)) {
    stop("`new_data` must be a data frame.", call. = FALSE)
  }

  report <- list()

  # --- Dimensions ---
  report$dimensions <- list(
    rows_before    = nrow(old_data),
    rows_after     = nrow(new_data),
    rows_diff      = nrow(new_data) - nrow(old_data),
    cols_before    = ncol(old_data),
    cols_after     = ncol(new_data),
    cols_added     = setdiff(names(new_data), names(old_data)),
    cols_removed   = setdiff(names(old_data), names(new_data))
  )

  # --- Missing values ---
  na_before <- vapply(old_data, function(x) sum(is.na(x)), integer(1))
  na_after_all <- vapply(new_data, function(x) sum(is.na(x)), integer(1))
  # Only report columns present in both, plus any new columns
  common_cols <- intersect(names(old_data), names(new_data))
  na_diff <- na_after_all[common_cols] - na_before[common_cols]
  changed_na <- na_diff[na_diff != 0]

  report$missing_values <- list(
    total_before = sum(na_before),
    total_after  = sum(na_after_all),
    per_column   = if (length(changed_na) > 0) {
      data.frame(
        column    = names(changed_na),
        na_before = na_before[names(changed_na)],
        na_after  = na_after_all[names(changed_na)],
        diff      = as.integer(changed_na),
        row.names = NULL,
        stringsAsFactors = FALSE
      )
    } else {
      NULL
    }
  )

  # --- Type changes ---
  types_before <- vapply(old_data[common_cols], function(x) class(x)[1], character(1))
  types_after  <- vapply(new_data[common_cols], function(x) class(x)[1], character(1))
  type_changed <- common_cols[types_before != types_after]

  report$type_changes <- if (length(type_changed) > 0) {
    data.frame(
      column      = type_changed,
      type_before = types_before[type_changed],
      type_after  = types_after[type_changed],
      row.names   = NULL,
      stringsAsFactors = FALSE
    )
  } else {
    NULL
  }

  # --- Duplicates ---
  dup_before <- sum(duplicated(old_data))
  dup_after  <- sum(duplicated(new_data))
  report$duplicate_changes <- list(
    duplicates_before = dup_before,
    duplicates_after  = dup_after,
    duplicates_removed = dup_before - dup_after
  )

  # --- Value changes (only when row counts match) ---
  if (nrow(old_data) == nrow(new_data) && length(common_cols) > 0) {
    changed_counts <- integer(0)
    for (col in common_cols) {
      old_vals <- as.character(old_data[[col]])
      new_vals <- as.character(new_data[[col]])
      n_changed <- sum(old_vals != new_vals, na.rm = TRUE)
      if (n_changed > 0) {
        changed_counts[col] <- n_changed
      }
    }
    report$value_changes <- if (length(changed_counts) > 0) {
      data.frame(
        column        = names(changed_counts),
        cells_changed = as.integer(changed_counts),
        row.names     = NULL,
        stringsAsFactors = FALSE
      )
    } else {
      NULL
    }
  } else {
    report$value_changes <- NULL
  }

  class(report) <- "cleanR_report"

  if (print_report) {
    print(report)
  }

  invisible(report)
}


#' Print method for cleanR_report
#'
#' @param x A \code{cleanR_report} object
#' @param ... Additional arguments (ignored)
#' @export
print.cleanR_report <- function(x, ...) {
  rule <- function(title) {
    cat("\n", strrep("-", 50), "\n", sep = "")
    cat(" ", title, "\n", sep = "")
    cat(strrep("-", 50), "\n", sep = "")
  }

  cat("\n")
  cat(strrep("=", 50), "\n")
  cat("           cleanR Cleaning Report\n")
  cat(strrep("=", 50), "\n")

  # Dimensions
  rule("Dimensions")
  d <- x$dimensions
  cat("  Rows:    ", d$rows_before, " -> ", d$rows_after, sep = "")
  if (d$rows_diff != 0) {
    cat("  (", ifelse(d$rows_diff > 0, "+", ""), d$rows_diff, ")", sep = "")
  }
  cat("\n")
  cat("  Columns: ", d$cols_before, " -> ", d$cols_after, sep = "")
  if (length(d$cols_added) > 0) {
    cat("  (+", paste(d$cols_added, collapse = ", "), ")", sep = "")
  }
  if (length(d$cols_removed) > 0) {
    cat("  (-", paste(d$cols_removed, collapse = ", "), ")", sep = "")
  }
  cat("\n")

  # Missing values
  rule("Missing Values")
  m <- x$missing_values
  cat("  Total NAs: ", m$total_before, " -> ", m$total_after, sep = "")
  diff_na <- m$total_after - m$total_before
  if (diff_na != 0) {
    cat("  (", ifelse(diff_na > 0, "+", ""), diff_na, ")", sep = "")
  }
  cat("\n")
  if (!is.null(m$per_column)) {
    for (i in seq_len(nrow(m$per_column))) {
      row <- m$per_column[i, ]
      cat("    ", row$column, ": ", row$na_before, " -> ", row$na_after, "\n", sep = "")
    }
  } else {
    cat("  No changes in missing values per column.\n")
  }

  # Type changes
  rule("Type Changes")
  if (!is.null(x$type_changes)) {
    for (i in seq_len(nrow(x$type_changes))) {
      row <- x$type_changes[i, ]
      cat("  ", row$column, ": ", row$type_before, " -> ", row$type_after, "\n", sep = "")
    }
  } else {
    cat("  No type changes.\n")
  }

  # Duplicates
  rule("Duplicates")
  dup <- x$duplicate_changes
  cat("  Duplicate rows: ", dup$duplicates_before, " -> ", dup$duplicates_after, sep = "")
  if (dup$duplicates_removed != 0) {
    cat("  (", dup$duplicates_removed, " removed)", sep = "")
  }
  cat("\n")

  # Value changes
  rule("Value Changes")
  if (!is.null(x$value_changes)) {
    for (i in seq_len(nrow(x$value_changes))) {
      row <- x$value_changes[i, ]
      cat("  ", row$column, ": ", row$cells_changed, " cell(s) modified\n", sep = "")
    }
  } else if (!is.null(x$dimensions) && x$dimensions$rows_diff != 0) {
    cat("  Row counts differ; cell-level comparison skipped.\n")
  } else {
    cat("  No values changed.\n")
  }

  cat("\n", strrep("=", 50), "\n", sep = "")
  invisible(x)
}
