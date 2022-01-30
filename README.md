# product-review-generator

This product review generator was created for the NLP assignemnt as part of the Intelligent Systems course at UPM in 2022.

## Running the Application
This implentation relies on a wrapper for the Python library markovify called [markovifyR](https://github.com/abresler/markovifyR/blob/master/R/markovify.R). 
In order to run the application, a special package, which is not part of the standard CRAN list needs to be installed.
Additionally, because the used dataset is too big in size to upload straight to GitHub, one must download the publicly available data set at its source. Out of simplicity GitHubs LFS was not chosen as an alternative.

In detail, the steps that need to be taken are:

1. Download the dataset from https://www.kaggle.com/datafiniti/consumer-reviews-of-amazon-products?select=Datafiniti_Amazon_Consumer_Reviews_of_Amazon_Products.csv and store it in the project folder under the _/data_ folder.
2. Run *install.packages("remotes")* in the R console.
3. Run *remotes::install_github("abresler/markovifyR")* in the R console.
4. Ensure all other required standard packages, which are listed at the beginning of the main.R file are installed.
5. Set the working directory with *setwd("your_path_to_project")*.
6. Run the code

