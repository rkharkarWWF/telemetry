telemetry_files <- list(
  "data/Budhuni_21102024.csv",
  "data/Mynow_21102024.csv",
  "data/Phul_21102024.csv",
  "data/Tara_21102024.csv"
)
lulc_file <- "data/NBL LULC.tif"
telemetry_with_lulc <- "data/telemetry_with_lulc.csv"

timediffs_binned <- "images/timediffs_hist.png"
timediffs_lulc_binned <- "images/timediffs_lulc_hist.png"

colnames_map <- c(
  collar_id = "Collar ID",
  timestamp = "Timestamp UTC",
  timestamp_IST = "Timestamp IST",
  latitude = "Latitude",
  longitude = "Longitude",
  type = "Type",
  temperature = "Temperature C",
  altitude = "Altitude m",
  accelerometer = "Accelerometer"
)
histogram_bins <- c(0, 0.5, 1, 2, 5, 12, 24, 168, Inf)
lulc_map <- list(
  "1" = "Water",
  "2" = "Forest",
  "5" = "Cropland",
  "7" = "Built-up",
  "8" = "Sandbank",
  "11" = "Rangeland",
  "100" = "Tea plantation"
)
lulc_colormap <- c(
  "Water" = "#3FDCE3",
  "Forest" = "#0B5606",
  "Cropland" = "#6B8531",
  "Built-up" = "#000000",
  "Sandbank" = "#D3CE21",
  "Rangeland" = "#85F90A",
  "Tea plantation" = "#448708"
)
