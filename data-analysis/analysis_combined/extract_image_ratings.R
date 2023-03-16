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

write_csv(d,here("data-analysis", "data","combined","emogo-combined-alldata-anonymized.csv"))

image_response_d <- d %>%
  rename(stimulus_image=simulus_image) %>%
  filter((trial_type %in% c("survey-text"))&!is.na(stimulus_image)) %>%
  select(task_version,subject,trial_type,stimulus_image,response) %>%
  mutate(response_raw = map(response, ~ fromJSON(.) %>% as.data.frame())) %>%
  unnest(response_raw) %>%
  rename(response_raw=Q0) %>%
  mutate(response_cleaned=trimws(tolower(response_raw))) %>%
  select(-trial_type,-response)

image_rating_d <- d %>%
  rename(stimulus_image=simulus_image) %>%
  filter((trial_type %in% c("html-slider-response"))) %>%
  select(task_version,subject,trial_type,stimulus_image,response,slider_start) %>%
  select(-trial_type) %>%
  rename(rating=response)

image_norms_d <- image_response_d %>%
  left_join(image_rating_d) %>%
  mutate(stimulus=str_replace(stimulus_image,"stimuli/","")) %>%
  mutate(stimulus=str_replace(stimulus,".jpg","")) %>%
  separate(stimulus,into=c("model","emotion"),sep="_",remove=FALSE)

write_csv(image_norms_d,here("data-analysis", "data","combined","emogo-combined-image-norms.csv"))

temp <- image_norms_d %>%
  group_by(emotion,response_cleaned) %>%
  summarize(n=n())
