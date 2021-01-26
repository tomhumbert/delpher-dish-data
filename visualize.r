library(plyr)
library(tidyverse)
library(ggplot2)
library(wordcloud)
library(tm)
library(Rstem)
library(stringr)
library(SnowballC)

full <- read.csv("final_dish_database.csv")
full$date <- as.Date(full$date)

artikels <- full %>%
  filter(article_type == 'artikel')

dec1 <- artikels %>%
  filter(date < '1956-01-01')

dec2 <- artikels %>%
  filter(date > '1956-01-01' && date < '1966-01-01')

dec3 <- artikels %>%
  filter(date > '1966-01-01' && date < '1976-01-01')

dec2 <- artikels %>%
  filter(date > '1976-01-01' && date < '1986-01-01')

# !!!
# Code taken as proposed by Martin Schweinberger (http://www.martinschweinberger.de/blog/creating-word-clouds-with-r/)
# !!!
corp <- Corpus(VectorSource(dec3)) # Create a corpus from the vectors
#corp <- tm_map(corp, stemDocument, language = "german") # stem words (inactive because I want intakt words)
corp <- tm_map(corp, removePunctuation) # remove punctuation
corp <- tm_map(corp, tolower) # convert all words to lower case
corp <- tm_map(corp, removeNumbers) # remove all numerals
corp <- tm_map(corp, function(x)removeWords(x, stopwords("dutch")))

corp <- sapply(corp, function(x) {
  x <- gsub("apos", "", x)
  x <- gsub("quot", "", x)
  x <- gsub("httpresolverkbnlresolveurnabcdddmpega", "", x)
  x <- gsub("resourcesabcdddtextdddtextxml", "", x)
  x <- gsub("dddmpega", "", x)
  x <- gsub("nasi", "", x)
  x <- gsub("bami", "", x)
  x <- gsub("goreng", "", x)
} )

corp <- Corpus(VectorSource(corp))  # convert vectors back into a corpus

# Create a term document matrix
term.matrix <- TermDocumentMatrix(corp)  # crate a term document matrix
#term.matrix <- removeSparseTerms(term.matrix, 0.5) # remove infrequent words
term.matrix <- as.matrix(term.matrix)
# clean row names

# normalize absolute frequencies: convert absolute frequencies 
# to relative freqeuncies (per 1,000 words)
#colSums(term.matrix)
term.matrix[, 1] <- as.vector(unlist(sapply(term.matrix[, 1], function(x) round(x/colSums(term.matrix)[1]*1000, 0) )))
term.matrix[, 2] <- as.vector(unlist(sapply(term.matrix[, 2], function(x) round(x/colSums(term.matrix)[2]*1000, 0) )))
term.matrix[, 3] <- as.vector(unlist(sapply(term.matrix[, 3], function(x) round(x/colSums(term.matrix)[3]*1000, 0) )))
term.matrix[, 4] <- as.vector(unlist(sapply(term.matrix[, 4], function(x) round(x/colSums(term.matrix)[4]*1000, 0) )))
term.matrix[, 5] <- as.vector(unlist(sapply(term.matrix[, 5], function(x) round(x/colSums(term.matrix)[5]*1000, 0) )))
#colSums(term.matrix)

# Create word clouds
wordcloud(corp, max.words = 100, colors = brewer.pal(6, "Dark2"), random.order = FALSE)
#comparison.cloud(term.matrix, max.words = 100, random.order = FALSE, colors = brewer.pal(8, "Dark2"))
#commonality.cloud(term.matrix, max.words = 100, random.order = FALSE)
