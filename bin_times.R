config <- new.env()
sys.source("config.R", envir = config)

utils <- new.env()
sys.source("utils.R", envir = utils)

library(purrr)
library(readr)
library(tibble)
library(ggplot2)
library(gridExtra)

movement_data_grouped <- config$import_files %>%
  map(~ as_tibble(read_csv(.x, show_col_types = FALSE))) %>%
  map(~ utils$pre_process_input(., config$colnames_map)) %>%
  bind_rows() %>%
  group_by(collar_id)

breakpoints <- c(0, 0.5, 1, 2, 5, 12, 24, 168, Inf)

time_difference_bins <- movement_data_grouped %>%
  mutate(
    time_diff = as.numeric(difftime(
      time1 = timestamp,
      time2 = lag(timestamp),
      units = "hours"
    )),
    bin = cut(
      x = time_diff,
      breaks = breakpoints
    )
  ) %>%
  group_by(bin, .add = TRUE) %>%
  summarise(count_bin = n(), .groups = "drop_last") %>%
  mutate(
    percent_in_bin = (count_bin / sum(count_bin)) * 100
  )

time_difference_bins <- time_difference_bins %>%
  nest() %>%
  mutate(
    plots = map2(data, collar_id, ~ utils$create_timediff_bar_chart(
      timediff_tibble = .x,
      subplot_title = sub(pattern = "\\:.*", "", .y)
    ))
  )

grid.arrange(grobs = time_difference_bins$plots, ncol = 2)
