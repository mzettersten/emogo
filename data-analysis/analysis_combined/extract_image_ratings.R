library(here)
library(tidyverse)
library(jsonlite)

d_v1 <- read_csv(here("data-analysis", "data","v1","processed","emogo-v1-alldata-anonymized.csv")) %>%
  mutate(task_version = "v1")

d_v2 <- read_csv(here("data-analysis", "data","v2","processed","emogo-v2-alldata.csv")) %>%
  mutate(task_version = "v2")

d_pers <- read_csv(here("data-analysis", "data","spark-personality","processed","emogo-spark-personality-alldata-anonymized.csv")) %>%
  mutate(task_version = "spark-personality")

d_psych <- read_csv(here("data-analysis", "data","spark-psychopathology","processed","emogo-spark-psychopathology-alldata-anonymized.csv")) %>%
  mutate(task_version = "spark-psychopathology")

d <- d_v1 %>%
  full_join(d_v2) %>%
  full_join(d_pers) %>%
  full_join(d_psych)

image_rating_d <- d %>%
  rename(stimulus_image=simulus_image) %>%
  filter((trial_type %in% c("survey-text","html-slider-response"))&!is.na(stimulus_image)) %>%
  select(task_version,subject,trial_type,stimulus_image,response,slider_start) %>%
  mutate(response_clean = map(response, ~ fromJSON(.) %>% as.data.frame()))
