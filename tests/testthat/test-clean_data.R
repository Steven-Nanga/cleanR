test_that("clean_data applies all steps", {
  df <- data.frame(
    id = c(1, 2, 2, 3, 4, 5),
    category = c("Cat ", "DOG", "dog", "FISH", "Bird", "CAT"),
    value = c(10, 20, 20, 100, 40, 50),
    stringsAsFactors = FALSE
  )
  result <- clean_data(
    df,
    duplicate_cols = c("id", "category"),
    categorical_cols = "category",
    outlier_cols = "value"
  )
  # duplicates removed
  expect_true(nrow(result) < nrow(df))
  # categories standardized
  expect_true(all(result$category == tolower(trimws(result$category))))
})

test_that("clean_data works with no optional args", {
  df <- data.frame(x = 1:5, y = letters[1:5], stringsAsFactors = FALSE)
  result <- clean_data(df)
  expect_equal(result, df)
})

test_that("clean_data validates data input", {
  expect_error(clean_data("not a df"), "`data` must be a data frame")
})

test_that("clean_data handles missing values via wrapper", {
  df <- data.frame(x = c(1, NA, 3), y = c(4, 5, 6))
  result <- clean_data(df, missing_cols = "x", missing_method = "mean")
  expect_false(any(is.na(result$x)))
  expect_equal(result$x[2], 2)
})

test_that("clean_data applies transformations via wrapper", {
  df <- data.frame(x = c(1, 4, 9))
  result <- clean_data(df, transform_cols_list = "x", transform_method = "sqrt",
                       transform_new_col = TRUE)
  expect_true("x_sqrt" %in% names(result))
  expect_equal(result$x_sqrt, c(1, 2, 3))
})

test_that("clean_data with report=TRUE returns list with data and report", {
  df <- data.frame(
    x = c(1, NA, 3, 4, 5),
    y = c("Cat ", "DOG", "dog", "FISH", "Bird"),
    stringsAsFactors = FALSE
  )
  result <- clean_data(df,
                       missing_cols = "x", missing_method = "mean",
                       categorical_cols = "y",
                       report = TRUE)
  expect_type(result, "list")
  expect_true("data" %in% names(result))
  expect_true("report" %in% names(result))
  expect_s3_class(result$report, "cleanR_report")
  expect_s3_class(result$data, "data.frame")
})

test_that("clean_data report tracks step-by-step changes", {
  df <- data.frame(x = c(1, NA, 3), y = c(4, 5, 6))
  result <- clean_data(df,
                       missing_cols = "x", missing_method = "remove",
                       report = TRUE)
  expect_equal(length(result$report$steps), 1)
  step <- result$report$steps[[1]]
  expect_equal(step$step, "Handle Missing Values")
  expect_equal(step$rows_before, 3)
  expect_equal(step$rows_after, 2)
})

test_that("clean_data report=FALSE returns plain data frame", {
  df <- data.frame(x = 1:3)
  result <- clean_data(df, report = FALSE)
  expect_s3_class(result, "data.frame")
})
