test_that("standardize_categories lowercases and trims", {
  df <- data.frame(
    cat = c("Cat ", " DOG", "FISH"),
    stringsAsFactors = FALSE
  )
  result <- standardize_categories(df, "cat")
  expect_equal(result$cat, c("cat", "dog", "fish"))
})

test_that("standardize_categories replaces non-alphanumeric chars", {
  df <- data.frame(
    cat = c("New York", "San-Francisco", "Las  Vegas"),
    stringsAsFactors = FALSE
  )
  result <- standardize_categories(df, "cat")
  expect_equal(result$cat, c("new_york", "san_francisco", "las__vegas"))
})

test_that("standardize_categories validates inputs", {
  expect_error(standardize_categories("not a df", "x"), "`data` must be a data frame")
  df <- data.frame(x = 1:3)
  expect_error(standardize_categories(df, "missing"), "Column\\(s\\) not found")
  expect_error(standardize_categories(df, character(0)), "`cols` must be a non-empty character vector")
})
