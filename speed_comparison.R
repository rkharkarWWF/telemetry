config <- new.env()
sys.source("config.R", envir = config)

utils <- new.env()
sys.source("utils.R", envir = utils)

library(raster)
library(readr)
library(dplyr)
library(purrr)
library(sf)
library(lubridate)
library(ggplot2)

lulc <- raster::raster(config$lulc_file)

movement_data_sf_grouped <- read_csv(
  file = config$telemetry_with_lulc,
  show_col_types = FALSE
) %>%
  st_as_sf(
    coords = c("longitude", "latitude"),
    crs = 4326
  ) %>%
  st_transform(crs = st_crs(lulc)) %>%
  group_by(collar_id)

time_and_dist_diffs <- movement_data_sf_grouped %>%
  mutate(
    time_diff = as.numeric(difftime(
      time1 = timestamp,
      time2 = lag(timestamp),
      unit = "secs"
    )),
    displacement = st_distance(
      x = geometry,
      y = lag(geometry),
      by_element = TRUE
    ),
    velocity = displacement / time_diff,
    month = month(timestamp_IST)
  )

velocity_mean_by_month <- time_and_dist_diffs %>%
  group_by(month, .add = TRUE) %>%
  summarise(average = mean(velocity), .groups = "drop_last")

plots <- velocity_mean_by_month %>%
  nest() %>%
  mutate(plots = map(
    data,
    ~
      ggplot(data = .x, mapping = aes(x = month, y = as.numeric(average))) +
        geom_col()
  ))
