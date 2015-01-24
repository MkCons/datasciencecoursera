####################################
###########run_analysis.R###########
####################################

## Load the libraries
library(plyr)
library(dplyr)

## Which columns are mean and std
features<- read.table("features.txt", stringsAsFactors = FALSE)
features <- features[,2]

selCols <- union(grep("-mean\\(\\)", features), grep("-std\\(\\)", features))
selCols <- selCols[sort.list(selCols)]

## Read xtrain, select mean and std columns, add a row index to do the merge later on
xtrain<-tbl_df(read.table("train/X_train.txt", stringsAsFactors = FALSE))
xtrain <- select(xtrain, selCols)
xtrain <- mutate(xtrain, Row.Index=1:dim(xtrain)[1])

## Read subjectTrain, add row index to do the merge later on
subjectTrain <- tbl_df(read.table("train/subject_train.txt", stringsAsFactors = FALSE))
names(subjectTrain) <- "Subject.Id"
subjectTrain <- mutate(subjectTrain, Row.Index=1:dim(subjectTrain)[1])

## Read ytrain, add row index to do the merge later on
ytrain <- tbl_df(read.table("train/y_train.txt", stringsAsFactors = FALSE))
names(ytrain)<-"Activity"
ytrain <- mutate(ytrain, Row.Index=1:dim(ytrain)[1])

## Merge subjectTrain with ytrain
aux <- tbl_df(join(subjectTrain, ytrain, by="Row.Index"))

## Merge the result with xtrain
train <- tbl_df(join(xtrain, aux, by="Row.Index"))

## Add a new variable indicating that these subjects were selected for the training group
train <- mutate(train, Data.Partition="Training")

## Read xtest, select mean and std columns, add a row index to do the merge later on
xtest <- tbl_df(read.table("test/X_test.txt", stringsAsFactors = FALSE))
xtest<-mutate(xtest, Row.Index=1:dim(xtest)[1])
xtest <- select(xtest, selCols, Row.Index)

## Read subjectTest and add a row index to do the merge later on
subjectTest <- tbl_df(read.table("test/subject_test.txt", stringsAsFactors = FALSE))
names(subjectTest) <- "Subject.Id"
subjectTest <- mutate(subjectTest, Row.Index=1:dim(subjectTest)[1])

## Read ytest and add a row index to do the merge later on
ytest <- tbl_df(read.table("test/y_test.txt", stringsAsFactors = FALSE))
names(ytest) <- "Activity"
ytest <- mutate(ytest, Row.Index=1:dim(ytest)[1])

## Merge subjectTest with ytest
aux <- tbl_df(join(subjectTest, ytest, by="Row.Index"))

## Merge the result with xtest
test <- tbl_df(join(xtest, aux, by="Row.Index"))

## Add a new variable indicating that these subjects were selected for the test group 
test <- mutate(test, Data.Partition="Test")

## Merge the test and train sets and order them by subject
data <- arrange(rbind_list(test, train), Subject.Id)

## Replace the activity number with its name
activityLabels<-read.table("activity_labels.txt", stringsAsFactors = FALSE)[2]
data<-mutate(data, Activity=activityLabels[data$Activity,1])

## Set the labels on the data set
dataCols <- dim(data)[2]
names(data) <- c(features[selCols], names(data)[(dataCols - 3):dataCols])

## Make the labels meaningful
names(data) <- names(data) %>%
gsub(pattern="BodyBody", replacement="Body") %>%
gsub(pattern="Body", replacement="Body.") %>%
gsub(pattern="Acc", replacement="Accelerometer.") %>%
gsub(pattern="Gyro", replacement="Gyroscope.") %>%
gsub(pattern="Mag", replacement="Magnitude.") %>%
gsub(pattern="Jerk", replacement="Jerk.") %>%
gsub(pattern="-X", replacement="X.Axis") %>%
gsub(pattern="-Y", replacement="Y.Axis") %>%
gsub(pattern="-Z", replacement="Z.Axis") %>%
gsub(pattern="-mean\\(\\)$", replacement="Mean") %>%
gsub(pattern="-mean\\(\\)", replacement="Mean.") %>%
gsub(pattern="-std\\(\\)$", replacement="Standard.Deviation") %>%
gsub(pattern="-std\\(\\)", replacement="Standard.Deviation.") %>%
gsub(pattern="^f", replacement="Frequency.Domain.") %>%
gsub(pattern="^t", replacement="Time.Domain.")  

## Compute the average of every variable by activity and subject
finalData <- data %>%
  select(-Row.Index, -Data.Partition) %>%
  group_by(Activity, Subject.Id) %>%
  summarise_each(funs(mean))

## Give this new data set new variable names by adding "Mean.Of."
names <- names(finalData)
finalColNames <- sapply(names[3:length(names)], function(name) paste("Mean.Of.",name, sep=""))
names(finalData) <- c(names[1:2], finalColNames)

## Write the table to a file
write.table(finalData, "finalData.txt", row.name=FALSE)



##mean and standard deviation for each measurement.  (Italics mine.)  Each measurement has a set of computed quantities, including "mean" and "std" and "meanFreq" and a bunch more.  See features_info.txt.  (I had to read it a few times!)  Thus, if we are to take the mean and standard deviation (and not the mean frequency), then we need to include "mean" and "std" but not "meanFreq".  In other words, if we include meanFreq, then we're including three items for each measurement, not two.
## measurements are normalised and so unitlless.


