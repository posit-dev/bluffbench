withr::local_envvar(VITALS_LOG_DIR = "inst/run/logs")
devtools::load_all()

tsk <- bluff_task(epochs = 3)

# To use a model-in-the-middle that interprets plots as text:
# tsk$eval(solver_chat = ..., model_in_the_middle = TRUE)

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

# gemini 3 pro ------------------------------------------------------
tsk_gemini_3_pro <- tsk$clone()
tsk_gemini_3_pro$eval(
  solver_chat = ellmer::chat_google_gemini(model = "gemini-3-pro-preview")
)

save(tsk_gemini_3_pro, file = "inst/run/tasks/tsk_gemini_3_pro.rda")

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
