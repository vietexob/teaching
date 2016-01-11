rm(list = ls())

## NOTE: This is currently not used for the routing app. ##

library(sp)

is.pgh <- TRUE
is.training <- TRUE

## Convert from data frame to spatial lines
if(is.pgh) {
  if(is.training) {
    filename <- './data/traffic/pgh_train_segment_speed_august.csv'
  } else {
    filename <- './data/traffic/pgh_test_segment_speed_august.csv'
  }
} else {
  if(is.training) {
    filename <- './data/traffic/was_train_segment_speed_august.csv'
  } else {
    filename <- './data/traffic/was_test_segment_speed_august.csv'
  }
}
input.data <- read.csv(file = filename, stringsAsFactors = FALSE)
begin.coord <- data.frame(lon = input.data$from.x, lat = input.data$from.y)
end.coord <- data.frame(lon = input.data$to.x, lat = input.data$to.y)

## Road attributes
street.name <- input.data$street.name
length <- round(input.data$length, 2)
mean.speed <- round(input.data$avg_speed, 2)
attribute.data <- data.frame(street.name = street.name, length = length,
                             mean.speed = mean.speed, stringsAsFactors = FALSE)

l <- vector("list", nrow(begin.coord))
for (i in seq_along(l)) {
  l[[i]] <- Lines(list(Line(rbind(begin.coord[i, ], end.coord[i,]))), as.character(i))
}
output <- SpatialLines(l)
final.output <- SpatialLinesDataFrame(output, data = attribute.data)

if(is.pgh) {
  if(is.training) {
    out.filename <- './code/routing_app/data/pgh_train_segment_speed_august.rds'
  } else {
    out.filename <- './code/routing_app/data/pgh_test_segment_speed_august.rds'
  }
} else {
  if(is.training) {
    out.filename <- './code/routing_app/data/was_train_segment_speed_august.rds'
  } else {
    out.filename <- './code/routing_app/data/was_test_segment_speed_august.rds'
  }
}
saveRDS(final.output, file = out.filename)
