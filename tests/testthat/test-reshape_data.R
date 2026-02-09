test_that("reshape_data pivots wide to long", {
  df <- data.frame(id = 1:2, height = c(5.5, 6.0), weight = c(150, 180))
  result <- reshape_data(df, direction = "long", cols = c("height", "weight"))
  expect_equal(nrow(result), 4)
  expect_true("name" %in% names(result))
  expect_true("value" %in% names(result))
})

test_that("reshape_data uses custom names_to and values_to", {
  df <- data.frame(id = 1:2, height = c(5.5, 6.0), weight = c(150, 180))
  result <- reshape_data(df, direction = "long", cols = c("height", "weight"),
                         names_to = "measure", values_to = "reading")
  expect_true("measure" %in% names(result))
  expect_true("reading" %in% names(result))
})

test_that("reshape_data pivots long to wide", {
  df <- data.frame(
    id = c(1, 1, 2, 2),
    measurement = c("height", "weight", "height", "weight"),
    value = c(5.5, 150, 6.0, 180),
    stringsAsFactors = FALSE
  )
  result <- reshape_data(df, direction = "wide",
                         names_from = "measurement", values_from = "value")
  expect_true("height" %in% names(result))
  expect_true("weight" %in% names(result))
  expect_equal(nrow(result), 2)
})

test_that("reshape_data validates inputs", {
  expect_error(reshape_data("not a df", "long"), "`data` must be a data frame")
  df <- data.frame(x = 1:3)
  expect_error(reshape_data(df, direction = "up"), '`direction` must be either')
  expect_error(reshape_data(df, direction = "long"), "`cols` must be provided")
  expect_error(reshape_data(df, direction = "long", cols = "missing"), "Column\\(s\\) not found")
  expect_error(reshape_data(df, direction = "wide"), "`names_from` and `values_from` must be")
  expect_error(reshape_data(df, direction = "wide", names_from = "a", values_from = "b"),
               "Column\\(s\\) not found")
})
