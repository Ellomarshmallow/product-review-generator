setwd("/home/ello/Notebooks/Notes/NLP/product-review-generator/")

library(markovifyR)
library(dplyr)
library(utf8)
library(spacyr)
library(quanteda)
library(tokenizers.bpe)

SEED = 1
set.seed(SEED) 

# https://www.kaggle.com/datafiniti/consumer-reviews-of-amazon-products?select=Datafiniti_Amazon_Consumer_Reviews_of_Amazon_Products.csv
reviews <- read.csv("data/Datafiniti_Amazon_Consumer_Reviews_of_Amazon_Products_May19.csv")

# Data Exploration ---- 
names(reviews)
nrow(reviews) 

summary(reviews$primaryCategories)
barplot(table(reviews$primaryCategories), space =1.0)
barplot(table(reviews$reviews.rating), space =1.0)

# check for missing values
colSums(is.na(reviews))
# reviews.didPurchase reviews.doRecommend reviews.id  reviews.numHelpful all miss a lot of values and we do not need them, so drop them.
barplot(table(reviews$reviews.numHelpful))
# --> too many missing or zero values, so not useful for us

# Clean and Prep Data ----
# only keep interesting columns 
reviews <- reviews %>% select(id, name, categories, primaryCategories, reviews.rating, reviews.text, reviews.title)

# add column based on merge primary categories
electronics <- c("Electronics", "Electronics,Media", "Electronics,Furniture", "Supplies,Electronics", "Toys & Games,Electronics")
reviews$mergedCategory <- with(reviews, ifelse(reviews$primaryCategories %in% electronics, "electronics", "non-electronics"))

# add column based on rating
reviews$reviews.rating_positivity <- with(reviews, ifelse(reviews$reviews.rating >3, "positive", "negative"))

reviews_text <- as.character(reviews$reviews.text)

# Check encoding
reviews_text[!utf8_valid(reviews_text)] # is good 0
# #Check character normalization. Specifically, the normalized composed form (NFC)
reviews_text <- utf8_normalize(reviews_text)

# Join lines like so 
paste(reviews_text[1:5], collapse=" ")

# BPE model ----
bpe_model <- bpe(unlist(reviews_text[1:14166]))
subtoks <- bpe_encode(bpe_model, x = reviews_text[14167:28332], type = "subwords")
head(unlist(subtoks), n=5)

# Document Feature Matrix ----
# Top features
dfm_reviews_text <- dfm(tokens(reviews_text))
topfeatures(dfm_reviews_text)
# Top features without punctuation and stop words
dfm_reviews_text_1 <- dfm(tokens(reviews_text, remove_punct = TRUE))
dfm_reviews_text_2 <- dfm_remove(dfm_reviews_text_1, stopwords("en"))
topfeatures(dfm_reviews_text_2)

# Single model Markov Chains----
# Build the model
markov_model <-
  generate_markovify_model(
    input_text = reviews_text,
    markov_state_size = 2L,
    max_overlap_total = 25,
    max_overlap_ratio = .85
  )

# Test model
markovify_text(
  markov_model = markov_model,
  maximum_sentence_length = NULL,
  output_column_name = 'textProductReview',
  count = 5,
  tries = 100,
  only_distinct = TRUE,
  return_message = TRUE
)

# Positive / Negative Model ----
# idea --> split the reviews into good and bad based on rating and train two separate models.
çreviews_positive <- subset(reviews, reviews.rating_positivity == "positive")
reviews_text_positive <- as.character(reviews_positive$reviews.text)

reviews_negative <- subset(reviews, reviews.rating_positivity == "negative")
reviews_text_negative <- as.character(reviews_negative$reviews.text)

# Build the models
markov_model_positive <-
  generate_markovify_model(
    input_text = reviews_text_positive,
    markov_state_size = 2L,
    max_overlap_total = 25,
    max_overlap_ratio = .85
  )

markov_model_negative <-
  generate_markovify_model(
    input_text = reviews_text_negative,
    markov_state_size = 2L,
    max_overlap_total = 25,
    max_overlap_ratio = .85
  )

# Test model
markovify_text(
  markov_model = markov_model_positive,
  maximum_sentence_length = NULL,
  output_column_name = 'textProductReview',
  count = 25,
  tries = 100,
  only_distinct = TRUE,
  return_message = TRUE
)

# Test model
markovify_text(
  markov_model = markov_model_negative,
  maximum_sentence_length = NULL,
  output_column_name = 'textProductReview',
  count = 25,
  tries = 100,
  only_distinct = TRUE,
  return_message = TRUE
)

# Category based models ----
# split data on primaryCategorie
reviews_electronics <- subset(reviews, mergedCategory == "electronics")
reviews_text_electronics <- as.character(reviews_electronics$reviews.text)

reviews_non_electronics <- subset(reviews, mergedCategory == "non-electronics")
reviews_text_non_electronics <- as.character(reviews_non_electronics$reviews.text)

# Build the models
markov_model_electronics <-
  generate_markovify_model(
    input_text = reviews_text_electronics,
    markov_state_size = 2L,
    max_overlap_total = 25,
    max_overlap_ratio = .85
  )

markov_model_non_electronics <-
  generate_markovify_model(
    input_text = reviews_text_non_electronics,
    markov_state_size = 2L,
    max_overlap_total = 25,
    max_overlap_ratio = .85
  )

# Test model
markovify_text(
  markov_model = markov_model_electronics,
  maximum_sentence_length = NULL,
  output_column_name = 'textProductReview',
  count = 25,
  tries = 100,
  only_distinct = TRUE,
  return_message = TRUE
)

# Test model
markovify_text(
  markov_model = markov_model_non_electronics,
  maximum_sentence_length = NULL,
  output_column_name = 'textProductReview',
  count = 25,
  tries = 100,
  only_distinct = TRUE,
  return_message = TRUE
)

# Product aware model ----
# Test model with starting words
markovify_text(
  markov_model = markov_model,
  maximum_sentence_length = NULL,
  start_words = c("The batteries", "Batteries"),
  output_column_name = 'textProductReview',
  count = 2,
  tries = 100,
  only_distinct = TRUE,
  return_message = TRUE
)
# --> limitation: cannot handle all kinds of starting words, as tries to formulate a valid sentence fail too often.