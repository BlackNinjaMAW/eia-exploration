library(data.table)
library(jsonlite)
library(magrittr)
library(httr)

api_key <- "Put your API key here"

customers <- "https://api.eia.gov/v2/electricity/retail-sales/data/?frequency=monthly&data[0]=customers&data[1]=price&data[2]=revenue&data[3]=sales&sort[0][column]=period&sort[0][direction]=desc&offset=0&length=5000&api_key=" %>%
  paste0(., api_key)

response <- GET(customers)  # Making API call

# Check if request was successful
if(http_status(response)$message == "OK") {
  # Parse the received JSON data
  dt_customers <- content(response, as = "text", encoding = "UTF-8") %>%
    fromJSON(flatten = TRUE) %>%
    .$response %>%
    .$data
} else {
  print(paste0("Error: ", http_status(response)$message, "\nMessage Michael"))
}
