# product-review-generator

This product review generator was created for the NLP assignemnt as part of the Intelligent Systems course at UPM in 2022.

## Running the Application
This implentation relies on a wrapper for the Python library markovify called markovifyR. 
In order to run the application, a special package, which is not part of the standard CRAN list needs to be installed.

In detail, the steps that need to be taken are:

1. Run *install.packages("remotes")* in the R console.
2. Run *remotes::install_github("abresler/markovifyR")* in the R console.
3. Set the working directory with *setwd("your_path_to_project")*.
4. Run the code

