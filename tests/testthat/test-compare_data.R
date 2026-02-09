test_that("compare_data detects row changes", {
  old <- data.frame(x = 1:5, y = letters[1:5], stringsAsFactors = FALSE)
  new <- old[1:3, ]
  report <- compare_data(old, new, print_report = FALSE)
  expect_equal(report$dimensions$rows_before, 5)
  expect_equal(report$dimensions$rows_after, 3)
  expect_equal(report$dimensions$rows_diff, -2)
})

test_that("compare_data detects column additions", {
  old <- data.frame(x = 1:3)
  new <- data.frame(x = 1:3, x_log = log(1:3))
  report <- compare_data(old, new, print_report = FALSE)
  expect_equal(report$dimensions$cols_added, "x_log")
})

test_that("compare_data detects NA changes", {
  old <- data.frame(x = c(1, NA, 3))
  new <- data.frame(x = c(1, 2, 3))
  report <- compare_data(old, new, print_report = FALSE)
  expect_equal(report$missing_values$total_before, 1)
  expect_equal(report$missing_values$total_after, 0)
  expect_false(is.null(report$missing_values$per_column))
})

test_that("compare_data detects type changes", {
  old <- data.frame(d = c("2023-01-01", "2023-02-01"), stringsAsFactors = FALSE)
  new <- data.frame(d = as.Date(c("2023-01-01", "2023-02-01")))
  report <- compare_data(old, new, print_report = FALSE)
  expect_false(is.null(report$type_changes))
  expect_equal(report$type_changes$type_before, "character")
  expect_equal(report$type_changes$type_after, "Date")
})

test_that("compare_data detects value changes", {
  old <- data.frame(x = c("Cat ", "DOG"), stringsAsFactors = FALSE)
  new <- data.frame(x = c("cat", "dog"), stringsAsFactors = FALSE)
  report <- compare_data(old, new, print_report = FALSE)
  expect_false(is.null(report$value_changes))
  expect_equal(report$value_changes$cells_changed, 2L)
})

test_that("compare_data detects duplicate changes", {
  old <- data.frame(x = c(1, 1, 2, 2))
  new <- data.frame(x = c(1, 2))
  report <- compare_data(old, new, print_report = FALSE)
  expect_equal(report$duplicate_changes$duplicates_before, 2)
  expect_equal(report$duplicate_changes$duplicates_after, 0)
})

test_that("compare_data reports no changes for identical data", {
  df <- data.frame(x = 1:3, y = letters[1:3], stringsAsFactors = FALSE)
  report <- compare_data(df, df, print_report = FALSE)
  expect_equal(report$dimensions$rows_diff, 0)
  expect_null(report$missing_values$per_column)
  expect_null(report$type_changes)
  expect_null(report$value_changes)
})

test_that("compare_data validates inputs", {
  expect_error(compare_data("bad", data.frame(x = 1)), "`old_data` must be a data frame")
  expect_error(compare_data(data.frame(x = 1), "bad"), "`new_data` must be a data frame")
})

test_that("compare_data print method works", {
  old <- data.frame(x = c(1, NA, 3))
  new <- data.frame(x = c(1, 2, 3))
  expect_output(compare_data(old, new), "cleanR Cleaning Report")
})

test_that("compare_data returns cleanR_report class", {
  df <- data.frame(x = 1:3)
  report <- compare_data(df, df, print_report = FALSE)
  expect_s3_class(report, "cleanR_report")
})
