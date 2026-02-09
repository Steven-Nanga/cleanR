# cleanR: Streamlined Data Cleaning in R

## Overview

cleanR is an R package designed to simplify and streamline the data cleaning process. It provides a unified interface for common data preparation tasks including:

- Handling missing values (removal or imputation)
- Removing duplicate rows
- Standardizing categorical variables
- Converting column data types
- Detecting and removing outliers
- Reshaping data between long and wide formats
- Applying mathematical column transformations
- Generating cleaning reports to see exactly what changed

## Installation

You can install the development version of cleanR from GitHub with:

```{r}
# install.packages("devtools")
devtools::install_github("Steven-Nanga/cleanR")
```

## Features

| Function | Description |
|---|---|
| `handle_missing()` | Handle missing values (remove, impute with mean/median/mode, or fill with constant) |
| `remove_duplicates()` | Remove duplicate rows from a data frame |
| `standardize_categories()` | Trim whitespace, lowercase, and normalize categorical variables |
| `convert_types()` | Convert column types (numeric, integer, character, factor, date, logical) |
| `remove_outliers()` | Remove outliers using IQR or z-score methods |
| `reshape_data()` | Convert between long and wide data formats |
| `transform_cols()` | Apply transformations: log, sqrt, square, normalize, standardize, and more |
| `clean_data()` | A wrapper that applies multiple cleaning steps in one call (with optional report) |
| `compare_data()` | Compare two data frames and generate a detailed report of differences |

## Quick Start

```{r}
library(cleanR)

# Sample data with common issues
data <- data.frame(
  id = c(1, 2, 2, 3, 4, 5),
  category = c("Cat ", "DOG", "dog", "FISH", "Bird", "CAT"),
  value = c(10, NA, 20, 100, 40, 50),
  date = c("2023-01-01", "2023-02-01", "2023-02-01", "2023-03-01", "2023-04-01", "2023-05-01"),
  stringsAsFactors = FALSE
)

# Clean everything in one call
cleaned_data <- clean_data(
  data,
  missing_cols = "value",
  missing_method = "mean",
  duplicate_cols = c("id", "category"),
  categorical_cols = "category",
  type_list = list(value = "numeric", date = "date"),
  outlier_cols = "value"
)

print(cleaned_data)
```

## Detailed Function Usage

### Handle Missing Values

```{r}
handle_missing(data, cols = NULL, method = "remove", fill_value = NULL)
```

- `data`: A data frame
- `cols`: Columns to handle (default is all columns)
- `method`: One of `"remove"`, `"mean"`, `"median"`, `"mode"`, or `"constant"`
- `fill_value`: Value to use when method is `"constant"`

**Examples:**

```{r}
# Remove rows with NA
handle_missing(data, method = "remove")

# Impute with column mean
handle_missing(data, cols = "value", method = "mean")

# Impute with most frequent value
handle_missing(data, cols = "category", method = "mode")

# Fill with a constant
handle_missing(data, cols = "value", method = "constant", fill_value = 0)
```

### Remove Duplicates

```{r}
remove_duplicates(data, cols = NULL)
```

- `data`: A data frame
- `cols`: Columns to consider when identifying duplicates (default is all columns)

### Standardize Categories

```{r}
standardize_categories(data, cols)
```

- `data`: A data frame
- `cols`: Categorical columns to standardize (trims whitespace, lowercases, replaces non-alphanumeric characters with underscores)

### Convert Types

```{r}
convert_types(data, type_list, date_format = NULL)
```

- `data`: A data frame
- `type_list`: A named list specifying column names and their desired types. Supported types: `"numeric"`, `"integer"`, `"character"`, `"factor"`, `"date"`, `"logical"`
- `date_format`: Optional date format string (e.g. `"%Y-%m-%d"`, `"%m/%d/%Y"`)

### Remove Outliers

```{r}
remove_outliers(data, cols, method = "iqr", threshold = 1.5)
```

- `data`: A data frame
- `cols`: Numeric columns to check for outliers
- `method`: `"iqr"` (interquartile range) or `"zscore"`
- `threshold`: Threshold for outlier detection (default 1.5 for IQR)

Rows with `NA` values in the checked columns are preserved.

### Reshape Data

