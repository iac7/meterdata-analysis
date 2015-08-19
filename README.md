ReadMe for run_analysis.R 
================================================================================

To read the output tidy data set, please use
```
data <- read.table("tidy.txt", header = TRUE)
```

**Raw data**
To better understand the raw dataset, please refer to the summary at the end of this file. Raw data can be downloaded here: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip into your working folder.

**R script**
Run the run_analysis.R script line by line.

**STEP 1** 
*Merges the training and the test sets*

After loading all necessary data into R, the script merges the training and test datasets together. subjects and activities are added. the subjects and activities columns are renamed accordingly in line with tidy data principals for simplicity of work later.

```
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
```

**STEP 2** 
*Extracts only the measurements on the mean and standard deviation*

First, the measurements names from file "features" are added to respective columns(variables). they are also renamed to unique valid names so that selection function can be used. 

```
measurements <- read.table("UCI HAR Dataset/features.txt")
measurements <- measurements$V2
measurements <- as.character(measurements)

names(df_full)[3:563] <- make.names(measurements, unique = TRUE)
#creates valid and unique names for variable
```

the columns that have mean and std in their title are subtracted along with subjects and activities. 

```
df_subset <- select(df_full, subjects, activities, contains(".mean.."), contains("std.."))
```

The course project instructions were to extract those columns that have mean and standard deviation for each measurement (signal), which according to dataset's features.info file correspond to:
mean(): Mean value
std(): Standard deviation
So, only these means and deviations were selected, in total of 66.

**STEP 3** 
*Assigns descriptive activity names*

The activity names are turned to lower case and assigned to each value instead of numeric value according to tidy data principles.

```
df_activities <- read.table("UCI HAR Dataset/activity_labels.txt")
activities <- as.character(df_activities$V2)
activities_indices <- as.numeric(df_subset$activities)
activity_names <- activities[activities_indices]
activity_names <- tolower(activity_names)
df_subset$activities <- activity_names
```

**STEP 4** 
*Labels the data set with descriptive variable names*

Variables (columns) have been already turned into descriptive names:
- words instead of numbers
- readable format
- lowercases to be able to call them easier

More clean ups are done:
```
vars <- names(df_subset)
vars <- tolower(vars)
names(df_subset) <- vars
```

**STEP 5** 
*Creates a tidy dataset with the average of each variable for each activity and each subject*

Data is grouped by subjects, activities and then ummarised by averages of each measurement. First subjects, then activities as it is a more clean and understandable representation of data. 

```
df_averages <- df_subset %>% group_by(subjects, activities) %>% summarise_each(funs(mean))
```

Dataset is melted and made into a long and skinny table which is more readable
Wickham recommends such formats to make it easy for analysis later, see his lecture https://vimeo.com/33727555 according to this video it is perfectly fine to keep measurements in a column under one variable, either them separate variables in individual columns.

```
tidy <- melt(df_averages, c("subjects", "activities"))
```

The measurements are now in rows not in columns, so it's enough to leave them abbreviated. Nevertheless, they are further cleaned to take our extra dots. they now look clean (abbreviated, lowercase and not unnecessary punctuations)
```
names(tidy) <- c("subjects", "activities", "measurements", "average")

measurements_tidy <- sub("...", ".", tidy$measurements, fixed = TRUE)
measurements_tidy <- sub("..", "", tidy$measurements, fixed = TRUE)
tidy$measurements <- measurements_tidy
```

<u>To summarise</u>, all tidy data principles were adhered to:
<url>https://github.com/iac7/courses/blob/master/03_GettingData/01_03_componentsOfTidyData/index.Rmd</url>

- Variables are in columns
- Each different observation of that variable is in a different row
- A rrow at the top of each file with variable names
- Variable names are human readable 

