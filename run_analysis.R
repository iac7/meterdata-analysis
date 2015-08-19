x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
z_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
df_test <- cbind(z_test, y_test, x_test)
colnames(df_test)[1] <- "subjects"
colnames(df_test)[2] <- "activities"

x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
z_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
df_train <- cbind(z_train, y_train, x_train)
colnames(df_train)[1] <- "subjects"
colnames(df_train)[2] <- "activities"

df_full <- rbind(df_train, df_test)

measurements <- read.table("UCI HAR Dataset/features.txt")
measurements <- measurements$V2
measurements <- as.character(measurements)

names(df_full)[3:563] <- make.names(measurements, unique = TRUE)
#creates valid and unique names for variable

df_subset <- select(df_full, subjects, activities, contains(".mean.."), contains("std.."))

df_activities <- read.table("UCI HAR Dataset/activity_labels.txt")
activities <- as.character(df_activities$V2)

activities_indices <- as.numeric(df_subset$activities)
activity_names <- activities[activities_indices]
activity_names <- tolower(activity_names)

df_subset$activities <- activity_names

vars <- names(df_subset)
vars <- tolower(vars)
names(df_subset) <- vars

df_averages <- df_subset %>% group_by(subjects, activities) %>% summarise_each(funs(mean))

tidy <- melt(df_averages, c("subjects", "activities"))

names(tidy) <- c("subjects", "activities", "measurements", "average")

measurements_tidy <- sub("...", ".", tidy$measurements, fixed = TRUE)
measurements_tidy <- sub("..", "", tidy$measurements, fixed = TRUE)
tidy$measurements <- measurements_tidy



