if (!nzchar(Sys.getenv("QUARTO_PROJECT_RENDER_ALL"))) {
  quit()
}
suppressPackageStartupMessages(library(tidyverse, quietly = TRUE))
library(googlesheets4)
library(tidyverse)
library(stringr)
gs4_auth(email = "dschneid@gmail.com")
Sheet <- "https://docs.google.com/spreadsheets/d/1252VDsq9N21Zrl21zkEx0TOjXeKmOddHrwno1xhrEsI/edit?resourcekey#gid=983704671"
sheet1 <- read_sheet(Sheet, sheet = "Form Responses 1")

clean_colnames <- colnames(sheet1) %>%
    str_replace("Which trail or region of Moscow Mountain do you most often use for the activity identified and why", "") %>%
    str_replace("\\(if helpful, see the trailmap on TrailForks https://www.trailforks.com/region/moscow-mountain/\\) ", "most_frequented-") %>%
    str_replace("\\n", "") %>%
    str_replace("Which trail or region of Moscow Mountain for the activity identified is your favorite and why", "") %>%
    str_replace("[?]", "") %>%
    str_replace("\\(if needed, see the official trail map on TrailForks https://www.trailforks.com/region/moscow-mountain/\\) ", "favorite-") %>%
    str_replace("Given the descriptions above, please check any trails you think fit the objective listed in each column. Different activities may elicit different experiences for the different trails. ", "experience-") %>%
    str_replace("[\\[]", "") %>%
    str_replace("[\\]]", "")

# clean_colnames
clean_colnames[1] <- "timestamp"
clean_colnames[2] <- "activity"
clean_colnames[3] <- "level"
clean_colnames[4] <- "why_most_frequented"
clean_colnames[5] <- "why_favorite"
clean_colnames[7] <- "similar_trail_wishes"
# clean_colnames

colnames(sheet1) <- clean_colnames

sheet_write(sheet1, ss = Sheet, sheet = "responses-clean_colnames")


# favorite

fav <- sheet1 %>% select(timestamp, activity, level, contains("favorite"))

fav_long <- fav %>%
    pivot_longer(contains("favorite-")) %>%
    separate(name, c("x", "favorite_trail"), sep = "favorite-") %>%
    select(-x) %>%
    filter(!is.na(value)) %>%
    select(timestamp, activity, level, favorite_trail, why_favorite)
fav_long

sheet_write(fav_long, ss = Sheet, sheet = "favorite_trails")

# frequency

freq <- sheet1 %>% select(timestamp, activity, level, contains("most_frequented"), "why_most_frequented")
freq_long <- freq %>%
    pivot_longer(contains("most_frequented-")) %>%
    separate(name, c("x", "most_frequented_trail"), sep = "most_frequented-") %>%
    filter(!is.na(value)) %>%
    select(timestamp, activity, level, most_frequented_trail, why_most_frequented)
freq_long

sheet_write(freq_long, ss = Sheet, sheet = "frequented_trails")

# experiences

exp <- sheet1 %>% select(timestamp, activity, level, contains("experience"))
exp_long <- exp %>%
    pivot_longer(contains("experience"), names_to = "trail", names_prefix = "experience-", values_to = "experience") %>%
    filter(!is.na(experience)) %>%
    separate_rows(experience, sep = ",")

sheet_write(exp_long, ss = Sheet, sheet = "trail_experiences")
