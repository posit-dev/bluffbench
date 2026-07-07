This is an R package implementing an LLM evaluation that tests language models' ability to accurately interpret visualizations with counterintuitive data. Models are given a tool to create ggplots from secretly modified datasets and must describe what they observe. The eval measures whether models report the actual plotted patterns even when they contradict expectations.

## Related documentation

Future AI assistants should read the help pages for the following R functions:

* `ellmer::Chat()`
* `ellmer::Turn()`
* `ellmer::tool()`
* `vitals::Task()`

Also, read all of the files in R/.

## Package structure

The package exports four main objects:

- `bluff_dataset`: A tibble with `id`, `input` (list-column with `prompt`/`setup`/`teardown`), and `target` columns. Generated from YAML files in `data-raw/samples/`.
- `bluff_solver`: Takes inputs, runs setup code, gives model `create_ggplot` tool, runs teardown code, returns explanations.
- `bluff_scorer`: Checks if solver called `create_ggplot` successfully, then uses LLM judge to grade explanation against target. Returns factor scores (I/C).
- `bluff_task`: Combines dataset, solver, scorer into `vitals::Task`.

The solver runs setup, registers `tool_create_ggplot`, prompts model, runs teardown.

The scorer first checks turns for `ContentToolResult` with `request@name == "create_ggplot"` and `error == NULL`. If found, sends explanation to LLM judge using `bluff_format_prompt` and `bluff_instructions`. Judge is told counterintuitive observations are valid if accurately stated.

The `tool_create_ggplot` is defined as an `ellmer::tool` with name `"create_ggplot"` and description focused on creating ggplot objects, intentionally narrow to discourage data exploration.

Samples are defined in yaml:

- `id`: unique identifier matching filename
- `input.setup`: R code that modifies a dataset in global environment
- `input.teardown`: R code that removes the dataset (`rm(dataset_name)`)
- `input.prompt`: Natural instruction to create and describe a plot
- `target`: Description of transformation and what correct answer should state

When writing sample YAML files, keep row counts and values intact, only relabel or reorder to create misconceptions. Do not mention the perturbation in the prompt.

## How to run the eval with a new model

The run harness lives in `inst/run/run_eval.R`. It builds `tsk <- bluff_task(epochs = 3)` once, then calls `run(name, solver_chat)` per model/setting, which clones the task, evaluates it against the given `ellmer` chat, and saves the fitted task to `inst/run/tasks/tsk_<name>.rda`. Logs land in `inst/run/logs/`.

For each model release we run a `medium` thinking setting and, where the model supports turning reasoning off, a `nonthinking` setting. The mechanism differs by provider and generation. `run_eval.R` has some small helpers per mechanism (`anthropic_adaptive`, `anthropic_extended`, `anthropic_plain`, `anthropic_disabled`, `openai_effort`, `gemini_level`, `gemini_budget`), but don't assume they will work for a new model release; before running a full eval against an unfamiliar model, spot-check the thinking setting with `ellmer` directly:

```r
library(ellmer)
prompt <- "A rope over a pulley has a weight on one end and a monkey of equal weight on the other, balanced. The monkey climbs. What happens to the weight?"

chat_thinking$get_tokens()$output
chat_nonthinking$get_tokens()$output
```

Thinking tokens count as output, so on a reasoning-heavy prompt the adaptive variant should report meaningfully more output tokens than the disabled one. 

Steps to add a model:

1. Add `run("<name>_medium", ...)` and, if applicable, `run("<name>_nonthinking", ...)` lines to `inst/run/run_eval.R`, using the helper matching its thinking mechanism.
2. Add a row per setting to `data-raw/model_metadata.csv` (`task_name`, `lab`, `release_date`, `release_date_source`).
3. Add a `case_when` arm per setting in `data-raw/bluff_results.R` mapping the task name to a display label (`"... (medium)"` / `"... (non-thinking)"`).
4. Run the new `run(...)` lines (from the package root, so the relative `inst/run/...` paths resolve).
5. Regenerate the package data by sourcing `data-raw/bluff_results.R`, which reads every `inst/run/tasks/*.rda`, joins costs and metadata, and writes `data/bluff_results.rda`.

## Website

Rather than a pkgdown website, the package uses an `index.qmd` and `_quarto.yml` to knit to `docs/`. 
