test_that("remove_outliers removes IQR outliers", {
  df <- data.frame(x = c(1, 2, 3, 4, 5, 100))
  result <- remove_outliers(df, "x", method = "iqr")
  expect_false(100 %in% result$x)
  expect_true(all(c(1, 2, 3, 4, 5) %in% result$x))
})

test_that("remove_outliers removes zscore outliers", {
  df <- data.frame(x = c(1, 2, 3, 4, 5, 100))
  result <- remove_outliers(df, "x", method = "zscore", threshold = 2)
  expect_false(100 %in% result$x)
})

test_that("remove_outliers preserves NA rows", {
  df <- data.frame(x = c(1, 2, NA, 3, 4, 5))
  result <- remove_outliers(df, "x", method = "iqr")
  expect_true(any(is.na(result$x)))
  expect_equal(nrow(result), 6)
})

test_that("remove_outliers validates inputs", {
  expect_error(remove_outliers("not a df", "x"), "`data` must be a data frame")
  df <- data.frame(x = 1:5)
  expect_error(remove_outliers(df, "missing"), "Column\\(s\\) not found")
  df2 <- data.frame(x = c("a", "b"))
  expect_error(remove_outliers(df2, "x"), "Column\\(s\\) must be numeric")
  expect_error(remove_outliers(df, "x", method = "bad"), '`method` must be one of')
})
