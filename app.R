library(optionstrat)
library(markdown)
library(reshape2)
library(ggplot2)
library(plotly)
library(Quandl)
library(shiny)

# Set the Quandl API key
Quandl.api_key("YfJPasbKLsN4smx3iNXw")

# Load the dataset
brent <- Quandl("CHRIS/CME_BZ1", meta = T)

caption_char_limit <- 90

# Define UI
ui <- fluidPage(
  
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "united.css")
  ),
  
  titlePanel("Analysis on the Brent Crude Oil Financial Futures"),
  
  # Sidebar layout
  sidebarLayout(
    sidebarPanel(
      numericInput("N", "Number of periods", value = 100),
      numericInput("S0", "Initial price", value = 100),
      numericInput("mu", "Drift", value = 0.05),
      numericInput("sigma", "Volatility", value = 0.2),
      includeMarkdown("description.md")
    ),
    
    # Main panel layout
    mainPanel(
      tabsetPanel(
        tabPanel("GBM Plot", plotlyOutput("gbm_plot", height = "650px")),
        tabPanel("Scatter Plot", plotlyOutput("scatter_plot", height = "500px")),
        tabPanel("Box Plot", plotlyOutput("box_plot", height = "650px")),
        tabPanel("Time Series Analysis", plotlyOutput("time_series_plot", height = "650px")),
        tabPanel("Price Prediction", plotlyOutput("price_prediction_plot", height = "650px")),
        tabPanel("Correlation Matrix", plotlyOutput("corr_plot", height = "650px"))
      )
    )
  )
)

