
README for Brent Crude Oil Financial Futures Analysis
=====================================================

This Shiny application analyzes the historical futures prices of Brent Crude Oil using the CHRIS/CME\_BZ1 dataset from Quandl.

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
  brent_subset <- brent[, c("Open", "High", "Low", "Last", "Change", "Settle", "Volume", "Previous Day Open Interest")]
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
