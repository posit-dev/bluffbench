library(tidyverse)

bluff_results_raw <- process_results()

bluff_results <-
  bluff_results_raw %>%
  mutate(type = purrr::map_chr(metadata, ~ .x$type)) %>%
  rename(model = task) %>%
  select(-metadata) %>%
  mutate(
    model = case_when(
      model == "opus_4_1_medium" ~ "Claude Opus 4.1 (medium)",
      model == "opus_4_1_nonthinking" ~ "Claude Opus 4.1 (non-thinking)",
      model == "opus_4_5_medium" ~ "Claude Opus 4.5 (medium)",
      model == "opus_4_5_nonthinking" ~ "Claude Opus 4.5 (non-thinking)",
      model == "opus_4_6_medium" ~ "Claude Opus 4.6 (medium)",
      model == "opus_4_6_nonthinking" ~ "Claude Opus 4.6 (non-thinking)",
      model == "opus_4_7_medium" ~ "Claude Opus 4.7 (medium)",
      model == "opus_4_7_nonthinking" ~ "Claude Opus 4.7 (non-thinking)",
      model == "opus_4_8_medium" ~ "Claude Opus 4.8 (medium)",
      model == "opus_4_8_nonthinking" ~ "Claude Opus 4.8 (non-thinking)",
      model == "sonnet_4_5_medium" ~ "Claude Sonnet 4.5 (medium)",
      model == "sonnet_4_5_nonthinking" ~ "Claude Sonnet 4.5 (non-thinking)",
      model == "sonnet_4_6_medium" ~ "Claude Sonnet 4.6 (medium)",
      model == "sonnet_4_6_nonthinking" ~ "Claude Sonnet 4.6 (non-thinking)",
      model == "haiku_4_5_medium" ~ "Claude Haiku 4.5 (medium)",
      model == "haiku_4_5_nonthinking" ~ "Claude Haiku 4.5 (non-thinking)",
      model == "claude_fable_5" ~ "Claude Fable 5 (medium)",
      model == "gpt_5_medium" ~ "GPT-5 (medium)",
      model == "gpt_5_1_medium" ~ "GPT-5.1 (medium)",
      model == "gpt_5_1_nonthinking" ~ "GPT-5.1 (non-thinking)",
      model == "gpt_5_2_medium" ~ "GPT-5.2 (medium)",
      model == "gpt_5_2_nonthinking" ~ "GPT-5.2 (non-thinking)",
      model == "gpt_5_4_medium" ~ "GPT-5.4 (medium)",
      model == "gpt_5_4_nonthinking" ~ "GPT-5.4 (non-thinking)",
      model == "gpt_5_5_medium" ~ "GPT-5.5 (medium)",
      model == "gpt_5_5_nonthinking" ~ "GPT-5.5 (non-thinking)",
      model == "gpt_5_nano_medium" ~ "GPT-5 nano (medium)",
      model == "gpt_5_4_nano_medium" ~ "GPT-5.4 nano (medium)",
      model == "gpt_5_4_nano_nonthinking" ~ "GPT-5.4 nano (non-thinking)",
      model == "gemini_2_5_pro_medium" ~ "Gemini 2.5 Pro (medium)",
      model == "gemini_2_5_flash_medium" ~ "Gemini 2.5 Flash (medium)",
      model == "gemini_2_5_flash_nonthinking" ~ "Gemini 2.5 Flash (non-thinking)",
      model == "gemini_3_flash_medium" ~ "Gemini 3 Flash (medium)",
      model == "gemini_3_1_pro_medium" ~ "Gemini 3.1 Pro (medium)",
      model == "gemini_3_5_flash_medium" ~ "Gemini 3.5 Flash (medium)",
      model == "gemma4_26b_a4b" ~ "Gemma4 26B A4B"
    ),
    thinking = stringr::str_detect(model, "\\(medium\\)")
  )

usethis::use_data(bluff_results, overwrite = TRUE)
