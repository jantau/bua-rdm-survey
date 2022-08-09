# Load data
# Complete input data is stored locally for data protection reasons
load("/Users/jan/Documents/bua-rdm-survey-data/fdm_survey_data_long_format_complete_surveys.Rdata")

# Anonymize freetext answers of data
# load("input/fdm_survey_data_long_format_complete_surveys.Rdata")
data <- fdm_survey_data_complete_surveys

freitextfragen <- c("DSH6", "DSH7", "SOL", "SER", "COM_1", "COM_2")

data_anonym <- data %>%
  mutate(value = case_when(question_id %in% freitextfragen ~ str_trim(str_remove_all(value, "</?p>")),
                           TRUE ~ value),
         value_decoded = case_when(question_id %in% freitextfragen ~ str_trim(str_remove_all(value_decoded, "</?p>")),
                           TRUE ~ value_decoded)) %>%
  mutate(value = case_when(question_id %in% freitextfragen &
                             str_detect(value, regex("^nein.?$|^no$|^-$|^kein.{0,3}$|^nichts$|^.{1,3}$", ignore_case = TRUE)) ~ "-999",
                           TRUE ~ value),
         value_decoded = case_when(question_id %in% freitextfragen &
                             str_detect(value_decoded, regex("^nein.?$|^no$|^-$|^kein.{0,3}$|^nichts$|^.{1,3}$", ignore_case = TRUE)) ~ "n. geantwortet",
                           TRUE ~ value_decoded)) %>%
  mutate(value = case_when(question_id %in% freitextfragen & 
                             str_detect(value, "^-9..$", negate = TRUE) ~ "Freitextantwort gegeben",
                           TRUE ~ value),
         value_decoded = case_when(question_id %in% freitextfragen & 
                             str_detect(value_decoded, "^n. ge.*|^DMP falsch verstanden$|^Filtersprung$", negate = TRUE) ~ "Freitextantwort gegeben",
                           TRUE ~ value_decoded))

# Control results
# test %>% filter(value == "Freitextantwort gegeben") %>%
#   distinct(data_id, .keep_all = TRUE) %>% nrow

# Save anonymized data in repository
save(data_anonym, file = "input/fdm_survey_data_long_format_complete_surveys_anonym.Rdata")

# Create xlsx-file with freetext answers to review and anonymize if necessary 
sonstiges_und_zwar_fragen <- data %>%
  filter(question_type == "Eingabe" & !question_id %in% freitextfragen) %>%
  select(data_id, question_id, question, value) %>%
  filter(str_detect(value, "^-9..$", negate = TRUE))

library(openxlsx)
write.xlsx(sonstiges_und_zwar_fragen, file = "/Users/jan/Documents/bua-rdm-survey-data/sonstiges-und-zwar-fragen.xlsx", keepNA = TRUE)
