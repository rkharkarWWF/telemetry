config <- new.env()
sys.source("config.R", envir = config)

utils <- new.env()
sys.source("utils.R", envir = utils)

library(readr)
library(purrr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(cowplot)

movement_data_grouped <- read_csv(
  file = config$telemetry_with_lulc,
  show_col_types = FALSE
) %>%
  mutate(lulc = factor(config$lulc_map[as.character(lulc)] %>% unlist())) %>%
  group_by(collar_id)

time_difference_bins <- movement_data_grouped %>%
  mutate(
    time_diff = as.numeric(difftime(
      time1 = timestamp,
      time2 = lag(timestamp),
      units = "hours"
    )),
    bin = cut(
      x = time_diff,
      breaks = config$histogram_bins
    )
  ) %>%
  filter(
    time_diff > 0.01
  )

#--------------------Plots for successive time diffs--------------------
summary_by_bin <- time_difference_bins %>%
  group_by(bin, .add = TRUE) %>%
  summarise(count_bin = n(), .groups = "drop_last") %>%
  mutate(
    percent_in_bin = (count_bin / sum(count_bin)) * 100
  )
max_percentage <- ceiling(max(summary_by_bin$percent_in_bin))

summary_by_bin <- summary_by_bin %>%
  nest() %>%
  mutate(
    plots = map2(data, collar_id, ~ utils$create_timediff_bar_chart(
      timediff_tibble = .x,
      subplot_title = sub(pattern = "\\:.*", "", .y),
      tick_labels = config$histogram_bins,
      ymax_value = max_percentage
    ))
  )

timediff_plot <- cowplot::plot_grid(
  plotlist = summary_by_bin$plots,
  ncol = 2
)
ggsave(
  filename = config$timediffs_binned,
  plot = timediff_plot,
  bg = "white"
)

#--------------------Plots for time diffs by lulc--------------------
summary_by_bin_lulc <- time_difference_bins %>%
  group_by(bin, lulc, .add = TRUE) %>%
  summarise(count_bin = n(), .groups = "drop") %>%
  group_by(collar_id) %>%
  mutate(
    percent_in_bin = (count_bin / sum(count_bin)) * 100
  ) %>%
  nest() %>%
  mutate(
    plots = map2(data, collar_id, ~ utils$create_timediff_bar_chart(
      timediff_tibble = .x,
      subplot_title = sub(pattern = "\\:.*", "", .y),
      tick_labels = config$histogram_bins,
      ymax_value = max_percentage,
      stacked = TRUE
    ))
  )

timediff_lulc_plot <- cowplot::plot_grid(
  plotlist = summary_by_bin_lulc$plots,
  ncol = 2
)
ggsave(
  filename = config$timediffs_lulc_binned,
  plot = timediff_lulc_plot,
  bg = "white"
)
