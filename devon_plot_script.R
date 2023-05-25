library(tidyverse)
library(jsonlite)
library(magrittr)
library(simts)
library(maps)
library(httr)
library(ggplot2)
library(dplyr)

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
      cat(paste(http_status(response)$message))
      finished <- TRUE
    }
  }
  
  # Prevents several calls from hitting API limit
  Sys.sleep(5)
  
  return(df_data)
}

api_key <- "cNBvIPbqcC8WgmDrJM5haRO9giKzNOosV1XuZgaG"

emissions_url <- "https://api.eia.gov/v2/co2-emissions/co2-emissions-aggregates/data/?frequency=annual&data[0]=value&sort[0][column]=period&sort[0][direction]=desc"

sector_url <- "https://api.eia.gov/v2/electricity/retail-sales/data/?frequency=monthly&data[0]=customers&data[1]=price&data[2]=revenue&data[3]=sales&sort[0][column]=period&sort[0][direction]=desc"

power_url <- "https://api.eia.gov/v2/electricity/facility-fuel/data/?frequency=monthly&data[0]=average-heat-content&data[1]=consumption-for-eg&data[2]=consumption-for-eg-btu&data[3]=generation&data[4]=gross-generation&data[5]=total-consumption&data[6]=total-consumption-btu&sort[0][column]=period&sort[0][direction]=desc"

df_emissions <- api_call(emissions_url, api_key)
df_sector <- api_call(sector_url, api_key)
df_power <- api_call(power_url, api_key)

df_totalcarbon <- df_emissions %>%
  filter(sectorId == "EC") %>%
  filter(`fuel-name` != "All Fuels") %>%
  group_by(`fuel-name`, `state-name`) %>%
  mutate(interval = signif(period, digits = 3)) %>%
  rename(fuel.name = "fuel-name")

df_cust_prices <- df_sector %>%
  mutate(period = as.Date(period, "%Y-%M")) %>%
  filter(sectorid != "ALL" & sectorid != "OTH") %>%
  group_by(period, sectorName, sectorid, stateid, `price-units`) %>%
  summarise(averagePrice = mean(price))



plot_carbon <- ggplot(data = df_totalcarbon, aes(x = period, y = value, fill = fuel.name, alpha = .6)) +
  stat_smooth(geom = "area") +
  geom_smooth(method = "lm", se = FALSE, linetype = "dashed") +
  theme(panel.grid = element_line(colour = "gray", linetype = "dashed")) +
  labs(title = "Total Carbon Emissions from Electric Power Sector by Fuel Type",
       subtitle = "Period from 1970-2020",
       x = "Period (Year)",
       y = "Metric Tons of CO2 Emitted (millions)")

plot(plot_carbon)


plot_pricing <- ggplot(data = df_cust_prices, aes(x = period, y = averagePrice, fill = sectorName, alpha = .6)) +
  stat_smooth(geom = "area") +
  geom_smooth(method = "lm", se = FALSE, linetype = "dashed") +
  theme(panel.grid = element_line(colour = "gray", linetype = "dashed")) +
  labs(title = "Price of Electricity by Sector",
       subtitle = "Period from 2001-2023",
       x = "Period",
       y = "Price (Cents per kW/H)")

plot(plot_pricing)