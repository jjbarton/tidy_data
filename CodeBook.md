The run_analysis.R script assumes that the working directory contains the "UCI HAR Dataset" folder.

A high level description of the scripts function is given below:

1. Load the raw data from the test and train folders. This raw data is pre-processed to contain subject IDs, activity names, and columns with measurement names. Only columns with standard deviation and mean measurements are included.
2. Combine the raw data from the test and train folders into a single data.frame.
3. Melt the combined data.frame into long form for easier analysis. This results in a data.frame with columns: subject.id, activity, measurement, statistic and value. The result of this is the long.data data.frame (details below)
4. Calculate average values of the mean and standard deviation for each subject / activity and measurement. The result of this is the averages data.frame (details below).
5. Write the file to disk.

long.data details

subject.id  - this is the numeric subject ID as provided in the initial test data.
activity    - this is a label describing the activity (e.g. WALKING, STANDING, ...)
measurement - this is the measurement observed, for example tBodyAcc-X, fBodyBodyGyroJerkMag
statistic   - this is the statistic taken, either mean or standard deviation
value       - this it the value of the given statistic

averages details

The columns in this table are the same as those in long.data, with the exception of the average column which replaces the value column. This column provides the average of the given statistic grouped by subject / activity / measurement.
