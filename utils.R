library(readr)
library(purrr)
library(lubridate)
library(dplyr)
library(ggplot2)

pre_process_input <- function(tibble_list, colnames_map) {
  tibble_list %>%
    rename(any_of(colnames_map)) %>%
    mutate(
      altitude = as.numeric(ifelse(altitude == "(-)", NA, altitude)),
      timestamp_IST = force_tz(timestamp_IST, "Asia/Kolkata")
    ) %>%
    arrange(timestamp)
}

read_data_files <- function(filepath_list, colnames_map) {
  filepath_list %>%
    map(~ as_tibble(read_csv(.x, show_col_types = FALSE))) %>%
    map(~ pre_process_input(., colnames_map)) %>%
    bind_rows()
}

create_timediff_bar_chart <- function(
  timediff_tibble,
  subplot_title,
  tick_labels,
  ymax_value,
  stacked = NULL,
  colormap = NULL
) {
  plot_geom <- geom_col()
  plot_mapping <- aes(x = bin, y = percent_in_bin)
  if (!is.null(stacked) == TRUE) {
    plot_geom <- geom_col(position = "stack")
    plot_mapping <- aes(x = bin, y = percent_in_bin, fill = lulc)
  }

  scale_fill <- NULL
  if (!is.null(colormap)) {
    scale_fill <- scale_fill_manual(values = colormap)
  }

  ggplot(
    data = timediff_tibble,
    mapping = plot_mapping
  ) +
    plot_geom +
    labs(
      title = subplot_title,
      x = "Time difference in hours",
      y = "Count"
    ) +
    lims(y = c(0, ymax_value)) +
    scale_x_discrete(labels = tick_labels) +
    scale_fill +
    theme_minimal()
}
