library(tidyverse)
library(jsonlite)
library(magrittr)
library(simts)
library(maps)
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

df_state <- df_sector %>%
  mutate(stateDescription = tolower(stateDescription)) %>%
  filter(sectorName == "all")

ggplot() +
  geom_map(data = mapUS, map = mapUS, aes(map_id = region), fill = "#00000033", color = "white") +
  theme(legend.background = element_rect(fill = "black"),
        legend.key = element_rect(fill = "black"),
        legend.text = element_text(color = "white"),
        legend.title = element_text(color = "white"),
        panel.grid = element_blank(), 
        panel.border = element_rect(fill = NA), 
        panel.background = element_rect(fill = "black"), 
        plot.background = element_rect(fill = "black"))

crimes <- data.frame(state = tolower(rownames(USArrests)), USArrests)

vars <- lapply(names(crimes)[-1], function(j) {
  data.frame(state = crimes$state, variable = j, value = crimes[[j]])
})
