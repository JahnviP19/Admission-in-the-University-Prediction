library(dplyr)
library(ggplot2)

# Load train and test datasets
train_data <- read.csv("adm_train.csv")
test_data <- read.csv("adm_test.csv")

# Explore the data
str(train_data)
summary(train_data)

# Renamed columns
colnames(train_data) <- c("Serial No", "GRE", "TOEFL", "University Rating", "SOP", "LOR", "CGPA", "Research", "Chance of Admit")
colnames(test_data) <- c("Serial No", "GRE", "TOEFL", "University Rating", "SOP", "LOR", "CGPA", "Research", "Chance of Admit")

# Check for missing values in the entire data set
any_missing_train <- any(is.na(train_data))  # there are no missing values in the entire train_data data set.
any_missing_test <- any(is.na(test_data))  # there are no missing values in the entire test_data data set.

# Detecting Outliers
# Boxplot for Score
boxplot(train_data$GRE, main = "Boxplot of GRE")
boxplot(train_data$TOEFL, main = "Boxplot of TOEFL")
boxplot(train_data$CGPA, main = "Boxplot of CGPA")

# Identifying outliers using z-score
z_scores <- scale(train_data$CGPA)
outliersCGPA <- which(abs(z_scores) > 3)  # outlier detected at 59

# Imputed outlier with the median of CGPA directly in the same column
train_data$CGPA[abs(z_scores) > 3] <- median(train_data$CGPA, na.rm = TRUE)

#Checking Data Distribution
# Histogram 
hist(train_data$CGPA, main = "Histogram of CGPA", col = "lightblue")
hist(train_data$GRE, main = "Histogram of GRE", col = "blue")
hist(train_data$TOEFL, main = "Histogram of TOEFL", col = "green")  # doesn't feel like data is highly skewed.

# Visualizing Correlations
# Correlation matrix
train_correlation_matrix <- cor(train_data[, c("GRE", "TOEFL", "CGPA", "Research", "Chance of Admit")])

# Create a heatmap using corrplot
library(corrplot)
corrplot(train_correlation_matrix, method = "number", col = colorRampPalette(c("white", "blue", "red"))(100), number.cex = 0.7) # This approach can be helpful when the color differences are not very pronounced

# Multiple correlations using the psych package
library(psych)
pairs.panels(train_data[, c("GRE", "TOEFL", "CGPA")])

# Scatter plot of GRE vs. CGPA
library(ggplot2)
ggplot(train_data, aes(x = GRE, y = CGPA, color = `Chance of Admit`)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "blue") +
  labs(title = "Scatter Plot of GRE vs. CGPA") +
  scale_color_gradient(low = "blue", high = "red")

# Scatter Plot of TOEFL vs. CGPA
ggplot(train_data, aes(x = TOEFL, y = CGPA, color = `Chance of Admit`)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "blue") +
  labs(title = "Scatter Plot of TOEFL vs. CGPA") +
  scale_color_gradient(low = "blue", high = "red")

# Scatter Plot of GRE vs. TOEFL
ggplot(train_data, aes(x = GRE, y = TOEFL, color = `Chance of Admit`)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "blue") +
  labs(title = "Scatter Plot of GRE vs. TOEFL") +
  scale_color_gradient(low = "blue", high = "red")

# Load required library
library(randomForest)

# Random Forest
model_rf <- randomForest(`Chance of Admit` ~ GRE + TOEFL + CGPA + Research, data = train_data)

# Make predictions on test_data
predictions_rf <- predict(model_rf, newdata = test_data)

# Evaluating the model (e.g., Mean Squared Error)
mse_rf <- mean((test_data$`Chance of Admit` - predictions_rf)^2)

# Saved predictions to a CSV file
predictions_df <- data.frame(`Chance of Admit Predicted` = predictions_rf)
write.csv(predictions_df, "predicted_results_RF.csv", row.names = FALSE)

# Assuming predictions_rf are the predictions from your Random Forest model
mse_rf <- mean((test_data$`Chance of Admit` - predictions_rf)^2)
mae_rf <- mean(abs(test_data$`Chance of Admit` - predictions_rf))
r_squared_rf <- 1 - (sum((test_data$`Chance of Admit` - predictions_rf)^2) / sum((test_data$`Chance of Admit` - mean(test_data$`Chance of Admit`))^2))
rmse_rf <- sqrt(mean((test_data$`Chance of Admit` - predictions_rf)^2))

# use the metrics as needed
print(paste("MSE:", mse_rf))
print(paste("MAE:", mae_rf))
print(paste("R-squared:", r_squared_rf))
print(paste("RMSE:", rmse_rf))

