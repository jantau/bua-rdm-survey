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
                             str_detect(value, "^-9..$", negate = TRUE) ~ "[Freitextantwort gegeben]",
                           TRUE ~ value),
         value_decoded = case_when(question_id %in% freitextfragen & 
                             str_detect(value_decoded, "^n. ge.*|^DMP falsch verstanden$|^Filtersprung$", negate = TRUE) ~ "[Freitextantwort gegeben]",
                           TRUE ~ value_decoded))

# Control results
# test %>% filter(value == "Freitextantwort gegeben") %>%
#   distinct(data_id, .keep_all = TRUE) %>% nrow


# Create xlsx-file with freetext answers to review and anonymize if necessary 
sonstiges_und_zwar_fragen <- data %>%
  filter(question_type == "Eingabe" & !question_id %in% freitextfragen) %>%
  select(data_id, question_id, question, value) %>%
  filter(str_detect(value, "^-9..$", negate = TRUE))

library(openxlsx)
write.xlsx(sonstiges_und_zwar_fragen, file = "/Users/jan/Documents/bua-rdm-survey-data/sonstiges-und-zwar-fragen.xlsx", keepNA = TRUE)

# Read anonymized data from Sonstiges-und-zwar-Fragen
library(readxl)
oth <- read_excel("~/Documents/bua-rdm-survey-data/sonstiges-und-zwar-fragen-deidentifiziert.xlsx")

oth_anonym <- oth %>%
  rename(value_anonym = de_identifiziert) %>%
  select(-question, -value)

# Join data_anonym and oth
data_anonym <- data_anonym %>% 
  left_join(oth_anonym, by = c("data_id", "question_id")) %>%
  mutate(value = case_when(!is.na(value_anonym) ~ value_anonym,
                           TRUE ~ value),
         value_decoded = case_when(!is.na(value_anonym) ~ value_anonym,
                           TRUE ~ value_decoded)) %>%
  select(-value_anonym)

# Save anonymized data in input folder of repository
save(data_anonym, file = "input/fdm_survey_data_long_format_complete_surveys_anonym.Rdata")


# Test for rdm strategy chart visualization
# x <- c(1,2,-1)
# y <- c(-1, 1, 1.5)
# color <- c("A", "B", "C")
# text <- c("Adjsja agdagd gjahdgad", "Badad adad dadaa", "Cdasd asas dad")
# size <- c(1, 2, 3)
# weight <- c(3, 2, 1)
# 
# 
# plot_ly(
#   x = ~x,
#   y = -y,
#   color = ~color,
#   shape = ~weight,
#   text = ~text
# ) %>%
#   add_markers(marker = list(sizemode = 'diameter'), size = ~size, opacity = 0.5) %>%
#   add_text(textposition = "center")




