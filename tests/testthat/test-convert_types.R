test_that("convert_types converts to numeric", {
  df <- data.frame(x = c("1", "2", "3"), stringsAsFactors = FALSE)
  result <- convert_types(df, list(x = "numeric"))
  expect_type(result$x, "double")
  expect_equal(result$x, c(1, 2, 3))
})

test_that("convert_types converts to date", {
  df <- data.frame(d = c("2023-01-01", "2023-06-15"), stringsAsFactors = FALSE)
  result <- convert_types(df, list(d = "date"))
  expect_s3_class(result$d, "Date")
})

test_that("convert_types respects date_format", {
  df <- data.frame(d = c("01/01/2023", "06/15/2023"), stringsAsFactors = FALSE)
  result <- convert_types(df, list(d = "date"), date_format = "%m/%d/%Y")
  expect_s3_class(result$d, "Date")
  expect_equal(result$d, as.Date(c("2023-01-01", "2023-06-15")))
})

test_that("convert_types validates inputs", {
  expect_error(convert_types("not a df", list(x = "numeric")), "`data` must be a data frame")
  df <- data.frame(x = 1:3)
  expect_error(convert_types(df, list(y = "numeric")), "Column\\(s\\) not found")
  expect_error(convert_types(df, list(x = "badtype")), "Unsupported type")
  expect_error(convert_types(df, c("numeric")), "`type_list` must be a named list")
})
