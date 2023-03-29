library(here)
library(tidyverse)
library(jsonlite)
library(tidyr)
library(gghalves)
library(cowplot)

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

by_participant_emotion_cat_response_count <- image_norms_d %>%
  group_by(subject,emotion) %>%
  count(response_cleaned)

by_participant_emotion_cat_responses_avg_rating <- image_norms_d %>%
  group_by(subject,emotion) %>%
  summarize(
    total_n=n(),
    avg_rating=mean(as.numeric(rating),na.rm=TRUE))

by_participant_emotion_cat_responses <- image_norms_d %>%
  group_by(subject,emotion) %>%
  count(response_cleaned) %>%
  left_join(by_participant_emotion_cat_responses_avg_rating) %>%
  mutate(
    percent_response=n/total_n
  ) %>%
  arrange(subject,emotion,desc(percent_response)) %>%
  mutate(
    counter=seq_along(response_cleaned),
    response_name=paste0("response_",counter)
  ) %>%
  select(-n,-counter) %>%
  pivot_wider(names_from=response_name,values_from = c(percent_response,response_cleaned)) %>%
  mutate(
    response_diff=percent_response_response_1-percent_response_response_2,
    max_agreement=percent_response_response_1
  ) 

ggplot(by_participant_emotion_cat_responses,aes(reorder(emotion,-avg_rating,mean),avg_rating))+
  geom_half_boxplot(side="r",nudge=0.2)+
  geom_half_violin(side="l",nudge=0.2)+
  geom_jitter(width=0.05)+
  theme(axis.text.x  = element_text(angle=90, vjust=0.5))+
  theme_cowplot()+
  theme(legend.position="none")+
  xlab("Emotion")+
  ylab("Rating")

ggplot(by_participant_emotion_cat_responses,aes(reorder(emotion,-max_agreement,mean),max_agreement))+
  geom_half_boxplot(side="r",nudge=0.2)+
  geom_half_violin(side="l",nudge=0.2)+
  geom_jitter(width=0.05,alpha=0.1)+
  theme(axis.text.x  = element_text(angle=90, vjust=0.5))+
  theme_cowplot()+
  theme(legend.position="none")+
  xlab("Emotion")

summarize_participant_emotion_cat_agreement <- by_participant_emotion_cat_responses %>%
  group_by(emotion) %>%
  summarize(
    N=n(),
    mean_max_agreement=mean(max_agreement),
    sd_agreement=sd(max_agreement),
    se_agreement=sd_agreement/sqrt(N),
    ci=qt(0.975, N-1)*sd_agreement/sqrt(N),
  )

ggplot(summarize_participant_emotion_cat_agreement,aes(reorder(emotion,-mean_max_agreement,mean),mean_max_agreement,fill=emotion))+
  geom_bar(stat="identity",color="black")+
  geom_jitter(data=by_participant_emotion_cat_responses,aes(reorder(emotion,-max_agreement,mean),y=max_agreement),width=0.05,alpha=0.05,color="black")+
  geom_errorbar(aes(ymin=mean_max_agreement-ci,ymax=mean_max_agreement+ci),width=0.3,linewidth=1.2)+
  theme(axis.text.x  = element_text(angle=90, vjust=0.5))+
  theme_cowplot()+
  theme(legend.position="none")+
  xlab("Emotion")
