# Install packages
#install.packages("hazer")
#install.packages("jpeg")

# Load packages
library(hazer)
library(jpeg)

# Set input (camera) for function
# This needs to be a folder of .jpgs in your working directory
camera <- 'test_camera1'

# Function that takes in a jpg an outputs haze degree and classification
# User can also define the threshold for classifying fog and no-fog
fog_function <- function(camera,threshold=0.4) {

  # perform concatenation
  folder <- paste('./', camera, sep ='')
  
  # call all files that are jpg
  files <- list.files(path=folder, pattern='.jpg')
  
  # create data frame with 0 rows and 3 columns
  df <- data.frame(matrix(ncol = 3, nrow = 0))

  # provide column names
  colnames(df) <- c('timestamp', 'haze_degree', 'fog')
  
  # start loop for all jpgs
  for (i in files){
    
    # perform concatenation
    image <- paste('./', camera,'/', i , sep ='')
    
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

    # remove jpg from the name
    i <- substr(i,1,nchar(i)-4)

    # append the new image data to a new row
    df[nrow(df) + 1,] = c(i, haze_degree, fog)
  }
  
  # perform concatenation for output
  output <- paste('./output/rhazer_', camera,'.csv', sep ='')

  # save the data to a csv file
  write.csv(df,output, row.names = FALSE)
  return()
}

fog_function(camera)
