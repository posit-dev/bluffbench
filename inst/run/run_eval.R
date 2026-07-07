withr::local_envvar(VITALS_LOG_DIR = "inst/run/logs")
devtools::load_all()

tsk <- bluff_task(epochs = 3)

# To use a model-in-the-middle that interprets plots as text:
# tsk$eval(solver_chat = ..., model_in_the_middle = TRUE)

# For each model release we run a "medium" thinking setting and, where the model
# supports turning reasoning off, a non-thinking setting. The mechanism differs
# by provider and generation:
#
# * Anthropic adaptive (Opus 4.6+, Sonnet 4.6): adaptive thinking + medium
#   effort. Omitting `thinking` disables reasoning.
# * Anthropic adaptive-default (Sonnet 5): adaptive thinking is on by default,
#   so omitting `thinking` does *not* disable it. The non-thinking setting must
#   pass `thinking = list(type = "disabled")` explicitly.
# * Anthropic extended (Opus 4.1/4.5, Sonnet 4.5, Haiku 4.5): these don't
#   support adaptive thinking, only extended thinking with a token budget. We
#   use 2000 tokens as a "medium" analogue. Omitting `thinking` disables it.
# * OpenAI: `reasoning_effort`. GPT-5.1+ accept "none" (truly off); the original
#   GPT-5 / GPT-5 nano have no true off setting, so we run those medium-only.
# * Gemini 3.x: `thinkingLevel`. "minimal" does not fully disable thinking, so
#   3.x models (which can't truly turn it off) run medium-only.
# * Gemini 2.5: `thinkingBudget`. Flash can disable with 0; Pro cannot, so Pro
#   runs medium-only.
#
# Models without a true non-thinking setting are run against the medium setting
# only, rather than a partial-reasoning analogue.

run <- function(name, solver_chat) {
  task <- tsk$clone()
  task$eval(solver_chat = solver_chat)
  save(task, file = file.path("inst/run/tasks", paste0("tsk_", name, ".rda")))
}

anthropic_adaptive <- function(model) {
  ellmer::chat_anthropic(
    model = model,
    api_args = list(
      thinking = list(type = "adaptive"),
      output_config = list(effort = "medium")
    )
  )
}

anthropic_extended <- function(model) {
  ellmer::chat_anthropic(
    model = model,
    params = ellmer::params(max_tokens = 8192),
    api_args = list(thinking = list(type = "enabled", budget_tokens = 2000))
  )
}

anthropic_plain <- function(model) {
  ellmer::chat_anthropic(model = model)
}

anthropic_disabled <- function(model) {
  ellmer::chat_anthropic(
    model = model,
    api_args = list(thinking = list(type = "disabled"))
  )
}

openai_effort <- function(model, effort) {
  ellmer::chat_openai(model = model, params = ellmer::params(reasoning_effort = effort))
}

gemini_level <- function(model, level) {
  ellmer::chat_google_gemini(
    model = model,
    api_args = list(generationConfig = list(thinkingConfig = list(thinkingLevel = level)))
  )
}

gemini_budget <- function(model, budget) {
  ellmer::chat_google_gemini(
    model = model,
    api_args = list(generationConfig = list(thinkingConfig = list(thinkingBudget = budget)))
  )
}

# Claude -------------------------------------------------------------------

run("opus_4_1_medium", anthropic_extended("claude-opus-4-1-20250805"))
run("opus_4_1_nonthinking", anthropic_plain("claude-opus-4-1-20250805"))

run("opus_4_5_medium", anthropic_extended("claude-opus-4-5-20251101"))
run("opus_4_5_nonthinking", anthropic_plain("claude-opus-4-5-20251101"))

run("opus_4_6_medium", anthropic_adaptive("claude-opus-4-6"))
run("opus_4_6_nonthinking", anthropic_plain("claude-opus-4-6"))

run("opus_4_7_medium", anthropic_adaptive("claude-opus-4-7"))
run("opus_4_7_nonthinking", anthropic_plain("claude-opus-4-7"))

run("opus_4_8_medium", anthropic_adaptive("claude-opus-4-8"))
run("opus_4_8_nonthinking", anthropic_plain("claude-opus-4-8"))

run("sonnet_4_5_medium", anthropic_extended("claude-sonnet-4-5-20250929"))
run("sonnet_4_5_nonthinking", anthropic_plain("claude-sonnet-4-5-20250929"))

run("sonnet_4_6_medium", anthropic_adaptive("claude-sonnet-4-6"))
run("sonnet_4_6_nonthinking", anthropic_plain("claude-sonnet-4-6"))

run("sonnet_5_medium", anthropic_adaptive("claude-sonnet-5"))
run("sonnet_5_nonthinking", anthropic_disabled("claude-sonnet-5"))

run("haiku_4_5_medium", anthropic_extended("claude-haiku-4-5-20251001"))
run("haiku_4_5_nonthinking", anthropic_plain("claude-haiku-4-5-20251001"))

# Fable 5 has adaptive thinking always on (no non-thinking setting).
run("claude_fable_5", anthropic_adaptive("claude-fable-5"))

# GPT ----------------------------------------------------------------------

# GPT-5 has no true non-thinking setting (its floor is "minimal").
run("gpt_5_medium", openai_effort("gpt-5", "medium"))

run("gpt_5_1_medium", openai_effort("gpt-5.1", "medium"))
run("gpt_5_1_nonthinking", openai_effort("gpt-5.1", "none"))

run("gpt_5_2_medium", openai_effort("gpt-5.2", "medium"))
run("gpt_5_2_nonthinking", openai_effort("gpt-5.2", "none"))

run("gpt_5_4_medium", openai_effort("gpt-5.4", "medium"))
run("gpt_5_4_nonthinking", openai_effort("gpt-5.4", "none"))

run("gpt_5_5_medium", openai_effort("gpt-5.5", "medium"))
run("gpt_5_5_nonthinking", openai_effort("gpt-5.5", "none"))

# GPT-5 nano has no true non-thinking setting (its floor is "minimal").
run("gpt_5_nano_medium", openai_effort("gpt-5-nano", "medium"))

run("gpt_5_4_nano_medium", openai_effort("gpt-5.4-nano", "medium"))
run("gpt_5_4_nano_nonthinking", openai_effort("gpt-5.4-nano", "none"))

# Gemini -------------------------------------------------------------------

# 2.5 Pro cannot disable thinking.
run("gemini_2_5_pro_medium", gemini_budget("gemini-2.5-pro", 2000))

run("gemini_2_5_flash_medium", gemini_budget("gemini-2.5-flash", 2000))
run("gemini_2_5_flash_nonthinking", gemini_budget("gemini-2.5-flash", 0))

# Gemini 3.x cannot fully disable thinking, so these run medium-only.
run("gemini_3_flash_medium", gemini_level("gemini-3-flash-preview", "medium"))
run("gemini_3_1_pro_medium", gemini_level("gemini-3.1-pro-preview", "medium"))
run("gemini_3_5_flash_medium", gemini_level("gemini-3.5-flash", "medium"))

# Gemma --------------------------------------------------------------------

gemma4_26b_a4b <-
  ellmer::chat_openai_compatible(
    base_url = paste0(Sys.getenv("GEMMA4_BASE_URL"), "/v1"),
    model = "google/gemma-4-26B-A4B-it",
    credentials = function() Sys.getenv("BASETEN_API_KEY")
  )

run("gemma4_26b_a4b", gemma4_26b_a4b)
