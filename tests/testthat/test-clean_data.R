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
