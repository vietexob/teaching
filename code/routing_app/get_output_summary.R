extractTime <- function(subset.time=data.frame(), conversion.factor=1,
                        is.metric=TRUE) {
  ## To be used internally only. 1 mile = 1609.34 meter.
  time <- 0
  if(is.metric) {
    time <- sum(subset.time$seg.len / (subset.time$speed * conversion.factor))
  } else {
    time <- sum(subset.time$seg.len / (subset.time$speed * conversion.factor * 1609.34))
  }
  
  return(time)
}

getOutputSummary <- function(input.data=data.frame(), is.metric=TRUE) {
  ## Computes the output summary: statistics of wait and travel times of
  ## the routing algorithm for all customers.
  
  conversion.factor <- 1
  if(is.metric) {
    conversion.factor <- 1000 / 60
  } else {
    conversion.factor <- 1 / (60)
  }
  
  taxi.idx <- which(input.data$indicator == 'Taxi')
  start.idx <- which(input.data$indicator == 'Start')
  end.idx <- which(input.data$indicator == 'End')
  
  wait.times <- vector()
  if(length(taxi.idx) == length(start.idx)) {
    for(i in 1:length(taxi.idx)) {
      subset.wait <- input.data[taxi.idx[i]:start.idx[i], ]
      # wait.time <- extractTime(subset.wait, conversion.factor, is.metric)
      wait.time <- subset.wait$speed
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
        # wait.time <- extractTime(subset.wait, conversion.factor, is.metric)
        wait.time <- subset.wait$speed
        wait.times <- c(wait.times, wait.time)
      }
    }
  }
  
  travel.times <- vector()
  if(length(start.idx) == length(end.idx)) {
    for(i in 1:length(start.idx)) {
      subset.travel <- input.data[start.idx[i]:end.idx[i], ]
      # travel.time <- extractTime(subset.travel, conversion.factor, is.metric)
      travel.time <- subset.travel$speed
      travel.times <- c(travel.times, travel.time)
    }
  } else {
    stop(paste('# Starts =', length(start.idx), '; # Ends =', length(end.idx)))
  }
  
  output.summary <- data.frame(wait.time = wait.times, travel.time = travel.times)
  
  return(output.summary)
}
