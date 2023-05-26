# Oil Money Master: A Real-Time Quantitative Trading app for Crude Oil options 🛢️ 📈 #

=====================================================

This repository contains a Shiny application designed for quantitative trading analysis of crude oil options. The application leverages historical data of Brent Crude Oil Financial Futures to provide users with various interactive plots and tools for analyzing price trends, volatility, and correlations.


The Crude Oil Quantitative Trading App provides valuable tools and visualizations that can assist investors in analyzing and making informed decisions regarding crude oil options. Here's how an investor can leverage the app:

# Geometric Brownian Motion (GBM) Plot: #
The GBM plot helps investors understand the potential future price movements of crude oil. By adjusting parameters such as the number of periods, initial price, drift, and volatility, investors can simulate different scenarios and assess the potential risk and return associated with their investment strategies.

S 
t
​
 =S 
0
​
 exp((μ− 
2
1
​
 σ 
2
 )t+σW 
t
​
 )

Where:

�
�
S 
t
​
  represents the price of the asset at time 
�
t.
�
0
S 
0
​
  is the initial price of the asset.
�
μ is the drift or expected return of the asset per unit of time.
�
σ is the volatility or standard deviation of the asset's returns per unit of time.
�
�
W 
t
​
  is a Wiener process or standard Brownian motion, representing a random variable that follows a normal distribution with mean 0 and standard deviation 1.
In the formula, the term 
(
�
−
1
2
�
2
)
�
(μ− 
2
1
​
 σ 
2
 )t accounts for the deterministic trend or drift of the asset's price over time. It represents the expected increase in the asset's price due to factors such as growth or inflation.

The term 
�
�
�
σW 
t
​
  represents the random component or volatility of the asset's price. It captures the unpredictable fluctuations or shocks in the price that are not explained by the drift. The multiplication of 
�
σ (volatility) and 
�
�
W 
t
​
  (Wiener process) ensures that the random component follows a normal distribution with mean 0 and standard deviation 
�
σ.

By simulating the GBM formula for different time periods, initial prices, drifts, and volatilities, investors can generate a range of possible future price paths for crude oil or any other asset. This simulation helps assess the risk and return associated with investment strategies and supports decision-making processes.

