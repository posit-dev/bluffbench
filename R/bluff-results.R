#' Bluffbench results
#'
#' @description
#' The bluffbench results contain evaluation scores from running language models
#' on the bluffbench dataset. Each row represents one model's response to one
#' sample, showing whether the model correctly interpreted the counterintuitive
#' visualization.
#'
#' The dataset is a tibble with one row per model-sample-epoch combination,
#' containing:
#' * `model`: The name of the language model evaluated, including the thinking
#'   mode in parentheses (e.g. "Claude Opus 4.8 (medium)").
#' * `id`: Unique identifier for the sample (matches `bluff_dataset$id`).
#' * `epoch`: The evaluation epoch (each model-sample pair is evaluated 3 times).
#' * `score`: An ordered factor indicating whether the model's explanation was
#'   Correct (C) or Incorrect (I). A correct score means the model accurately
#'   described the actual plotted pattern, even when it contradicted expectations.
#' * `type`: The sample type: "baseline", "intuitive", or "mocked".
#' * `thinking`: Logical; `TRUE` for models run with medium thinking effort,
#'   `FALSE` for non-thinking variants.
#' * `cost`: Total solver cost in USD for running the full evaluation
#'   (all samples, all epochs) for this model variant. Derived from token usage
#'   and per-model pricing. The same value is repeated across all rows for a
#'   given model.
#' * `lab`: The organization that developed the model: "Anthropic", "OpenAI",
#'   or "Google".
#' * `release_date`: The date the model was publicly released, as a [Date].
#' * `release_date_source`: A URL citing the source for the release date.
#'
#' @format A tibble with columns `model`, `id`, `epoch`, `score`, `type`,
#'   `thinking`, `cost`, `lab`, `release_date`, and `release_date_source`.
"bluff_results"

# See usage in bluff_results.R
process_results <- function() {
  task_files <- list.files("inst/run/tasks", full.names = TRUE)

  load_object <- function(file) {
    tmp <- new.env()
    load(file = file, envir = tmp)
    tmp[[ls(tmp)[1]]]
  }

  tasks <- list()
  for (task in task_files) {
    tasks[[gsub(".rda", "", basename(task))]] <- load_object(task)
  }
  names(tasks) <- gsub("tsk_", "", names(tasks))

  vitals::vitals_bind(!!!tasks)
}
