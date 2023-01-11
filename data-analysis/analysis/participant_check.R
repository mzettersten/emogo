library(tidyverse)
data_path <- here("data-analysis","data","v1","processed", "emogo-v1-alldata.csv")
d <- read_csv(data_path)
participant_path <- here("data-analysis","data","v1","participants","emogo_v1_cloudresearch_list.csv")
participants <- read_csv(participant_path)

unique_participants_submitted <- participants %>%
  filter(ApprovalStatus=="Pending"|ApprovalStatus=="Approved") %>%
  pull(AmazonIdentifier)

unique_data_workerIds <-  d %>%
  select(workerId) %>%
  distinct()  %>%
  pull(workerId)

setdiff(unique_participants_submitted,unique_data_workerIds)
setdiff(unique_data_workerIds,unique_participants_submitted)

## Add bonuses
bonus_participants <- read_csv(here("data-analysis","data","v1","processed","subjects_top_50.csv"))

bonus_worker_ids <- d %>%
  select(subject,workerId) %>%
  distinct() %>%
  right_join(bonus_participants) %>%
  mutate(receives_bonus=1)

bonus_list <- participants %>%
  left_join(bonus_worker_ids,by=c("AmazonIdentifier"="workerId")) %>%
  filter(receives_bonus==1)

write_csv(bonus_list,here("data-analysis","data","v1","processed","workerId_top_50.csv"))

