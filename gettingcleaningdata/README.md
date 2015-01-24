# README

## Introduction
This is the Course Project of the Getting and Cleaning Data course on Coursera.

Our goal is to clean and tidy the following data:


Human Activity Recognition Using Smartphones Dataset
Version 1.0

Jorge L. Reyes-Ortiz, Davide Anguita, Alessandro Ghio, Luca Oneto.

Smartlab - Non Linear Complex Systems Laboratory

DITEN - Università degli Studi di Genova.

Via Opera Pia 11A, I-16145, Genoa, Italy.

activityrecognition@smartlab.ws

www.smartlab.ws

Project website:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Data link:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

According to the course's website we should create one R script called run_analysis.R that does the following:

- Merge the training and the test sets to create one data set.
- Extracts only the measurements on the mean and standard deviation for each measurement. 
- Uses descriptive activity names to name the activities in the data set
- Appropriately labels the data set with descriptive variable names. 
- From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Script explanation
In this section we will go over the different steps in run_analysis.R to achieve the required goals:

- Before manipulating the data we need to load the plyr and dplyr packages.
- Read the features.txt file, which contains the names of the variables in the data sets (X_train.txt and X_test.txt).
- From the variable names in features.txt select only the ones that compute the mean and the std for every signal (understanding that mean() is different than meanFreq() as described in features_info.txt).
- Read the training data set in X_train.txt and drop the columns we are not going to use.
- Later on we will merge the training data set with the subjects' identifier and the activity code. To be able to do so we need to add a row identifier "Row.Index" on all three data frames; we start by adding it to the xtrain tbl.
- Read the subjects' identifier from subject_train.txt and add the row index column.
- Read the activity code from y_train.txt and add the row index column.
- Now that we have all the data from the training set loaded on different tbl objects we need to merge them. The first step is to merge the subject's identifier with the activity indentifer; the second is merging the result with the data gathered from the sensors (xtrain).
- The final step for the training set is to add a new column/variable that identifies all the observations as belonging to "Training" set.
- Moving on to the test data, we start by reading X_test.txt, dropping the columns we are not going to use and adding the row identifier to merge data later on.
- Read the subjects' identifier from subject_test.txt and add the row index for the merge.
- Read the activity code from y_test and add the row index column.
- Now that we have all the data from the test set loaded on different tbl objects we need to merge them. The first step is to merge the subject's identifier with the activity indentifer; the second is merging the result with the data gathered from the sensors (xtest).
- The final step for the test set is to add a new column/variable that identifies all the observations as belonging to "Test" set.
- We have all the test data in the _test_ tbl and all the training data in the _train_ tbl. Now we can combine the train and test data and order by Subject Identifier.

At this point we have the training and test data in the _data_ tbl. Next steps:

- Replace the activity code with the activity name. To do that we use the mutate function.
- Set the columns names in _data_ using the features vector but preserving the names of the last 4 variables that we have added (Row.Index, Subject.Identifier, Activity, Data.Partition).
- Normalize the names of the columns: remove repeated parts of the name, replace abbreviations with the complete word and separate every word in the name with a dot.

At this point we have the data set with clear and meaningful names and the activity code has been replaced with the activity name. Next steps:

- Create a new tbl by dropping the Row.Index and the Data.Partition variables, we are not going to need them.
- We need to compute the mean of all the variables for every activity and every subject. To do that we indicate the tbl to group_by _Activity_ and _Subject.Identifier_. Call _summarise_each_ to compute the mean on every column.
- Finally we need to rename the column variables, since they now contain the mean of the original variables. By calling _sapply_ we add "Mean.Of." to the current column name.
