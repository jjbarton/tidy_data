
library(reshape2)
library(stringr)
library(plyr)

# This script assumes the working directory has a subfolder "UCI HAR Dataset" which contains the extracted
# test data.

# This function loads a set of raw data, adds column names from the features 
# parameter, and adds activity names from the activities parameter.
loadRawData <- function(path,               # the path containing the test data (e.g. UCI HAR Dataset/test)
                        raw.data.filename,  # the name of the raw data file
                        activity.filename,  # the name of the file containing activity ids
                        subject.filename,   # the name of the file containing subject ids
                        features,           # data.frame containing feature ids/values (the measurements)
                        activities)         # data.frame mapping activity ids to names
{
  # Load the raw data, and apply the feature column names
  raw.data <- read.table(file.path(path, raw.data.filename))
  colnames(raw.data) <- features$feature
  
  # Remove all columns which are not mean or standard deviation measurements
  # N.B. this includes columns with form mean()-X and mean()-Y
  relevant.columns <- grep("*-mean\\(\\)-*|*-std\\(\\)-*", colnames(raw.data))  
  raw.data <- raw.data[, relevant.columns]
    
  # Add a subject ID column
  subject.data <- read.table(file.path(path, subject.filename))
  raw.data$subject.id <- subject.data[, 1]

  # Add a activity ID column
  activity.data <- read.table(file.path(path, activity.filename))
  raw.data$activity.id <- activity.data[, 1]
  
  # Add an activity label
  # using match rather than merge to preserve ordering
  raw.data$activity = activities[match(raw.data$activity.id, activities$activity.id), ]$activity
  raw.data$activity.id <- NULL
  
  return(raw.data)
}

# Define paths
base.path <- "./UCI HAR Dataset"
test.path <- file.path(base.path, "test")
train.path <- file.path(base.path, "train")

# Load activity labels, giving appropriate columns
activities <- read.table(file.path(base.path, "activity_labels.txt"))
colnames(activities) <- c("activity.id", "activity")

# Load feature labels, giving appropriate columns
features <- read.table(file.path(base.path, "features.txt"))
colnames(features) <- c("feature.id", "feature")

# Load the test and train data separately, then combine
test.raw.data <- loadRawData(test.path, "X_test.txt", "y_test.txt", "subject_test.txt", features, activities)
train.raw.data <- loadRawData(train.path, "X_train.txt", "y_train.txt", "subject_train.txt", features, activities)
raw.data <- rbind(test.raw.data, train.raw.data)

# Pull out the measurement (e.g. tBody-Acc-X) and the statistic taken (mean / std) into separate columns
# for easier analysis
long.data <- melt(raw.data, id.vars = c("subject.id", "activity"))
long.data$measurement <- sub("-(mean|std)\\(\\)", "", long.data$variable)
long.data$statistic <- gsub("-|\\(|\\)", "", str_extract(long.data$variable, "-(mean|std)\\(\\)"))
long.data$variable <- NULL

# Re-order columns
long.data <- long.data[, c("subject.id", "activity", "measurement", "statistic", "value")]

# Now calculate the average of the statistics for each subject / activity / measurement.
# Assumption: task is to provide average of means and average of standard deviations measurements.
# assignment does not specify this clearly.
averages <- ddply(long.data, 
                  c("subject.id", "activity", "measurement", "statistic"), 
                  summarise, 
                  average = mean(value))

# Write the averages to disk as a text file (as specified)
write.table(averages, "./averages.txt", row.names = FALSE)

                       
