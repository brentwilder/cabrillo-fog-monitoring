# Install packages
#install.packages("hazer")
#install.packages("jpeg")

# Load packages
library(hazer)
library(jpeg)

# Set input for function
# Depending on file structure... it could  be something like,
# taking in all recent files loopning through in a function on a schedule (i.e., taskscheduleR)
# Then, output the spatial/temporal information to a running csv database
# Finally, should create a working UI that activley reads the csv and outputs to a cool web GIS platform
image <- "test.jpg"

# Function that takes in a jpg an outputs haze degree and classification
# User can also define the threshold for classifying fog and no-fog
fog_function <- function(image,threshold=0.4) {

  # read the image as an array
  rgb_array <- jpeg::readJPEG(image)

  # extracting the haze matrix
  haze_matrix <- getHazeFactor(rgb_array)
  haze_degree <- haze_matrix[c('haze')] 
  if(haze_degree > threshold){
    fog <- 1
  } else {
    fog <- 0
  }

  return(list(haze_degree,fog))

}

print(fog_function(image))