![Capture](https://github.com/michael-wherry/eia-exploration/assets/75454891/5d93b96f-ad41-4e4d-9082-9b388a3f4407)

# Correlation Matrix: #
The correlation matrix allows investors to evaluate the relationships between different attributes of the Brent Crude Oil dataset, including settle price, volume, and previous day open interest. By identifying correlations, investors can gain insights into how these attributes interact and potentially discover patterns or dependencies that can inform their trading strategies.

![5Capture](https://github.com/michael-wherry/eia-exploration/assets/75454891/d2c1e0ef-eb77-4899-8874-4fc406c29a42)

# Scatter Plot (3D): #
The 3D scatter plot visualizes the relationship between date, settle price, and volume. Investors can identify trends, patterns, and potential outliers in the data, which can help in assessing market behavior and making trading decisions. For example, observing higher volumes accompanied by significant price movements may indicate increased market activity and potential trading opportunities.

![2Capture](https://github.com/michael-wherry/eia-exploration/assets/75454891/4a38f983-c8b7-4c65-9674-f5bb8fc47e12)

# Box Plot (Interactive):#
The interactive box plot enables investors to examine the distribution of settle prices across different years. By analyzing the central tendencies, outliers, and ranges within each year, investors can gain insights into the market's price dynamics. This information can help investors understand the historical behavior of crude oil prices and potentially identify trading opportunities based on price patterns and outliers.

![3Capture](https://github.com/michael-wherry/eia-exploration/assets/75454891/dcc12baf-a539-48f0-b4a7-60402eaad11c)

# Time Series Analysis: #
The time series analysis plot provides investors with a visual representation of the historical trend of settle prices across different years. By analyzing price movements over time, investors can identify long-term trends, seasonality, and potential cyclical patterns. This analysis can help investors in assessing market conditions and making informed decisions based on historical price behavior.

# Price Prediction: #
The price prediction feature utilizes the GBM parameters specified by the investor to forecast future prices of crude oil. By simulating different scenarios and generating predicted prices, investors can assess potential outcomes and gauge the risk and return associated with different investment strategies. This information can be valuable in formulating trading strategies and managing portfolio risk.

![4Capture](https://github.com/michael-wherry/eia-exploration/assets/75454891/8add9dbc-f627-4c5a-b5f4-3257f2d97607)

By utilizing these features and analyzing the visualizations provided by the Crude Oil Quantitative Trading App, investors can gain insights into the crude oil market and make more informed decisions when trading crude oil options. The app empowers investors to evaluate different scenarios, assess risk and return, identify patterns and correlations, and make predictions based on historical data and quantitative models.

Dependencies
------------

The application relies on several R packages:

*   `shiny` for creating the web application.
*   `ggplot2` for creating plots.
*   `Quandl` for downloading financial data.
*   `optionstrat` for options strategies and analytics.
*   `reshape2` for data reshaping.
*   `plotly` for creating interactive plots.

You can install these packages in R with:

```r
install.packages(c("shiny", "ggplot2", "Quandl", "optionstrat", "reshape2", "plotly"))
```

API Key
-------

The application requires a Quandl API key. Replace `"Your_Api_Key"` with your own API key.

Running the Application
-----------------------

To run the application, you can source the script in R or RStudio.

```r
source("path/to/your/script.R")
```

User Interface
--------------

The application features a sidebar for input parameters and multiple tabs for visualizing the data:

*   **Number of Periods**: This input allows the user to specify the number of periods for the Geometric Brownian Motion (GBM) model and price prediction.
    
*   **Initial Price**: This input allows the user to specify the initial price for the GBM model and price prediction.
    
*   **Drift**: This input allows the user to specify the drift (mean return) for the GBM model and price prediction.
    
*   **Volatility**: This input allows the user to specify the volatility (standard deviation of returns) for the GBM model and price prediction.
    

The main panel features six different tabs for visualizations:

*   **GBM Plot**: This tab displays the GBM of the stock prices.
    
*   **Correlation Matrix**: This tab shows a heatmap of the correlations between different attributes of the data.
    
*   **Scatter Plot**: This tab displays a 3D scatter plot of Date, Settle price, and Volume.
    
*   **Box Plot**: This tab shows a box plot of the Settle prices across different years.
    
*   **Time Series Analysis**: This tab presents a time series plot of Settle prices.
    
*   **Price Prediction**: This tab displays predicted prices based on the GBM model.
    
Notable Code
---------------------

### Data Loading

```r
# Set the Quandl API key
Quandl.api_key("Your_Api_Key")

# Load the dataset
brent <- Quandl("CHRIS/CME_BZ1", meta = T)
```

This snippet fetches data from the Quandl API using the provided API key. The data is then stored in the `brent` variable.

### Geometric Brownian Motion (GBM)

```r
# Generate GBM plot
gbm <- reactive({
  dt <- 1/input$N
  t <- seq(0, 1, by = dt)
  W <- c(0, cumsum(rnorm(input$N)*sqrt(dt)))
  S <- input$S0*exp((input$mu-0.5*input$sigma^2)*t+input$sigma*W)
  data.frame(t = t, S = S)
})
```

This reactive function calculates a Geometric Brownian Motion, a stochastic process often used in financial mathematics to model stock prices. This is then plotted in the GBM tab.

### Correlation Matrix

```r
# Generate correlation matrix plot
corr_matrix <- reactive({
  # Select the required columns
  brent_subset <- brent[, c("Settle", "Volume", "Previous Day Open Interest")]
  # Calculate the correlation matrix
  corr <- cor(brent_subset)
  # Return the correlation matrix
  melt(corr)
})
```

This function calculates the correlation matrix of the data subset selected. This correlation matrix is then displayed in the Correlation Matrix tab as a heatmap.

### Price Prediction

```r
# Generate price prediction plot
output$price_prediction_plot <- renderPlotly({
  # Perform price prediction using GBM
  dt <- 1/input$N
  t <- seq(0, 1, by = dt)
  W <- c(0, cumsum(rnorm(input$N)*sqrt(dt)))
  predicted_prices <- input$S0 * exp((input$mu - 0.5 * input$sigma^2) * t + input$sigma * W)
  
  # Create a data frame with predicted prices
  prediction_data <- data.frame(t = t, Predicted_Price = predicted_prices)
  
  #...
})
```

This part of the script uses the modeled Geometric Brownian Motion to predict future prices. The predicted prices are then visualized as a bar graph in the Price Prediction tab.

