# Electricity Price Forecasting

Author: Hammad Ullah

Electricity price forecasting, a branch of energy forecasting methods, focuses on the spot and forward prices in the wholesale electricity markets. It is an important tool that influences the energy companies’ decision-making at a larger corporate level. The forecasts not only predict the prices for the coming days but it also helps us see the seasonality in the prices whether that is weekly, daily, monthly, or even yearly. The whole purpose of forecasting is mainly for the bidding on power at a wholesale market as the prices for a certain day is decided a day before through the bidding system

**Aim and Tools**

**Data Preparation**
Our aim for this report is to download the electricity price data for France from the start of the year 2019 till 25th of October 2021. The data in these files include the day-ahead prices for all the days as well as the day-ahead load forecast. We need to treat the data for daylight saving time and correct the repetitions or any missing day’s day. For the missing days in the data, we take the average of the neighboring days and take that value for the missing day. For the day’s that are repeated, an average of the 2 days is taken and substituted as one entry.

**Data Visualization**
After the data has been cleaned and organized, we need to prepare scatter plots using the data of the first 2 years i.e., 2019-2020. The following scatter plots of forecasted load versus the price shall be prepared:
#For all data
#For all hours on Saturdays
#For the hour 10am on all days of the week

Along with the scatter plots, we have to prepare weekly and daily seasonality plots for both the price and load data for the same span of time i.e., 2019-2020.

**Data Forecasting**
After the scatter and seasonality plots, we need to compute forecasts for all the days in 2021 that we have the data for i.e., from 1st January to 25th October. We shall prepare forecasts for the electricity price using 4 different models.
The models can be found in the report file.

For all the 4 models, we will calculate the Mean Absolute Error (MAE) and Root Mean Square Error (RMSE) for each hour of the day separately and jointly for all hours.
We shall be using MATLAB for all of these tasks. The code is explained in the following sub-section of this report.


**Neural Network**

For each hour h of the day, we need to compute forecasts for all days in 2021 of a multilayer perceptron (MLP) with:
#Same inputs as the 24 hourly ARX1 models
#2 hidden layers
#24 outputs, i.e., Pd,1, Pd,2, ..., Pd,24
#sigmoid activation function for both hidden layers,
#A fixed two-year calibration window (2019-2020).

And we shall calculate MAE and RMSE and compare with the other four models. For this task, we shall be using Python.
