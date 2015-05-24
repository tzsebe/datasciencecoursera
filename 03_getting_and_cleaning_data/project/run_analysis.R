library(dplyr)

# This loads a raw data set (e.g. "training data"). All components must
# be passed in as parameters:
# * data_file: File containing the raw measurements.
# * labels_file: File containing activity labels for each measurement.
# * subject_file: File containing subject IDs for each measurement.
#
# Returns: Data frame containing the following columns:
# [subject][labels][all measurements...]
load_dataset <- function(data_file, labels_file, subjects_file) {
    data <- read.table(data_file)
    labels <- read.table(labels_file)
    subjects <- read.table(subjects_file)
    cbind(subjects, labels, data)
}

# Declare constants.
DATASET_ROOT            <- "UCI HAR Dataset"
TRAINING_DATA_FILE      <- paste(DATASET_ROOT, "train/X_train.txt", sep = "/")
TRAINING_LABELS_FILE    <- paste(DATASET_ROOT, "train/y_train.txt", sep = "/")
TRAINING_SUBJECTS_FILE  <- paste(DATASET_ROOT, "train/subject_train.txt", sep = "/")
TEST_DATA_FILE          <- paste(DATASET_ROOT, "test/X_test.txt", sep = "/")
TEST_LABELS_FILE        <- paste(DATASET_ROOT, "test/y_test.txt", sep = "/")
TEST_SUBJECTS_FILE      <- paste(DATASET_ROOT, "test/subject_test.txt", sep = "/")
FEATURES_FILE           <- paste(DATASET_ROOT, "features.txt", sep = "/")
ACTIVITY_LABELS_FILE    <- paste(DATASET_ROOT, "activity_labels.txt", sep = "/")
OUTPUT_AVERAGES_FILE    <- "subject_activity_averages.txt"

# Verify we're at the right place.
if(!dir.exists(DATASET_ROOT)) {
    stop("Working directory ", getwd(), " does not contain expected dataset root: ", DATASET_ROOT)
}

# Load and merge the data sets. We assume we're sitting right outside the
# unzipped data directory.
# (corresponds to step 1 in the assignment)
message("Loading training data...")
training_data <- load_dataset(data_file = TRAINING_DATA_FILE,
                              labels_file = TRAINING_LABELS_FILE,
                              subjects_file = TRAINING_SUBJECTS_FILE)
message("Loading test data...")
test_data <- load_dataset(data_file = TEST_DATA_FILE,
                          labels_file = TEST_LABELS_FILE,
                          subjects_file = TEST_SUBJECTS_FILE)
message("Merging data...")
raw_data <- rbind(training_data, test_data)

# Set corresponding column names.
# (corresponds to step 4 in the assignment)
features <- read.table(FEATURES_FILE, stringsAsFactors = F)
names(raw_data) <- c("subject", "activity", features[,2])

# Read activity labels file.
activity_labels <- read.table(ACTIVITY_LABELS_FILE)

# Grab only columns containing mean and std, and throw in the human-readable activity labels.
# (corresponds to steps 2 and 3 in the assignment)
mean_std_data <- raw_data[!duplicated(names(raw_data))] %>%
                 mutate(activity = activity_labels[activity, 2]) %>%
                 select(subject, activity, contains("-mean()"), contains("-std()"))

# Generate averages data set. We'll go with a wide output, and use dplyr's summarise_each function.
# (corresponds to step 5 in the assignment)
message("Generating and writing averages data...")
output_averages <- mean_std_data %>% 
                   group_by(subject, activity) %>%
                   summarise_each(funs(mean))
write.table(output_averages, OUTPUT_AVERAGES_FILE, row.name = F)
