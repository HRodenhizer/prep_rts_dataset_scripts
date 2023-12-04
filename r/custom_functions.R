# add_empty_columns
add_empty_columns <- function(df, column_names) {
  for (name in column_names) {
    if (!name %in% colnames(df)) {
      df <- df |>
        mutate(!!!setNames(NA, name))
    }
  }
  return(df)
}

# check_intersection_info
check_intersection_info <- function(df) {
  
  duplicated_UIDs <- df |>
    as_tibble() |>
    select(UID) |>
    summarise(count = n(),
              .by = UID) |>
    filter(count > 1) |>
    pull(UID)
  
  int_info_complete <- df |>
    mutate(
      int_info_complete = case_when(
        (
          is.na(Intersections) | str_length(Intersections)==0
        ) & str_length(SelfIntersectionIndices) == 0 ~ TRUE,
        !is.na(Intersections) & (!is.na(RepeatRTS) | !is.na(MergedRTS) | !is.na(StabilizedRTS) | !is.na(AccidentalOverlap)) ~ TRUE,
        str_length(SelfIntersectionIndices) > 0 & UID %in% duplicated_UIDs ~ TRUE,
        TRUE ~ FALSE
      )
    )
  if (!all(int_info_complete$int_info_complete)) {
    
    incomplete_info <- int_info_complete |>
      filter(int_info_complete == FALSE)
    
    st_write(incomplete_info, paste(
      'r_output',
      paste0(str_split(new_data_file, '\\.')[[1]][1],
             '_incomplete_information.geojson'),
      sep = '/'), 
      append = FALSE)
    
    print(
      incomplete_info
    )
    
    stop(
      paste0(
        'Incomplete information provided about intersecting RTS polygons. Please complete information for rows printed above. This file has also been saved to ', paste(
          'r_output',
          paste0(str_split(new_data_file, '\\.')[[1]][1],
                 '_incomplete_information.geojson'),
          sep = '/')),
      ', so that you can determine the problem in your preferred GIS software.'
    )
  }
  
  print('Intersection information is complete.')
  
}

# get_earliest_uid
# Return `UID` from feature with earliest `BaseMapDate` for features in `new_data` that overlap eachother.
get_earliest_uid <- function(df, index_col, self_intersections_col) {
  
  indices <- c(index_col,
               as.numeric(split_string_to_vector(self_intersections_col)))
  
  return(
    df |>
      slice(indices) |>
      filter(BaseMapDate == min(BaseMapDate)) |>
      pull(UID)
  )
  
}

# get_uids_by_index_string
get_uids_by_index_string <- function(index_string, df) {
  str_flatten(df |>
                slice(as.numeric(
                  str_split(index_string, ',') |>
                    pluck(1))
                ) |>
                pull(UID) |>
                unique(),
              collapse = ',')
}

# remove_adjacent_polys
remove_adjacent_polys <- function(intersections, adjacent_polys) {
  intersections <- str_split(intersections, ',')
  adjacent_polys <- str_split(adjacent_polys, ',')
  
  intersections <- map2(intersections,
                        adjacent_polys,
                        ~ str_flatten(.x[which(!.x %in% .y)], collapse = ','))
  
  return(intersections)
  
}

# run_formatting_checks
check_lat <- function(lat) {
  
  correct_type <- class(lat) == 'numeric'
  missing_values <- any(is.na(lat))
  reasonable_values <- all(lat >= -90 & lat <= 90)
  
  if (!correct_type) {
    stop('The CentroidLat column is not numeric. Ensure that latitude is reported as decimal degress in WGS 84.')
  } else if (missing_values) {
    stop('The CentroidLat column is missing values.')
  } else if (!reasonable_values) {
    stop('Unexpected values found in the CentroidLat column. Ensure that CentroidLat is listed as decimal degress in WGS 84.')
  }
}

check_lon <- function(lon) {
  
  correct_type <- class(lon) == 'numeric'
  missing_values <- any(is.na(lon))
  reasonable_values <- all(lon >= -180 & lon <= 180)
  
  if (!correct_type) {
    stop('The CentroidLon column is not numeric. Ensure that longitude is listed as decimal degress in WGS 84.')
  } else if (missing_values) {
    stop('The CentroidLon column is missing values.')
  } else if (!reasonable_values) {
    stop('Unexpected values found in the CentroidLon column. Ensure that CentroidLon is listed as decimal degress in WGS 84.')
  }
}

check_region <- function(region) {
  
  correct_type <- class(region) == 'character'
  missing_values <- any(is.na(region))
  
  if (!correct_type) {
    stop('The RegionName column is not a string.')
  } else if (missing_values) {
    stop('The RegionName column is missing values.')
  }
}

check_creator <- function(creator) {
  
  correct_type <- class(creator) == 'character'
  missing_values <- any(is.na(creator))
  
  if (!correct_type) {
    stop('The CreatorName column is not a string.')
  } else if (missing_values) {
    stop('The CreatorName column is missing values.')
  }
}

check_basemap_date <- function(basemap_date) {
  
  correct_type <- all(
    as.logical(
      map(
        basemap_date |>
          str_split(pattern = ','),
        ~ class(
          .x |>
            ymd()
        ) == 'Date'
      )
    )
  )
  missing_values <- any(is.na(basemap_date))
  
  if (!correct_type) {
    stop('The BaseMapDate column does not contain dates (or they are improperly formatted).')
  } else if (missing_values) {
    stop('The BaseMapDate column is missing values.')
  }
}

check_source <- function(source) {
  
  correct_type <- class(source) == 'character'
  missing_values <- any(is.na(source))
  
  if (!correct_type) {
    stop('The BaseMapSource column is not a string.')
  } else if (missing_values) {
    stop('The BaseMapSource column is missing values.')
  }
}

check_resolution <- function(resolution) {
  
  correct_type <- class(resolution) == 'numeric'
  missing_values <- any(is.na(resolution))
  
  if (!correct_type) {
    stop('The BaseMapResolution column is not numeric.')
  } else if (missing_values) {
    stop('The BaseMapResolution column is missing values.')
  }
}

check_train_class <- function(train_class) {
  
  correct_type <- class(train_class) == 'character'
  missing_values <- any(is.na(train_class))
  
  if (!correct_type) {
    stop('The TrainClass column is not a string.')
  } else if (missing_values) {
    stop('The TrainClass column is missing values.')
  }
}

run_formatting_checks <- function(df) {
  check_lat(df$CentroidLat)
  check_lon(df$CentroidLon)
  check_region(df$RegionName)
  check_creator(df$CreatorLab)
  check_basemap_date(df$BaseMapDate)
  check_source(df$BaseMapSource)
  check_resolution(df$BaseMapResolution)
  check_train_class(df$TrainClass)
  
  print('Formatting looks good!')
}

# split_string_to_vector
split_string_to_vector <- function(UID_string) {
  UID_string |>
    str_split(',') |>
    pluck(1)
}