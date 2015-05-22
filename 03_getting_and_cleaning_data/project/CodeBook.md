# Getting and Cleaning Data: Project Code Book #

This document summarizes the workings of the run_analysis.R script.

## The Data ##

This section goes over some basic infomation about the data we are working with.

### Source Data ###

Some basic information about our source data:

* Download the data at: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
* Information about data: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

### Output Data ###

Information about our final tidy data set output file. The file has one row per (subject, activity) group, with each row containing the mean of each measurement for that grouping.

* subject: ID of the subject (individual) from whom the measurement came from. This is a numeric ID.
* activity: Human-readable activity label for the activity being measured. Values can consist of: WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING.
* *-mean(), *-std(): Average values for each mean and standard deviation measurement, for each grouping. Units: varies (accelerometer and gyroscope sensor outputs).


## Study Design ##

Here, we cover specifics about how the analysis script does its work.

### Assumptions ###

1. We assume that all mean and std deviation measurement data, which is what we are looking for, has a feature name of the form "*-mean()" or "*-std()", respectively.
2. We assume that there are no missing values. This assumption is confirmed in the dataset characteristics document provided. We call this out because run_analysis.R has no special handling for missing values.

### Analysis Execution ###

This is a summary of how the script executes.

1. Load all training data (subjects, activities, measurements), and combine the columns into a data frame.
2. Load all test data (subjects, activities, measurements), and combine the columns into a data frame.
3. Combine the data rows into a single raw data set.
4. Decorate the raw data with appropriate column names.
    1. Load the features file, which lists all measurement names.
    2. Add the subject, activity, and the contents of all features to the data names.
5. Keep only the mean/stddev measurements, and replace activity IDs with their human-readable names.
    1. Remove all columns with duplicated names (needed for dplyr to work correctly)
    2. Replace the activity IDs with the corresponding activity label name, read from the activity labels data.
    3. Keep only desired columns (subject, activity, and anything containing "-mean()" or "-std()").
6. Summarize data by averaging all measurements, grouped by subject and activity.
    1. apply a subject+activity grouping to the data
    2. summarize on each grouping by taking the mean of each measurement for the group. Note we opt for a "wide" form of tidy data.
7. Write summary result out to table.

