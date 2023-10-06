library(sf)
library(dplyr)
library(stringr)
library(lubridate)

years <-  c('2022', '2022', '2023', '2023', '2022', '2023')

polys <- read_sf('/home/hrodenhizer/Documents/permafrost_pathways/rts_mapping/rts_dataset/rts_dataset_test_polygons.shp')

polys <- polys |>
  bind_cols(st_coordinates(st_centroid(polys))) |>
  rename(CentroidLat = X, CentroidLon = Y) |>
  mutate(RegionName = 'Yamal-Gydan',
         CreatorLab = 'Rodenhizer',
         BaseMapDate = paste0('01-05-', years, ',30-09-', years),
         BaseMapSource = 'WorldView-2',
         `BaseMapResolution(m)` = 4) |>
  select(id, 
         CentroidLat, 
         CentroidLon, 
         RegionName, 
         CreatorLab,
         ContrDate, 
         BaseMapDate, 
         BaseMapSource, 
         `BaseMapResolution(m)`)

current_data <- polys |>
  filter(ContrDate == as_date('2023-09-01'))

new_data <- polys |>
  filter(ContrDate == as_date('2023-09-28'))

write_sf(current_data,
         '/home/hrodenhizer/Documents/permafrost_pathways/rts_mapping/rts_dataset/rts_dataset_test_polygons_current.shp')

write_sf(new_data,
         '/home/hrodenhizer/Documents/permafrost_pathways/rts_mapping/rts_dataset/rts_dataset_test_polygons_new.shp')
