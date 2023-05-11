library(jsonlite)
library(magrittr)
library(dplyr)
library(httr)

api_key <- "Put your api key here"
url <- "https://api.eia.gov/v2/electricity/retail-sales/data/?frequency=monthly&data[0]=customers&data[1]=price&data[2]=revenue&data[3]=sales&sort[0][column]=period&sort[0][direction]=desc"

df_customers <- data.frame()

offset <- 0
length <- 5000
finished <- FALSE

while(!finished) {
  
  # Construct the URL for the page
  customers <-  url %>%
    paste0(., "&api_key=", api_key) %>%
    paste0(., "&offset=", offset) %>%
    paste0(., "&length=", length)
  
  # Make the API call
  response <- GET(customers)
  
  # Check if request was successful
  if(response$status_code == 200) {
    # Parse the JSON data
    data <- content(response, as = "text", encoding = "UTF-8") %>%
      fromJSON(flatten = TRUE) %>%
      .$response %>%
      .$data
    
    # Append the new data to the main data.frame
    df_customers <- data %>%
      rbind(df_customers)
    
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
