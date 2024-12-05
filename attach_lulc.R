config <- new.env()
sys.source("config.R", envir = config)

utils <- new.env()
sys.source("utils.R", envir = utils)

library(raster)
library(sf)

lulc <- raster::raster(config$lulc_file)
telemetry_data <- utils$read_data_files(
  config$telemetry_files,
  config$colnames_map
)

telemetry_sf <- st_as_sf(
  telemetry_data,
  coords = c("longitude", "latitude"),
  crs = 4326
) %>%
  st_transform(crs = st_crs(crs(lulc)))

coordinates <- st_coordinates(x = telemetry_sf)
telemetry_data$lulc <- raster::extract(lulc, coordinates)
write_csv(x = telemetry_data, file = config$telemetry_with_lulc)
