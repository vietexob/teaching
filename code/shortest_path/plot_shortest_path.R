rm(list = ls())

library(ggplot2)

source('./code/util/plotSegments.R')

## Central coordinates for Singapore
sin.lon <- 103.819836
sin.lat <- 1.352083

filename <- './data/instances/sin_shortest_path.csv'
segment.data <- read.csv(file = filename, header = FALSE, stringsAsFactors = FALSE)
names(segment.data) <- c('indicator', 'from.x', 'from.y', 'to.x', 'to.y')
## Get the number of instances
N <- as.numeric(table(segment.data$indicator)['Start'])
start.idx <- which(segment.data$indicator == 'Start')
end.idx <- which(segment.data$indicator == 'End')

# for(i in 1:N) {
#   start.index <- start.idx[i]
#   end.index <- end.idx[i]
#   subset.segment <- segment.data[start.index:end.index, ]
#   head(subset.segment)
# }

aesStr <- aes_string(x = 'from.x', y = 'from.y', xend = 'to.x', yend = 'to.y')
out.filename <- './figures/shortest_paths/sin_shortest_path.png'
plotSegments(mean_lon = sin.lon, mean_lat = sin.lat, segment_data = segment.data,
             aesStr = aesStr, lwd = 1, titleStr = 'Shortest Paths',
             out_filename = out.filename)
