rm(list = ls())

library(ggplot2)

source('./code/util/plotSegments.R')

## Central coordinates for Singapore
sin.lon <- 103.819836
sin.lat <- 1.352083

segment.data <- read.csv(file = './data/output/shortest_path_6023_15189.csv', header = FALSE,
                         stringsAsFactors = FALSE)
names(segment.data) <- c('seg_id', 'from.x', 'from.y', 'to.x', 'to.y', 'seg_name',
                         'seg_len', 'max_speed')

aesStr <- aes_string(x = 'from.x', y = 'from.y', xend = 'to.x', yend = 'to.y')
out.filename <- './figures/shortest_paths/test.png'
plotSegments(mean_lon = sin.lon, mean_lat = sin.lat, segment_data = segment.data,
             aesStr = aesStr, lwd = 1, titleStr = 'Shortest Paths',
             out_filename = out.filename)
