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

create_timediff_bar_chart <- function(
  timediff_tibble,
  subplot_title
) {
  ggplot(
    data = timediff_tibble,
    mapping = aes(x = bin, y = percent_in_bin)
  ) +
    geom_col() +
    labs(
      title = subplot_title,
      x = "Time difference in hours",
      y = "Count"
    ) +
    lims(y = c(0, 70)) +
    theme_minimal()
}
