library(tidyverse)
library(here)

cosine_similarity_d <- read_csv(here("data-analysis", "data","combined","emogo-combined-cosine-similarity-image-pairs.csv"))
nameability_d <- read_csv(here("data-analysis", "data","combined","emogo-combined-nameability.csv"))

cosine_similarity_d <- cosine_similarity_d %>%
  separate(image_pair, into=c("model_1","emotion_1","model_2","emotion_2"),sep="_",remove=FALSE) %>%
  mutate(same_emotion=ifelse(emotion_1==emotion_2,"yes","no"),
         same_model=ifelse(model_1==model_2,"yes","no")) %>%
  rowwise() %>%      
  mutate(
    emotion_pair = paste(sort(c(emotion_1, emotion_2)), collapse = " - "),
    model_pair = paste(sort(c(model_1, model_2)), collapse = " - ")) %>%  
  ungroup()

cosine_similarity_summarized <- cosine_similarity_d %>%
  

nameability_d <- nameability_d %>%
  separate(image, into=c("model","emotion"),sep="_",remove=FALSE)

ggplot(cosine_similarity_d,aes(emotion_pair,lemma_cosine_sim,color=same_emotion))+
  geom_boxplot()+
  #geom_point()+
  theme(axis.text.x  = element_text(angle=90, vjust=0.5))

ggplot(nameability_d,aes(emotion,simpson_diversity))+
  geom_boxplot()+
  #geom_point()+
  theme(axis.text.x  = element_text(angle=90, vjust=0.5))

ggplot(nameability_d,aes(emotion,modal_agreement))+
  geom_boxplot()+
  #geom_point()+
  theme(axis.text.x  = element_text(angle=90, vjust=0.5))

ggplot(nameability_d,aes(model,simpson_diversity))+
  geom_boxplot()+
  #geom_point()+
  theme(axis.text.x  = element_text(angle=90, vjust=0.5))
