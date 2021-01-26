library(plyr)
library(tidyverse)
library(ggplot2)


full <- read.csv("delpher_dish_data/final_dish_database.csv")
full$date <- as.Date(full$date)
full$article_type <- as.factor(full$article_type)
full$np_title <- as.factor(full$np_title)

full %>%
  group_by(article_type) %>%
  filter(date<"1986-01-01") %>%
  ggplot(aes(x=date, fill=article_type)) + geom_histogram(bins=8, center=T ) +
    scale_x_date(date_breaks = "5 years", date_labels = "%Y")

full %>%
  group_by(article_type) %>%
  filter(date<"1986-01-01") %>%
  ggplot(aes(x=date, fill=article_type)) + geom_histogram(bins=8, center=T, position= 'fill') +
  scale_x_date(date_breaks = "5 years", date_labels = "%Y") + scale_y_continuous(labels = scales::percent)

