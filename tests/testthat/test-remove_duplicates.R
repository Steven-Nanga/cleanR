test_that("remove_duplicates removes duplicate rows", {
  df <- data.frame(
    id = c(1, 2, 2, 3),
    name = c("a", "b", "b", "c"),
    stringsAsFactors = FALSE
  )
  result <- remove_duplicates(df)
  expect_equal(nrow(result), 3)
})

test_that("remove_duplicates respects specified columns", {
  df <- data.frame(
    id = c(1, 2, 2, 3),
    name = c("a", "b", "x", "c"),
    stringsAsFactors = FALSE
  )
  result <- remove_duplicates(df, cols = "id")
  expect_equal(nrow(result), 3)
  # first occurrence is kept
  expect_equal(result$name[result$id == 2], "b")
})

test_that("remove_duplicates validates inputs", {
  expect_error(remove_duplicates("not a df"), "`data` must be a data frame")
  df <- data.frame(x = 1:3)
  expect_error(remove_duplicates(df, cols = "nonexistent"), "Column\\(s\\) not found")
})
