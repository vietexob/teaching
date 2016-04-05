extractTime <- function(subset.time=data.frame(), conversion.factor=1,
                        is.metric=TRUE) {
  ## To be used internally only. 1 mile = 1609.34 meter.
  time <- 0
#   if(is.metric) {
#     time <- sum(subset.time$seg.len / (subset.time$speed * conversion.factor))
#   } else {
#     time <- sum(subset.time$seg.len / (subset.time$speed * conversion.factor * 1609.34))
#   }
  time <- sum(subset.time$travel_time)
  
  return(time)
}

getOutputSummary <- function(input.data=data.frame(), is.metric=TRUE,
                             is.scheduling = FALSE) {
  ## Computes the output summary: statistics of wait and travel times of
  ## the routing algorithm for all customers.
  
  conversion.factor <- 1
  if(is.metric) {
    conversion.factor <- 1000 / 60
  } else {
    conversion.factor <- 1 / (60)
  }
  
  wait.times <- vector()
  travel.times <- vector()
  output.summary <- NULL
  
  if(is.scheduling) {
    max.taxi.no <- max(input.data$taxi)
    for(taxi.no in 1:max.taxi.no) {
      subset.taxi <- subset(input.data, taxi == taxi.no)
      if(nrow(subset.taxi) > 0) {
        taxi.idx <- which(subset.taxi$indicator == 'Taxi')
        start.idx <- which(subset.taxi$indicator == 'Start')
        end.idx <- which(subset.taxi$indicator == 'End')
        
        cumulative.wait <- 0
        if(length(start.idx) > 0 && length(end.idx) > 0) {
          if(length(taxi.idx) == length(start.idx) && length(start.idx) == length(end.idx)) {
            for(i in 1:length(taxi.idx)) {
              subset.wait <- subset.taxi[taxi.idx[i]:start.idx[i], ]
              wait.time <- extractTime(subset.wait, conversion.factor, is.metric)
              wait.time <- wait.time + cumulative.wait
              pickup.time <- subset.taxi$time[start.idx[i]]
              if(is.na(pickup.time)) {
                stop('Error: Pickup time is NA!')
              }
              real.wait.time <- max(0, wait.time - pickup.time)
              wait.times <- c(wait.times, real.wait.time)
              
              subset.travel <- subset.taxi[start.idx[i]:end.idx[i], ]
              travel.time <- extractTime(subset.travel, conversion.factor, is.metric)
              travel.times <- c(travel.times, travel.time)
              cumulative.wait <- cumulative.wait + wait.time + travel.time
            }
          } else {
            stop('Number of taxi.idx, start.idx, and end.idx must be equal.')
          }
        }
      }
    }
  } else {
    taxi.idx <- which(input.data$indicator == 'Taxi')
    start.idx <- which(input.data$indicator == 'Start')
    end.idx <- which(input.data$indicator == 'End')
    
    if(length(taxi.idx) == length(start.idx)) {
      for(i in 1:length(taxi.idx)) {
        subset.wait <- input.data[taxi.idx[i]:start.idx[i], ]
        wait.time <- extractTime(subset.wait, conversion.factor, is.metric)
        wait.times <- c(wait.times, wait.time)
      }
    } else {
      non.trans.idx <- which(input.data$indicator != 'Trans')
      taxi.start.idx <- setdiff(non.trans.idx, end.idx)
      taxi.index <- NULL
      for(index in taxi.start.idx) {
        if(index %in% taxi.idx) {
          taxi.index <- index
        } else {
          subset.wait <- input.data[taxi.index:index, ]
          wait.time <- extractTime(subset.wait, conversion.factor, is.metric)
          wait.times <- c(wait.times, wait.time)
        }
      }
    }
    
    if(length(start.idx) == length(end.idx)) {
      for(i in 1:length(start.idx)) {
        subset.travel <- input.data[start.idx[i]:end.idx[i], ]
        travel.time <- extractTime(subset.travel, conversion.factor, is.metric)
        travel.times <- c(travel.times, travel.time)
      }
    } else {
      stop(paste('# Starts =', length(start.idx), '; # Ends =', length(end.idx)))
    }
  }
  
  output.summary <- data.frame(wait.time = wait.times, travel.time = travel.times)
  
  return(output.summary)
}
