library(tidyverse)
library(here)
library(gghalves)
library(cowplot)

cosine_similarity_d <- read_csv(here("data-analysis", "data","combined","emogo-combined-cosine-similarity-image-pairs.csv"))
nameability_d <- read_csv(here("data-analysis", "data","combined","emogo-combined-nameability.csv"))

cosine_similarity_d <- cosine_similarity_d %>%
  tidyr::separate(image_pair, into=c("model_1","emotion_1","model_2","emotion_2"),sep="_",remove=FALSE) %>%
  mutate(same_emotion=ifelse(emotion_1==emotion_2,"yes","no"),
         same_model=ifelse(model_1==model_2,"yes","no")) %>%
  rowwise() %>%      
  mutate(
    emotion_pair = paste(sort(c(emotion_1, emotion_2)), collapse = " - "),
    model_pair = paste(sort(c(model_1, model_2)), collapse = " - ")) %>%  
  ungroup()
  

nameability_d <- nameability_d %>%
  tidyr::separate(image, into=c("model","emotion"),sep="_",remove=FALSE)

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

ggplot(nameability_d,aes(emotion,percent_unique_words))+
  geom_boxplot()+
  #geom_point()+
  theme(axis.text.x  = element_text(angle=90, vjust=0.5))

ggplot(nameability_d,aes(reorder(emotion,-simpson_diversity,mean),simpson_diversity,color=emotion))+
  geom_half_boxplot(side="r",nudge=0.2)+
  geom_half_violin(side="l",nudge=0.2)+
  geom_jitter(width=0.05)+
  theme(axis.text.x  = element_text(angle=90, vjust=0.5))+
  theme_cowplot()+
  theme(legend.position="none")+
  xlab("Emotion")+
  ylab("Simpson Diversity")

ggplot(nameability_d,aes(reorder(emotion,-modal_agreement,mean),modal_agreement,color=emotion))+
  geom_half_boxplot(side="r",nudge=0.2)+
  geom_half_violin(side="l",nudge=0.2)+
  geom_jitter(width=0.05)+
  theme(axis.text.x  = element_text(angle=90, vjust=0.5))+
  theme(legend.position="none")

ggplot(nameability_d,aes(emotion,percent_unique_words,color=emotion))+
  geom_half_boxplot(side="r",nudge=0.2)+
  geom_half_violin(side="l",nudge=0.2)+
  geom_jitter(width=0.05)+
  theme(axis.text.x  = element_text(angle=90, vjust=0.5))+
  theme(legend.position="none")

ggplot(nameability_d,aes(emotion,simpson_diversity))+
  geom_boxplot()+
  #geom_point()+
  theme(axis.text.x  = element_text(angle=90, vjust=0.5))+
  

ggplot(nameability_d,aes(model,simpson_diversity))+
  geom_boxplot()+
  #geom_point()+
  theme(axis.text.x  = element_text(angle=90, vjust=0.5))
