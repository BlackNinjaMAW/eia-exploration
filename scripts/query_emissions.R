library(jsonlite)
library(magrittr)
library(dplyr)
library(simts)
library(httr)

api_call <- function(url, api_key) {
  
  offset <- 0
  length <- 5000
  finished <- FALSE
  df_data <- data.frame()
  
  while(!finished) {
    
    # Construct the URL for the page
    offset_url <-  url %>%
      paste0(., "&api_key=", api_key) %>%
      paste0(., "&offset=", offset) %>%
      paste0(., "&length=", length)
    
    # Make the API call
    response <- GET(offset_url)
    
    # Check if request was successful
    if(response$status_code == 200) {
      # Parse the JSON data
      data <- content(response, as = "text", encoding = "UTF-8") %>%
        fromJSON(flatten = TRUE) %>%
        .$response %>%
        .$data
      
      # Append the new data to the main data.frame
      df_data <- data %>%
        rbind(df_data)
      
      # If we got less data than we asked for, we've reached the end
      if(nrow(data) < length) {
        finished <- TRUE
      } else {
        # Otherwise, increase the offset for the next call
        offset <- offset + length
      }
    } else {
      # End if errant status code received
      cat(paste(http_status(response)$message, "\nMessage Michael"))
      finished <- TRUE
    }
  }
  
  return(df_data)
}

api_key <- "Your API key here"
url <- "https://api.eia.gov/v2/co2-emissions/co2-emissions-aggregates/data/?frequency=annual&data[0]=value&facets[stateId][]=AK&facets[stateId][]=AL&facets[stateId][]=AR&facets[stateId][]=AZ&facets[stateId][]=CA&facets[stateId][]=CO&facets[stateId][]=CT&facets[stateId][]=DC&facets[stateId][]=DE&facets[stateId][]=FL&facets[stateId][]=GA&facets[stateId][]=HI&facets[stateId][]=IA&facets[stateId][]=ID&facets[stateId][]=IL&facets[stateId][]=IN&facets[stateId][]=KS&facets[stateId][]=KY&facets[stateId][]=LA&facets[stateId][]=MA&facets[stateId][]=MD&facets[stateId][]=ME&facets[stateId][]=MI&facets[stateId][]=MN&facets[stateId][]=MO&facets[stateId][]=MS&facets[stateId][]=MT&facets[stateId][]=NC&facets[stateId][]=ND&facets[stateId][]=NE&facets[stateId][]=NH&facets[stateId][]=NJ&facets[stateId][]=NM&facets[stateId][]=NV&facets[stateId][]=NY&facets[stateId][]=OH&facets[stateId][]=OK&facets[stateId][]=OR&facets[stateId][]=PA&facets[stateId][]=RI&facets[stateId][]=SC&facets[stateId][]=SD&facets[stateId][]=TN&facets[stateId][]=TX&facets[stateId][]=UT&facets[stateId][]=VA&facets[stateId][]=VT&facets[stateId][]=WA&facets[stateId][]=WI&facets[stateId][]=WV&facets[stateId][]=WY&facets[fuelId][]=CO&facets[fuelId][]=NG&facets[fuelId][]=PE&facets[sectorId][]=EC&start=1990&end=2020&sort[0][column]=fuelId&sort[0][direction]=desc&offset=0&length=5000"

df_emissions <- api_call(url, api_key)

# Example of a plot using the above dataset

df_prices <- df_customers %>%
  mutate(period = as.Date(period, "%Y-%M")) %>%
  filter(sectorid != "ALL" & sectorid != "OTH") %>%
  group_by(period, sectorName) %>% 
  summarize(averagePrice = mean(price), .groups = "drop")

plot_theme <- ggdark::dark_theme_gray(base_size = 14) + 
  theme(plot.title = element_text(color = "#F7F7F7"),
        plot.background = element_rect(fill = "#1e2124"),
        panel.background = element_rect(fill = "#1e2124"),
        panel.grid.major = element_line(color = "grey40", linewidth = 0.2),
        panel.grid.minor = element_line(color = "grey40", linewidth = 0.2),
        legend.background = element_blank(),
        axis.ticks = element_blank(),
        legend.key = element_blank(),
        legend.position = c(0.2, 0.815),
        axis.text = element_text(color = "#F7F7F7"),
        legend.text = element_text(color = "#F7F7F7"))

plot <- ggplot(df_prices, aes(x = period, y = averagePrice, color = sectorName)) +
  geom_line() +
  labs(x = "Price (Cents Per kW/H)", y = "Date", color = "Sector") +
  plot_theme

plot(plot)