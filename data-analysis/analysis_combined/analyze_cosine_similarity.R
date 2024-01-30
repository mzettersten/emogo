library(tidyverse)
library(here)
library(gghalves)
library(cowplot)

cosine_similarity_d <- read_csv(here("data-analysis", "data","combined","emogo-combined-cosine-similarity-image-pairs.csv"))
nameability_d <- read_csv(here("data-analysis", "data","combined","emogo-combined-nameability.csv"))
d <- read_csv(here("data-analysis", "data","combined","emogo-combined-alldata-anonymized.csv"))

#extract image names
d <- d %>%
  mutate(
    image_base1 = str_remove(basename(d$image1),".jpg"),
    image_base2 = str_remove(basename(d$image2),".jpg"),
    image_base3 = str_remove(basename(d$image3),".jpg"),
    image_base4 = str_remove(basename(d$image4),".jpg")
  )

column_combinations <- combn(names(select(d,image_base1:image_base4)), 2, simplify = FALSE)

# Function to unite two columns in alphabetical order
unite_alphabetically <- function(df, cols) {
  col_name <- paste(sort(cols), collapse = "_")
  df %>%
    rowwise() %>%
    mutate(!!col_name := paste0(sort(c_across(all_of(cols))), collapse = "_")) %>%
    ungroup()
}

# Unite each pair into a new column, alphabetically
for (pair in column_combinations) {
  d <- unite_alphabetically(d, pair)
}

#join in cosine similarity 
d <- d %>%
  left_join(select(cosine_similarity_d,image_pair,lemma_cosine_sim),by=c("image_base1_image_base2"="image_pair")) %>%
  rename(lemma_cosine_sim_12=lemma_cosine_sim) %>%
  left_join(select(cosine_similarity_d,image_pair,lemma_cosine_sim),by=c("image_base1_image_base3"="image_pair")) %>%
  rename(lemma_cosine_sim_13=lemma_cosine_sim) %>%
  left_join(select(cosine_similarity_d,image_pair,lemma_cosine_sim),by=c("image_base1_image_base4"="image_pair")) %>%
  rename(lemma_cosine_sim_14=lemma_cosine_sim) %>%
  left_join(select(cosine_similarity_d,image_pair,lemma_cosine_sim),by=c("image_base2_image_base3"="image_pair")) %>%
  rename(lemma_cosine_sim_23=lemma_cosine_sim) %>%
  left_join(select(cosine_similarity_d,image_pair,lemma_cosine_sim),by=c("image_base2_image_base4"="image_pair")) %>%
  rename(lemma_cosine_sim_24=lemma_cosine_sim) %>%
  left_join(select(cosine_similarity_d,image_pair,lemma_cosine_sim),by=c("image_base3_image_base4"="image_pair")) %>%
  rename(lemma_cosine_sim_34=lemma_cosine_sim) %>%
  mutate(
    reward_combo_86_lemma_cosine_sim = case_when(
      reward1==8 & reward2==6 ~ lemma_cosine_sim_12,
      reward1==8 & reward3==6 ~ lemma_cosine_sim_13,
      reward1==8 & reward4==6 ~ lemma_cosine_sim_14,
      reward2==8 & reward3==6 ~ lemma_cosine_sim_23,
      reward2==8 & reward4==6 ~ lemma_cosine_sim_24,
      reward2==8 & reward1==6 ~ lemma_cosine_sim_12,
      reward3==8 & reward4==6 ~ lemma_cosine_sim_34,
      reward3==8 & reward2==6 ~ lemma_cosine_sim_23,
      reward3==8 & reward1==6 ~ lemma_cosine_sim_13,
      reward4==8 & reward3==6 ~ lemma_cosine_sim_34,
      reward4==8 & reward2==6 ~ lemma_cosine_sim_24,
      reward4==8 & reward1==6 ~ lemma_cosine_sim_14,
    ),
    reward_combo_84_lemma_cosine_sim = case_when(
      reward1==8 & reward2==4 ~ lemma_cosine_sim_12,
      reward1==8 & reward3==4 ~ lemma_cosine_sim_13,
      reward1==8 & reward4==4 ~ lemma_cosine_sim_14,
      reward2==8 & reward3==4 ~ lemma_cosine_sim_23,
      reward2==8 & reward4==4 ~ lemma_cosine_sim_24,
      reward2==8 & reward1==4 ~ lemma_cosine_sim_12,
      reward3==8 & reward4==4 ~ lemma_cosine_sim_34,
      reward3==8 & reward2==4 ~ lemma_cosine_sim_23,
      reward3==8 & reward1==4 ~ lemma_cosine_sim_13,
      reward4==8 & reward3==4 ~ lemma_cosine_sim_34,
      reward4==8 & reward2==4 ~ lemma_cosine_sim_24,
      reward4==8 & reward1==4 ~ lemma_cosine_sim_14,
    ),
    reward_combo_82_lemma_cosine_sim = case_when(
      reward1==8 & reward2==2 ~ lemma_cosine_sim_12,
      reward1==8 & reward3==2 ~ lemma_cosine_sim_13,
      reward1==8 & reward4==2 ~ lemma_cosine_sim_14,
      reward2==8 & reward3==2 ~ lemma_cosine_sim_23,
      reward2==8 & reward4==2 ~ lemma_cosine_sim_24,
      reward2==8 & reward1==2 ~ lemma_cosine_sim_12,
      reward3==8 & reward4==2 ~ lemma_cosine_sim_34,
      reward3==8 & reward2==2 ~ lemma_cosine_sim_23,
      reward3==8 & reward1==2 ~ lemma_cosine_sim_13,
      reward4==8 & reward3==2 ~ lemma_cosine_sim_34,
      reward4==8 & reward2==2 ~ lemma_cosine_sim_24,
      reward4==8 & reward1==2 ~ lemma_cosine_sim_14,
    ),
  ) %>%
  mutate(
    avg_reward_lemma_cosine_sim=rowMeans(pick(reward_combo_82_lemma_cosine_sim,reward_combo_84_lemma_cosine_sim,reward_combo_86_lemma_cosine_sim),na.rm=TRUE),
    max_reward_lemma_cosine_sim=pmax(reward_combo_82_lemma_cosine_sim,reward_combo_84_lemma_cosine_sim,reward_combo_86_lemma_cosine_sim,na.rm=TRUE)
  ) %>%
  group_by(subject,cur_structure_condition) %>%
  mutate(
    avg_reward_lemma_cosine_sim_c=avg_reward_lemma_cosine_sim-mean(avg_reward_lemma_cosine_sim,na.rm=TRUE),
    max_reward_lemma_cosine_sim_c=max_reward_lemma_cosine_sim-mean(max_reward_lemma_cosine_sim,na.rm=TRUE),
    
  )