```{r}
reshape_data(data, direction, cols = NULL, names_to = "name", values_to = "value",
             names_from = NULL, values_from = NULL)
```

- `data`: A data frame
- `direction`: `"long"` or `"wide"`
- `cols`: (long) Columns to pivot into longer format
- `names_to` / `values_to`: (long) Names for the new key/value columns
- `names_from` / `values_from`: (wide) Columns to spread into wider format

**Examples:**

```{r}
# Wide to long
wide_df <- data.frame(id = 1:3, height = c(5.5, 6.0, 5.8), weight = c(150, 180, 165))
reshape_data(wide_df, direction = "long", cols = c("height", "weight"))

# Long to wide
long_df <- data.frame(
  id = c(1, 1, 2, 2),
  measurement = c("height", "weight", "height", "weight"),
  value = c(5.5, 150, 6.0, 180)
)
reshape_data(long_df, direction = "wide", names_from = "measurement", values_from = "value")
```

### Transform Columns

```{r}
transform_cols(data, cols, method = "log", base = exp(1), new_col = FALSE)
```

- `data`: A data frame
- `cols`: Numeric columns to transform
- `method`: One of `"log"`, `"log1p"`, `"sqrt"`, `"square"`, `"normalize"`, `"standardize"`, or `"inverse"`
- `base`: Base for logarithm (default is natural log)
- `new_col`: If `TRUE`, keep originals and add new columns with a suffix (e.g. `value_log`)

**Examples:**

```{r}
df <- data.frame(x = c(1, 10, 100, 1000))

# Natural log
transform_cols(df, "x", method = "log")

# Log base 10
transform_cols(df, "x", method = "log", base = 10)

# Min-max normalization (0 to 1)
transform_cols(df, "x", method = "normalize")

# Z-score standardization (mean 0, sd 1)
transform_cols(df, "x", method = "standardize")

# Keep original and add transformed column
transform_cols(df, "x", method = "sqrt", new_col = TRUE)
```

### Clean Data (Wrapper Function)

```{r}
clean_data(data,
           missing_cols = NULL, missing_method = "remove", missing_fill = NULL,
           duplicate_cols = NULL,
           categorical_cols = NULL,
           type_list = NULL, date_format = NULL,
           outlier_cols = NULL, outlier_method = "iqr", outlier_threshold = 1.5,
           transform_cols_list = NULL, transform_method = "log", transform_new_col = FALSE,
           report = FALSE)
```

Applies all cleaning steps in one call. Steps are executed in order:

1. Handle missing values
2. Remove duplicates
3. Standardize categories
4. Convert types
5. Remove outliers
6. Transform columns

Each step is **skipped** when its corresponding parameter is `NULL`.

Set `report = TRUE` to get a step-by-step report of every change:

```{r}
result <- clean_data(
  data,
  missing_cols = "value",
  missing_method = "mean",
  duplicate_cols = c("id", "category"),
  categorical_cols = "category",
  type_list = list(date = "date"),
  outlier_cols = "value",
  report = TRUE
)

# The cleaned data
result$data

# The full report object
result$report
```

### Compare Data (Standalone Report)

```{r}
compare_data(old_data, new_data, print_report = TRUE)
```

- `old_data`: The original data frame (before cleaning)
- `new_data`: The modified data frame (after cleaning)
- `print_report`: If `TRUE` (default), prints the report to the console

Use this to compare any two data frames, regardless of how the cleaning was done:

```{r}
original <- data
cleaned <- handle_missing(original, cols = "value", method = "median")
compare_data(original, cleaned)
```

The report covers:
- **Dimensions**: rows and columns before vs. after
- **Missing values**: total and per-column NA changes
- **Type changes**: columns whose type was converted
- **Duplicates**: duplicate row counts before vs. after
- **Value changes**: number of cells modified per column

## Contributing

Contributions to cleanR are welcome! Here are some ways you can contribute:

- Report bugs and request features by opening an [issue](https://github.com/Steven-Nanga/cleanR/issues)
- Submit pull requests to fix bugs or add new features
- Improve documentation or add examples
- Share your experience using cleanR

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Authors

- Steven Nanga

## Acknowledgments

Inspired by common data cleaning challenges in R.
