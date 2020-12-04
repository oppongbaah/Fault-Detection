# Import the necessary python libraries
import numpy as np
import pandas as pd
from io import StringIO
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import LabelEncoder
from sklearn import preprocessing
from sklearn.model_selection import train_test_split

# Import the dataset from the project directory
dataset = pd.read_csv('F:\Project\Final Year\Main Work\Data\Data.csv')
# Drop the first column (i.e., the No column)
dataset = dataset.drop(['No'], axis = 1)
# HANDLING CATEGORICAL DATA
# Output column is a column with categoricaldata. ML algorithms do not work with 
# any datatype aside numerical data.Therefore LabelEncoding will be used
# Performing LabelEncoding using sciketlearn
labelencoder = LabelEncoder()
dataset['Fault'] = labelencoder.fit_transform(dataset['Fault'])
# Standardising the inputs of the dataset (between -1 and 1)
# Define target
target_y = dataset['Fault']
# Drop the output from the dataset
dataset = dataset.drop(['Fault'], axis = 1)
# Standardise the inputs by creating a Scaler object. 
scaler = preprocessing.StandardScaler()
# Fit your data on the scaler object
scaled_df = scaler.fit_transform(dataset)
# Define inputs
dataset = pd.DataFrame(scaled_df, columns = ['A6','D1','D2','D3','D4','D5','D6'])
# Add the output to the dataset
dataset = pd.concat([dataset, target_y], axis = 1)
# Save the dataset 
dataset.to_excel(r'F:\Project\Final Year\Main Work\Data\Proccessed_Data.xlsx', sheet_name='ProcessedData')
# Splitting dataset into training and testing datasets
x_train, y_test = train_test_split(dataset, test_size=0.2)
(train_data, test_data) = (x_train, y_test)
x, y = train_test_split(x_train, test_size=0.001)
check_data = y.drop(['Fault'], axis = 1)
# Saving the training and testing datasets
# Training data
train_data.to_csv(r'F:\Project\Final Year\Main Work\Data\Train_Data.csv', header = False, index=False) 
train_data.to_excel(r'F:\Project\Final Year\Main Work\Data\Train_Data.xlsx', sheet_name='Training_Data')
# Testing data
test_data.to_csv(r'F:\Project\Final Year\Main Work\Data\Test_Data.csv', header = False, index=False) 
test_data.to_excel(r'F:\Project\Final Year\Main Work\Data\Test_Data.xlsx', sheet_name='Testing_Data')
# Checking data
check_data.to_csv(r'F:\Project\Final Year\Main Work\Data\Check_Data.csv', header = False, index=False) 
check_data.to_excel(r'F:\Project\Final Year\Main Work\Data\Check_Data.xlsx', sheet_name='Testing_Data')