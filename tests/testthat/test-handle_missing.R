test_that("handle_missing removes rows with NA by default", {
  df <- data.frame(x = c(1, NA, 3), y = c("a", "b", NA), stringsAsFactors = FALSE)
  result <- handle_missing(df)
  expect_equal(nrow(result), 1)
  expect_equal(result$x, 1)
})

test_that("handle_missing removes rows only for specified cols", {
  df <- data.frame(x = c(1, NA, 3), y = c("a", "b", NA), stringsAsFactors = FALSE)
  result <- handle_missing(df, cols = "x", method = "remove")
  expect_equal(nrow(result), 2)
})

test_that("handle_missing imputes with mean", {
  df <- data.frame(x = c(1, NA, 3, 4))
  result <- handle_missing(df, cols = "x", method = "mean")
  expect_equal(result$x[2], mean(c(1, 3, 4)))
  expect_false(any(is.na(result$x)))
})

test_that("handle_missing imputes with median", {
  df <- data.frame(x = c(1, NA, 3, 4, 100))
  result <- handle_missing(df, cols = "x", method = "median")
  expect_equal(result$x[2], median(c(1, 3, 4, 100)))
})

test_that("handle_missing imputes with mode", {
  df <- data.frame(x = c("a", "b", "b", NA), stringsAsFactors = FALSE)
  result <- handle_missing(df, cols = "x", method = "mode")
  expect_equal(result$x[4], "b")
})

test_that("handle_missing imputes with constant", {
  df <- data.frame(x = c(1, NA, 3))
  result <- handle_missing(df, cols = "x", method = "constant", fill_value = 999)
  expect_equal(result$x[2], 999)
})

test_that("handle_missing validates inputs", {
  expect_error(handle_missing("not a df"), "`data` must be a data frame")
  df <- data.frame(x = 1:3)
  expect_error(handle_missing(df, method = "bad"), "`method` must be one of")
  expect_error(handle_missing(df, cols = "missing"), "Column\\(s\\) not found")
  expect_error(handle_missing(df, method = "constant"), "`fill_value` must be provided")
  df2 <- data.frame(x = c("a", NA), stringsAsFactors = FALSE)
  expect_error(handle_missing(df2, cols = "x", method = "mean"), "must be numeric")
})
