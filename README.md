# cleanR: Streamlined Data Cleaning in R

## Overview

cleanR is an R package designed to simplify and streamline the data cleaning process. It provides a set of functions to handle common data cleaning tasks, including removing duplicates, standardizing categorical variables, converting data types, and removing outliers. This package aims to make data preparation more efficient and consistent across projects.

## Installation

You can install the development version of cleanR from GitHub with:
  
  ```r
# install.packages("devtools")
devtools::install_github("Steven-Nanga/cleanR")
Features
cleanR offers the following main functions:
  
  remove_duplicates(): Remove duplicate rows from a data frame
standardize_categories(): Standardize categorical variables
convert_types(): Convert column types in a data frame
remove_outliers(): Remove outliers from numeric columns
clean_data(): A wrapper function that applies multiple cleaning steps

Usage
Here's a basic example of how to use cleanR:
rCopylibrary(cleanR)

# Sample data
data <- data.frame(
  id = c(1, 2, 2, 3, 4, 5),
  category = c("Cat ", "DOG", "dog", "FISH", "Bird", "CAT"),
  value = c(10, 20, 20, 100, 40, 50),
  date = c("2023-01-01", "2023-02-01", "2023-02-01", "2023-03-01", "2023-04-01", "2023-05-01")
)

# Clean the data
cleaned_data <- clean_data(
  data,
  duplicate_cols = c("id", "category"),
  categorical_cols = "category",
  type_list = list(value = "numeric", date = "date"),
  outlier_cols = "value"
)

print(cleaned_data)
Detailed Function Usage
Remove Duplicates
rCopyremove_duplicates(data, cols = NULL)

data: A data frame
cols: Columns to consider when identifying duplicates (default is all columns)

Standardize Categories
rCopystandardize_categories(data, cols)

data: A data frame
cols: Categorical columns to standardize

Convert Types
rCopyconvert_types(data, type_list)

data: A data frame
type_list: A named list specifying column names and their desired types

Remove Outliers
rCopyremove_outliers(data, cols, method = "iqr", threshold = 1.5)

data: A data frame
cols: Numeric columns to check for outliers
method: Method to use for outlier detection ("iqr" or "zscore")
threshold: Threshold for outlier detection

Clean Data (Wrapper Function)
rCopyclean_data(data, 
           duplicate_cols = NULL, 
           categorical_cols = NULL,
           type_list = NULL,
           outlier_cols = NULL,
           outlier_method = "iqr",
           outlier_threshold = 1.5)
This function applies all the above cleaning steps in one go.
Contributing
Contributions to cleanR are welcome! Here are some ways you can contribute:

Report bugs and request features by opening an issue
Submit pull requests to fix bugs or add new features
Improve documentation or add examples
Share your experience using cleanR

Please read CONTRIBUTING.md for details on our code of conduct and the process for submitting pull requests.
License
This project is licensed under the MIT License - see the LICENSE file for details.
Authors

Steven Nanga - Initial work - Steven-Nanga

Acknowledgments

Inspired by common data cleaning challenges in R
Thanks to all contributors and users of cleanR

FAQ
Q: Can I use cleanR with large datasets?
A: cleanR is designed to work with datasets of various sizes. However, for very large datasets, you may want to consider using data.table or other big data solutions in conjunction with cleanR.
Q: How does cleanR handle missing values?
A: Currently, cleanR does not explicitly handle missing values. This is a planned feature for future releases. In the meantime, you can use base R or tidyr functions to handle missing values before applying cleanR functions.
Q: Can I customize the standardization process for categorical variables?
A: The current version uses a fixed standardization process. Future versions may include options for custom standardization functions.
Versioning
We use SemVer for versioning. For the versions available, see the tags on this repository.
Support
If you encounter any problems or have any questions, please open an issue on GitHub.