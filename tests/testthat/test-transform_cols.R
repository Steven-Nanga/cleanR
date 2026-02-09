test_that("transform_cols applies log transformation", {
  df <- data.frame(x = c(1, 10, 100))
  result <- transform_cols(df, "x", method = "log")
  expect_equal(result$x, log(c(1, 10, 100)))
})

test_that("transform_cols applies log with custom base", {
  df <- data.frame(x = c(1, 10, 100))
  result <- transform_cols(df, "x", method = "log", base = 10)
  expect_equal(result$x, log10(c(1, 10, 100)))
})

test_that("transform_cols applies log1p (safe for zeros)", {
  df <- data.frame(x = c(0, 1, 2))
  result <- transform_cols(df, "x", method = "log1p")
  expect_equal(result$x, log1p(c(0, 1, 2)))
})

test_that("transform_cols applies sqrt", {
  df <- data.frame(x = c(0, 4, 9))
  result <- transform_cols(df, "x", method = "sqrt")
  expect_equal(result$x, c(0, 2, 3))
})

test_that("transform_cols applies square", {
  df <- data.frame(x = c(2, 3, 4))
  result <- transform_cols(df, "x", method = "square")
  expect_equal(result$x, c(4, 9, 16))
})

test_that("transform_cols normalizes to 0-1", {
  df <- data.frame(x = c(10, 20, 30))
  result <- transform_cols(df, "x", method = "normalize")
  expect_equal(result$x, c(0, 0.5, 1))
})

test_that("transform_cols standardizes to z-scores", {
  df <- data.frame(x = c(10, 20, 30))
  result <- transform_cols(df, "x", method = "standardize")
  expect_equal(mean(result$x), 0, tolerance = 1e-10)
  expect_equal(sd(result$x), 1, tolerance = 1e-10)
})

test_that("transform_cols computes inverse", {
  df <- data.frame(x = c(2, 4, 5))
  result <- transform_cols(df, "x", method = "inverse")
  expect_equal(result$x, c(0.5, 0.25, 0.2))
})

test_that("transform_cols creates new columns with new_col = TRUE", {
  df <- data.frame(x = c(1, 4, 9))
  result <- transform_cols(df, "x", method = "sqrt", new_col = TRUE)
  expect_true("x_sqrt" %in% names(result))
  expect_equal(result$x, c(1, 4, 9))
  expect_equal(result$x_sqrt, c(1, 2, 3))
})

test_that("transform_cols validates inputs", {
  expect_error(transform_cols("not a df", "x"), "`data` must be a data frame")
  df <- data.frame(x = 1:3)
  expect_error(transform_cols(df, "x", method = "bad"), "`method` must be one of")
  expect_error(transform_cols(df, "missing"), "Column\\(s\\) not found")
  df2 <- data.frame(x = c("a", "b"))
  expect_error(transform_cols(df2, "x"), "must be numeric")
  df3 <- data.frame(x = c(-1, 0, 1))
  expect_error(transform_cols(df3, "x", method = "log"), "non-positive values")
  df4 <- data.frame(x = c(-1, 2, 3))
  expect_error(transform_cols(df4, "x", method = "sqrt"), "negative values")
  df5 <- data.frame(x = c(0, 1, 2))
  expect_error(transform_cols(df5, "x", method = "inverse"), "contains zeros")
})
