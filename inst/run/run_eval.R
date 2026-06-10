withr::local_envvar(VITALS_LOG_DIR = "inst/run/logs")
devtools::load_all()

tsk <- bluff_task(epochs = 3)

# To use a model-in-the-middle that interprets plots as text:
# tsk$eval(solver_chat = ..., model_in_the_middle = TRUE)

# Claude Fable 5 -----------------------------------------------------
# Fable 5 isn't accessible with the usual key; use the one in .env.
# ~/.Renviron overrides the shell environment, so set this within R.
readRenviron(".env")

tsk_claude_fable_5 <- tsk$clone()
tsk_claude_fable_5$eval(
  solver_chat = ellmer::chat_anthropic(
    model = "claude-fable-5",
    api_args = list(
      thinking = list(type = "adaptive"),
      output_config = list(effort = "medium")
    )
  )
)

save(tsk_claude_fable_5, file = "inst/run/tasks/tsk_claude_fable_5.rda")

# Claude Fable 5 (no thinking) ---------------------------------------
# Note: Fable 5 400s on an explicit thinking = "disabled"; omit it instead.
tsk_claude_fable_5_no_thinking <- tsk$clone()
tsk_claude_fable_5_no_thinking$eval(
  solver_chat = ellmer::chat_anthropic(model = "claude-fable-5")
)

save(
  tsk_claude_fable_5_no_thinking,
  file = "inst/run/tasks/tsk_claude_fable_5_no_thinking.rda"
)

# Claude 4.8 Opus ----------------------------------------------------
tsk_claude_4_8_opus <- tsk$clone()
tsk_claude_4_8_opus$eval(
  solver_chat = ellmer::chat_anthropic(
    model = "claude-opus-4-8",
    api_args = list(
      thinking = list(type = "adaptive"),
      output_config = list(effort = "high")
    )
  )
)

save(tsk_claude_4_8_opus, file = "inst/run/tasks/tsk_claude_4_8_opus.rda")

# Claude 4.8 Opus (no thinking) -------------------------------------
tsk_claude_4_8_opus_no_thinking <- tsk$clone()
tsk_claude_4_8_opus_no_thinking$eval(
  solver_chat = ellmer::chat_anthropic(model = "claude-opus-4-8")
)

save(tsk_claude_4_8_opus_no_thinking, file = "inst/run/tasks/tsk_claude_4_8_opus_no_thinking.rda")

# Claude 4.7 Opus ----------------------------------------------------
tsk_claude_4_7_opus <- tsk$clone()
tsk_claude_4_7_opus$eval(
  solver_chat = ellmer::chat_anthropic(model = "claude-opus-4-7")
)

save(tsk_claude_4_7_opus, file = "inst/run/tasks/tsk_claude_4_7_opus.rda")

# Claude 4.6 Opus ----------------------------------------------------
tsk_claude_4_6_opus <- tsk$clone()
tsk_claude_4_6_opus$eval(
  solver_chat = ellmer::chat_anthropic(model = "claude-opus-4-6")
)

save(tsk_claude_4_6_opus, file = "inst/run/tasks/tsk_claude_4_6_opus.rda")

# Gemini 3.5 Flash (high) --------------------------------------------
tsk_gemini_3_5_flash <- tsk$clone()
tsk_gemini_3_5_flash$eval(
  solver_chat = ellmer::chat_google_gemini(
    model = "gemini-3.5-flash",
    api_args = list(
      generationConfig = list(
        thinkingConfig = list(
          thinkingLevel = "HIGH"
        )
      )
    )
  )
)

save(tsk_gemini_3_5_flash, file = "inst/run/tasks/tsk_gemini_3_5_flash.rda")

# Gemini 3.5 Flash (minimal) ----------------------------------------
tsk_gemini_3_5_flash_minimal <- tsk$clone()
tsk_gemini_3_5_flash_minimal$eval(
  solver_chat = ellmer::chat_google_gemini(
    model = "gemini-3.5-flash",
    api_args = list(
      generationConfig = list(
        thinkingConfig = list(
          thinkingLevel = "MINIMAL"
        )
      )
    )
  )
)

save(tsk_gemini_3_5_flash_minimal, file = "inst/run/tasks/tsk_gemini_3_5_flash_minimal.rda")

# gemini 3 pro ------------------------------------------------------
tsk_gemini_3_pro <- tsk$clone()
tsk_gemini_3_pro$eval(
  solver_chat = ellmer::chat_google_gemini(model = "gemini-3-pro-preview")
)

save(tsk_gemini_3_pro, file = "inst/run/tasks/tsk_gemini_3_pro.rda")

# GPT-5.5 (high) ----------------------------------------------------
tsk_gpt_5_5 <- tsk$clone()
tsk_gpt_5_5$eval(
  solver_chat = ellmer::chat_openai(
    model = "gpt-5.5",
    params = ellmer::params(reasoning_effort = "high")
  )
)

save(tsk_gpt_5_5, file = "inst/run/tasks/tsk_gpt_5_5.rda")

# GPT-5.5 (no thinking) ---------------------------------------------
tsk_gpt_5_5_no_thinking <- tsk$clone()
tsk_gpt_5_5_no_thinking$eval(
  solver_chat = ellmer::chat_openai(model = "gpt-5.5")
)

save(tsk_gpt_5_5_no_thinking, file = "inst/run/tasks/tsk_gpt_5_5_no_thinking.rda")

# gpt-5.2 -----------------------------------------------------------
tsk_gpt_5_2 <- tsk$clone()
tsk_gpt_5_2$eval(
  solver_chat = ellmer::chat_openai(model = "gpt-5.2")
)

save(tsk_gpt_5_2, file = "inst/run/tasks/tsk_gpt_5_2.rda")

# gemma 4 26B A4B ------------------------------------------------------
gemma4_26b_a4b <-
  ellmer::chat_openai_compatible(
    base_url = paste0(Sys.getenv("GEMMA4_BASE_URL"), "/v1"),
    model = "google/gemma-4-26B-A4B-it",
    credentials = function() Sys.getenv("BASETEN_API_KEY")
  )

tsk_gemma4_26b_a4b <- tsk$clone()
tsk_gemma4_26b_a4b$eval(
  solver_chat = gemma4_26b_a4b
)
save(tsk_gemma4_26b_a4b, file = "inst/run/tasks/tsk_gemma4_26b_a4b.rda")