# Define server
server <- function(input, output) {
  
  # Generate GBM plot
  gbm <- reactive({
    dt <- 1/input$N
    t <- seq(0, 1, by = dt)
    W <- c(0, cumsum(rnorm(input$N)*sqrt(dt)))
    S <- input$S0*exp((input$mu-0.5*input$sigma^2)*t+input$sigma*W)
    data.frame(t = t, S = S)
  })
  
  output$gbm_plot <- renderPlotly({
    caption_text <- "Displays the Geometric Brownian Motion, which is a stochastic process used to model stock prices. It is calculated based on the specified parameters: Number of periods, Initial price, Drift, and Volatility." %>%
      strwrap(width = caption_char_limit) %>%
      paste(collapse = "\n")
  
    plot_ly(gbm(), 
            x = ~t, 
            y = ~S, 
            type = "scatter", 
            mode = "lines",
            color = I("#AA5945")) %>%
      layout(
        title = "Geometric Brownian Motion",
        xaxis = list(title = "Time"),
        yaxis = list(title = "Price"),
        margin = list(b = 170, t = 100),
        annotations = list(x = 1, y = -0.4, text = caption_text,
                           xref='paper', yref='paper', showarrow = F, 
                           xanchor='right', yanchor='auto', xshift=0, yshift=0,
                           font = list(size = 12), align = "right")
      )
  })
  
  # Generate correlation matrix plot
  corr_matrix <- reactive({
    # Select the required columns
    brent_subset <- brent[, c("Settle", "Volume", "Previous Day Open Interest")]
    # Calculate the correlation matrix
    corr <- cor(brent_subset)
    # Return the correlation matrix
    melt(corr)
  })
  
  output$corr_plot <- renderPlotly({
    caption_text <- "Shows the correlation between different attributes of the Brent Crude Oil dataset" %>%
      strwrap(width = caption_char_limit) %>%
      paste(collapse = "\n")
    
    # Plot the correlation matrix as a heatmap
    plot_ly(
      data = corr_matrix(),
      x = ~Var1,
      y = ~Var2,
      z = ~value,
      type = "heatmap",
      colorscale = "Jet"
    ) %>%
      layout(
        xaxis = list(title = ""),
        yaxis = list(title = ""),
        margin = list(b = 170, t = 100),
        annotations = list(x = 1, y = -0.4, text = caption_text,
                           xref='paper', yref='paper', showarrow = F, 
                           xanchor='right', yanchor='auto', xshift=0, yshift=0,
                           font = list(size = 12), align = "right")
      )
  })
  
  # Generate scatter plot
  output$scatter_plot <- renderPlotly({
    caption_text <- "Represents the relationship between Date, Settle price, and Volume within a 3 dimensional space." %>%
      strwrap(width = caption_char_limit) %>%
      paste(collapse = "\n")
    
    plot_ly(
      brent, 
      x = ~Date, 
      y = ~Settle, 
      z = ~Volume,
      type = "scatter3d",
      mode = "markers",
      marker = list(
        color = ~Settle,
        colorscale = "Inferno"
      )
    ) %>%
      layout(
        title = "Scatter Plot (3D)",
        scene = list(
          xaxis = list(title = "Date"),
          yaxis = list(title = "Settle"),
          zaxis = list(title = "Volume"),
          aspectmode = 'auto'
        ),
        margin = list(b = 200, t = 100),
        height = 700,
        annotations = list(x = 1, y = -0.5, text = caption_text,
                           xref='paper', yref='paper', showarrow = F, 
                           xanchor='right', yanchor='auto', xshift=0, yshift=0,
                           font = list(size = 12), align = "right")
      )
  })
  
  # Generate box plot
  output$box_plot <- renderPlotly({
    brent$Date <- as.Date(brent$Date)
    
    caption_text <- "The distribution of Settle prices across different years." %>%
      strwrap(width = caption_char_limit) %>%
      paste(collapse = "\n")
    
    plot_ly(
      data = brent,
      x = ~format(Date, "%Y"),
      y = ~Settle,
      type = "box",
      color = I("#AA5945"),
      marker = list(
        color = ~Settle,
        colorscale = "Inferno"
      )
    ) %>%
      layout(
        title = "Box Plot (Interactive)",
        xaxis = list(title = "Year"),
        yaxis = list(title = "Settle"),
        margin = list(b = 170, t = 100),
        annotations = list(x = 1, y = -0.4, text = caption_text,
                           xref='paper', yref='paper', showarrow = F, 
                           xanchor='right', yanchor='auto', xshift=0, yshift=0,
                           font = list(size = 12), align = "right")
      )
  })
  
  # Generate time series plot
  output$time_series_plot <- renderPlotly({
    caption_text <- "The historical trend of Settle prices across different years." %>%
      strwrap(width = caption_char_limit) %>%
      paste(collapse = "\n")
    
    plot_ly(
      data = brent,
      x = ~Date,
      y = ~Settle,
      type = "scatter",
      mode = "lines",
      color = I("#AA5945")
    ) %>%
      layout(
        title = "Time Series Analysis",
        xaxis = list(title = "Date"),
        yaxis = list(title = "Settle"),
        margin = list(b = 170, t = 100),
        annotations = list(x = 1, y = -0.4, text = caption_text,
                           xref='paper', yref='paper', showarrow = F, 
                           xanchor='right', yanchor='auto', xshift=0, yshift=0,
                           font = list(size = 12), align = "right")
      )
  })
  
  # Generate price prediction plot
  output$price_prediction_plot <- renderPlotly({
    # Perform price prediction using GBM
    dt <- 1/input$N
    t <- seq(0, 1, by = dt)
    W <- c(0, cumsum(rnorm(input$N)*sqrt(dt)))
    predicted_prices <- input$S0 * exp((input$mu - 0.5 * input$sigma^2) * t + input$sigma * W)
    
    # Create a data frame with predicted prices
    prediction_data <- data.frame(t = t, Predicted_Price = predicted_prices)
    
    caption_text <- "Predicts the future prices of crude oil using the specified GBM parameters and displays them in an interactive bar graph with gradient coloring." %>%
      strwrap(width = caption_char_limit) %>%
      paste(collapse = "\n")
    
    # Generate an interactive bar graph with gradient coloring
    plot_ly(prediction_data, x = ~t, y = ~Predicted_Price, type = "bar", 
            marker = list(color = ~Predicted_Price, colorscale = "Inferno")) %>%
      layout(
        title = "Price Prediction",
        xaxis = list(title = "Time"),
        yaxis = list(title = "Price"),
        margin = list(b = 170, t = 100),
        annotations = list(x = 1, y = -0.4, text = caption_text,
                           xref='paper', yref='paper', showarrow = F, 
                           xanchor='right', yanchor='auto', xshift=0, yshift=0,
                           font = list(size = 12), align = "right")
      )
  })
}

# Run the app
shinyApp(ui = ui, server = server)
