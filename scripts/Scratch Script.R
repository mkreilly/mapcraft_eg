library(httr)
key="b901231133cf7da9e4ae3dea1af2470e87b3b9e7"
ACS_year="2016"
ACS_product="5"
county="001,013,041,055,075,081,085,095,097"
state="06"

https://api.census.gov/data/2017/acs/acs5?get=B01001_001E,NAME&for=block%20group:*&in=state:01%20county:025%20tract:957602&key=YOUR_KEY_GOES_HERE
trial_url2 = paste0("https://api.census.gov/data/",ACS_year,"/acs/acs",ACS_product,"?get=NAME,",ACS_BG_variables2,"&for=block%20group:*&in=state:",state,"%20county:","001","%20tract:400400&key=",key)

f.data <- function(url,geography_fields){  
  furl <- content(GET(url))
  for (i in 1:length(furl)){
    if (i==1) header <- furl [[i]]
    if (i==2){
      temp <- lapply(furl[[i]], function(x) ifelse(is.null(x), NA, x))
      output_data <- data.frame(temp, stringsAsFactors=FALSE)
      names (output_data) <- header
    }
    if (i>2){
      temp <- lapply(furl[[i]], function(x) ifelse(is.null(x), NA, x))
      tempdf <- data.frame(temp, stringsAsFactors=FALSE)
      names (tempdf) <- header
      output_data <- rbind (output_data,tempdf)
    }
  }
  for(i in 2:(ncol(output_data)-geography_fields)) {
    output_data[,i] <- as.numeric(output_data[,i])
  }
  return (output_data)
}


f.url <- function (ACS_BG_variables,tract) {paste0("https://api.census.gov/data/",ACS_year,"/acs/acs",ACS_product,"?get=NAME,",ACS_BG_variables,"&for=block%20group:*&in=state:",state,"%20county:","001","%20tract:",tract,"&key=",key)}
trial_url <- f.url(ACS_BG_variables = ACS_BG_variables1,"400400")

first_df <- f.data(f.url(ACS_BG_variables1,400400),4)


for(i in 1:length(tracts_vector)) {
  if (i==1) {
    first_df <- f.data(f.url(ACS_BG_variables1,tracts_vector[i]),4)
  }
  else if (i==2) {
    temp_df <- f.data(f.url(ACS_BG_variables1,tracts_vector[i]),4)
    output_df <- rbind(first_df,temp_df)
  }
  else {
    temp_df <- f.data(f.url(ACS_BG_variables1,tracts_vector[i]),4)
    output_df <- rbind(output_df,temp_df)
  }
}



for(i in 1:length(tracts_vector)) {
  if (i==1) {
    first_df <- f.data(f.url(ACS_BG_variables2,tracts_vector[i]),4)
  }
  else if (i==2) {
    temp_df <- f.data(f.url(ACS_BG_variables2,tracts_vector[i]),4)
    output_df <- rbind(first_df,temp_df)
  }
  else {
    temp_df <- f.data(f.url(ACS_BG_variables2,tracts_vector[i]),4)
    output_df <- rbind(output_df,temp_df)
  }
}

    


