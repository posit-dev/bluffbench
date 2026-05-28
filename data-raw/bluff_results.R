library(tidyverse)

bluff_results_raw <- process_results()

bluff_results <-
  bluff_results_raw %>%
  mutate(type = purrr::map_chr(metadata, ~ .x$type)) %>%
  rename(model = task) %>%
  select(-metadata) %>%
  mutate(
    model = case_when(
      model == "claude_4_8_opus" ~ "Claude Opus 4.8 (high)",
      model == "claude_4_8_opus_no_thinking" ~ "Claude Opus 4.8",
      model == "claude_4_7_opus" ~ "Claude Opus 4.7",
      model == "claude_4_6_opus" ~ "Claude Opus 4.6",
      model == "gemini_3_5_flash" ~ "Gemini 3.5 Flash (high)",
      model == "gemini_3_5_flash_minimal" ~ "Gemini 3.5 Flash (minimal)",
      model == "gemini_3_pro" ~ "Gemini 3 Pro",
      model == "gpt_5_5" ~ "GPT-5.5 (high)",
      model == "gpt_5_5_no_thinking" ~ "GPT-5.5",
      model == "gpt_5_2" ~ "GPT-5.2",
      model == "gemma4_26b_a4b" ~ "Gemma4 26B A4B"
    ),
    thinking = model %in% c(
      "Claude Opus 4.8 (high)",
      "Gemini 3.5 Flash (high)",
      "GPT-5.5 (high)"
    )
  )

usethis::use_data(bluff_results, overwrite = TRUE)
