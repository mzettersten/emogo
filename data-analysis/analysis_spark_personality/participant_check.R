### only run with access to raw, identifiable data ###
library(here)
library(tidyverse)
data_path <- here("data-analysis","data","spark-personality","processed", "emogo-spark-personality-alldata.csv")
d <- read_csv(data_path)

## Add bonuses
bonus_participants <- read_csv(here("data-analysis","data","spark-personality","processed","subjects_top_50.csv"))

bonus_worker_ids <- d %>%
  select(subject,workerId) %>%
  distinct() %>%
  right_join(bonus_participants) %>%
  mutate(receives_bonus=1)

write_csv(bonus_worker_ids,here("data-analysis","data","spark-personality","processed","spark-personality-workerId_top_50.csv"))

