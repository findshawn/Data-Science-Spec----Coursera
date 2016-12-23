### Summary:

This is the code book that describes the variables, the data, and any transformations or work performed to clean up the data.

### Background:

One of the most exciting areas in all of data science right now is wearable computing. Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

### What does the script *run_analysis.R* do:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

### What does the output (tidy) data look like:

1. **35 oberservations** (unique subject & activity combinations) and **66 calculated fields**.
2. The 66 calculated fields are the average value for each variable given the subject and his/her activity.

### Features in raw data:

The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 

These signals were used to estimate variables of the feature vector for each pattern:  
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

### Features in output (tidy) data:

Key terms in the 66 variable names:

- **Time:** time domain signals
- **Frequency:** frequency domain signals
- **Body-Acceleration:** body acceration signals 
- **Gravity-Acceleration:** gravity acceration signals 
- **Jerk:** Jerk signals derived from the body linear acceleration and angular velocity
- **Magnitude:** the magnitude of these three-dimensional signals calculated using the Euclidean norm
- **Gyration:** gyration signals captured by gyroscope
- **XYZ:** the 3-axial signals in the X, Y and Z directions

- **mean:** the average value (same unit from the raw data)
- **std:** standard deviation (1 equals to one standard deviation)

### Detailed data cleaning process:

1. Download, unzip and load the raw data into R.
2. Combine the train and test data.
3. Get column names from the file *features.txt* and apply them to the combined data frame.
4. Extracts only the measurements on the mean and standard deviation for each measurement by searching the patterns "mean()" or "std()" in variable names.
5. Append the activity names to the data frame using the files *y_train.txt*, *y_test.txt*, and the lookup table *activity_labels.txt*.
6. Append the subject id to the data frame using the files *subject_train.txt* and *subject_test.txt*.
7. Clean the variable names using the following transformation rules:
    - "t" -> "Time"
    - "f" -> "Frequency"
    - "Acc" -> "Acceleration"
    - "Gyro" -> "Gyration"
    - "Mag" -> "Magnitude"
    - "-" -> make sure every two words are seperated by one "-"
    - "(" -> removed
    - ")" -> removed
8. Rollup the dataset by *Subject* and *Activity*, and calculate the mean of each variable to populated the output (tidy) data.

### Full list of variables in output (tidy) data:

1. Subject                                             
2. Activity                                            
3. Time-Body-Acceleration-mean-X                       
4. Time-Body-Acceleration-mean-Y                       
5. Time-Body-Acceleration-mean-Z                       
6. Time-Body-Acceleration-std-X                        
7. Time-Body-Acceleration-std-Y                        
8. Time-Body-Acceleration-std-Z                        
9. Time-Gravity-Acceleration-mean-X                    
10. Time-Gravity-Acceleration-mean-Y                    
11. Time-Gravity-Acceleration-mean-Z                    
12. Time-Gravity-Acceleration-std-X                     
13. Time-Gravity-Acceleration-std-Y                     
14. Time-Gravity-Acceleration-std-Z                     
15. Time-Body-Acceleration-Jerk-mean-X                  
16. Time-Body-Acceleration-Jerk-mean-Y                  
17. Time-Body-Acceleration-Jerk-mean-Z                  
18. Time-Body-Acceleration-Jerk-std-X                   
19. Time-Body-Acceleration-Jerk-std-Y                   
20. Time-Body-Acceleration-Jerk-std-Z                   
21. Time-Body-Gyration-mean-X                           
22. Time-Body-Gyration-mean-Y                           
23. Time-Body-Gyration-mean-Z                           
24. Time-Body-Gyration-std-X                            
25. Time-Body-Gyration-std-Y                            
26. Time-Body-Gyration-std-Z                            
27. Time-Body-Gyration-Jerk-mean-X                      
28. Time-Body-Gyration-Jerk-mean-Y                      
29. Time-Body-Gyration-Jerk-mean-Z                      
30. Time-Body-Gyration-Jerk-std-X                       
31. Time-Body-Gyration-Jerk-std-Y                       
32. Time-Body-Gyration-Jerk-std-Z                       
33. Time-Body-Acceleration-Magnitude-mean               
34. Time-Body-Acceleration-Magnitude-std                
35. Time-Gravity-Acceleration-Magnitude-mean            
36. Time-Gravity-Acceleration-Magnitude-std             
37. Time-Body-Acceleration-Jerk-Magnitude-mean          
38. Time-Body-Acceleration-Jerk-Magnitude-std           
39. Time-Body-Gyration-Magnitude-mean                   
40. Time-Body-Gyration-Magnitude-std                    
41. Time-Body-Gyration-Jerk-Magnitude-mean              
42. Time-Body-Gyration-Jerk-Magnitude-std               
43. Frequency-Body-Acceleration-mean-X                  
44. Frequency-Body-Acceleration-mean-Y                  
45. Frequency-Body-Acceleration-mean-Z                  
46. Frequency-Body-Acceleration-std-X                   
47. Frequency-Body-Acceleration-std-Y                   
48. Frequency-Body-Acceleration-std-Z                   
49. Frequency-Body-Acceleration-Jerk-mean-X             
50. Frequency-Body-Acceleration-Jerk-mean-Y             
51. Frequency-Body-Acceleration-Jerk-mean-Z             
52. Frequency-Body-Acceleration-Jerk-std-X              
53. Frequency-Body-Acceleration-Jerk-std-Y              
54. Frequency-Body-Acceleration-Jerk-std-Z              
55. Frequency-Body-Gyration-mean-X                      
56. Frequency-Body-Gyration-mean-Y                      
57. Frequency-Body-Gyration-mean-Z                      
58. Frequency-Body-Gyration-std-X                       
59. Frequency-Body-Gyration-std-Y                       
60. Frequency-Body-Gyration-std-Z                       
61. Frequency-Body-Acceleration-Magnitude-mean          
62. Frequency-Body-Acceleration-Magnitude-std           
63. Frequency-Body-Body-Acceleration-Jerk-Magnitude-mean
64. Frequency-Body-Body-Acceleration-Jerk-Magnitude-std 
65. Frequency-Body-Body-Gyration-Magnitude-mean         
66. Frequency-Body-Body-Gyration-Magnitude-std          
67. Frequency-Body-Body-Gyration-Jerk-Magnitude-mean    
68. Frequency-Body-Body-Gyration-Jerk-Magnitude-std  