m_cosine <- glmer(max_reward_choice ~ block_trial_number_c*avg_reward_lemma_cosine_sim_c + (1+avg_reward_lemma_cosine_sim_c|subject)+(1|choiceImage),data=filter(d,block==1&cur_structure_condition=="emotion"), family=binomial,glmerControl(optimizer="bobyqa"))
summary(m_cosine)
confint(m_cosine, method="Wald")

m_cosine_int <- glmer(max_reward_choice ~ cur_structure_condition_emotion*block_trial_number_c*avg_reward_lemma_cosine_sim_c + (1+avg_reward_lemma_cosine_sim_c|subject)+(1|choiceImage),data=d, family=binomial,glmerControl(optimizer="bobyqa"))
summary(m_cosine_int)
confint(m_cosine_int, method="Wald")

m_cosine_emotion <- glmer(max_reward_choice ~ block_trial_number_c*avg_reward_lemma_cosine_sim_c + (1|subject)+(1|choiceImage),data=filter(d,block==1&cur_structure_condition=="emotion"), family=binomial,glmerControl(optimizer="bobyqa"))
summary(m_cosine_emotion)
confint(m_cosine_emotion, method="Wald")

m_cosine_generalize <- glmer(max_reward_choice ~ cur_structure_condition_c*block_trial_number_c*avg_reward_lemma_cosine_sim_c + (1|subject)+(1|choiceImage),data=filter(d,block==2), family=binomial,glmerControl(optimizer="bobyqa"))
summary(m_cosine_generalize)



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

cosine_similarity_summarize_by_emotion_cat <- cosine_similarity_d %>%
  group_by(same_emotion) %>%
  summarize(
    N=n(),
    mean_similarity=mean(lemma_cosine_sim,na.rm=T)

  )

cosine_similarity_summarize_by_emotion_pair <- cosine_similarity_d %>%
  group_by(emotion_pair) %>%
  summarize(
    N=n(),
    mean_similarity=mean(lemma_cosine_sim,na.rm=T)
    
  )

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
