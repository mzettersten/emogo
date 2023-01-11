library(here)
library(tidyverse)

data_directory <- here("data-analysis","data","spark-psychopathology","raw")
processed_data_directory <- here("data-analysis","data","spark-psychopathology","processed")
file_name <- "emogo-spark-psychopathology"

merge_and_deidentify_data <- function(raw_data_directory, 
                                      merged_data_path, 
                                      min_row=200) {
  
  raw_files <- here(raw_data_directory, dir(here(raw_data_directory), "*.csv"))
  
  #read data
  raw_data <- map_df(raw_files, function(file) {
    d <- read_csv(file,col_types = cols(.default = "c")) %>% 
      mutate(
        file_name = file 
      )
  }) 
  
  # count how many rows in each file 
  raw_count <- raw_data %>% 
    group_by(file_name) %>%
    count() 
  
  raw_data <- raw_data %>%
    left_join(raw_count)
  
  #convert relevant files back to numeric
  numeric_cols <- c("trial_index",
                    "time_elapsed",
                    "rt",
                    "start_time",
                    "end_time",
                    "choice_index",
                    "reward_score",
                    "reward",
                    "reward_score_unadjusted",
                    "score_after_trial",
                    "slider_start",
                    "n")
  
  raw_data <- raw_data %>%
    mutate_at(numeric_cols,as.numeric)
  
  #remove abbreviated responses
  cleaned_data <- raw_data %>%
    filter(n>=min_row) 
  
  #remove workerIds
  anonymized_data <- cleaned_data %>%
   select(-workerId)

  #keep cleaned data for verifying participation
  write_csv(cleaned_data, here(merged_data_path,paste0(file_name,"-alldata.csv")))
  
  #keep anonymized data
  write_csv(anonymized_data, here(merged_data_path,paste0(file_name,"-alldata-anonymized.csv")))
  
}


d <- merge_and_deidentify_data(data_directory, processed_data_directory)
