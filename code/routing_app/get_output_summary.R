getOutputSummary <- function(input.data=data.frame(), is.metric=TRUE) {
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
      if(is.metric) {
        wait.time <- sum(subset.wait$seg.len / (subset.wait$speed * conversion.factor))
      } else {
        wait.time <- sum(subset.wait$seg.len / (subset.wait$speed * conversion.factor * 1609.34))
      }
      wait.times <- c(wait.times, wait.time)
    }
  } else {
    stop(paste('# Taxis =', length(taxi.idx), '; # Starts =', length(start.idx)))
  }
  
  travel.times <- vector()
  if(length(start.idx) == length(end.idx)) {
    for(i in 1:length(start.idx)) {
      subset.travel <- input.data[start.idx[i]:end.idx[i], ]
      if(is.metric) {
        travel.time <- sum(subset.travel$seg.len / (subset.travel$speed * conversion.factor))
      } else {
        travel.time <- sum(subset.travel$seg.len / (subset.travel$speed * conversion.factor * 1609.34))
      }
      
      travel.times <- c(travel.times, travel.time)
    }
  } else {
    stop(paste('# Starts =', length(start.idx), '; # Ends =', length(end.idx)))
  }
  
  output.summary <- data.frame(wait.time = wait.times, travel.time = travel.times)
  return(output.summary)
}
