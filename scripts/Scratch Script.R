library(httr)
key="b901231133cf7da9e4ae3dea1af2470e87b3b9e7"
ACS_year="2016"
ACS_product="5"
county="001,013,041,055,075,081,085,095,097"
state="06"

https://api.census.gov/data/2017/acs/acs5?get=B01001_001E,NAME&for=block%20group:*&in=state:01%20county:025%20tract:957602&key=YOUR_KEY_GOES_HERE
trial_url2 = paste0("https://api.census.gov/data/",ACS_year,"/acs/acs",ACS_product,"?get=NAME,",ACS_BG_variables2,"&for=block%20group:*&in=state:",state,"%20county:","001","%20tract:400400&key=",key)

# Function for converting API calls into data frame

f.data <- function(url,geography_fields){  
  furl <- content(RETRY("GET",url,times=3))
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

# Function for creating block group URL API calls

f.url <- function (ACS_BG_variables,tract) {paste0("https://api.census.gov/data/",ACS_year,"/acs/acs",ACS_product,"?get=NAME,",
                                                   ACS_BG_variables,"&for=block%20group:*&in=state:",state,"%20county:","001",
                                                   "%20tract:",tract,"&key=",key)}

# 

for(i in 1:3){                     #length(tracts_vector)) {
  if (i==1) {
    first_df <- f.data(f.url(ACS_BG_variables1,tracts_vector[i]),4)
  }
  else if (i==2) {
    temp_df <- f.data(f.url(ACS_BG_variables1,tracts_vector[i]),4)
    bg_df1 <- rbind(first_df,temp_df)
  }
  else {
    temp_df <- f.data(f.url(ACS_BG_variables1,tracts_vector[i]),4)
    bg_df1 <- rbind(bg_df1,temp_df)
  }
}

for(i in 1:3){                     #length(tracts_vector)) {
  if (i==1) {
    first_df <- f.data(f.url(ACS_BG_variables2,tracts_vector[i]),4)
  }
  else if (i==2) {
    temp_df <- f.data(f.url(ACS_BG_variables2,tracts_vector[i]),4)
    bg_df2 <- rbind(first_df,temp_df)
  }
  else {
    temp_df <- f.data(f.url(ACS_BG_variables2,tracts_vector[i]),4)
    bg_df2 <- rbind(bg_df2,temp_df)
  }
}


for(i in 1:3){                     #length(tracts_vector)) {
  if (i==1) {
    first_df <- f.data(f.url(ACS_BG_variables3,tracts_vector[i]),4)
  }
  else if (i==2) {
    temp_df <- f.data(f.url(ACS_BG_variables3,tracts_vector[i]),4)
    bg_df3 <- rbind(first_df,temp_df)
  }
  else {
    temp_df <- f.data(f.url(ACS_BG_variables3,tracts_vector[i]),4)
    bg_df3 <- rbind(bg_df3,temp_df)
  }
}

ACS_BG_preraw <- cbind(bg_df1,bg_df2,bg_df3)

trial <- bg_df1 %>%
  #names(bg_df1) <- str_replace_all(names(bg_df1), c(" " = "_")) %>% # Remove space in variable name, "block group" to "block_group"
  mutate(
    concat = paste0(state,county,tract,block_group))

trial2 <- trial %>%
  arrange(concat)

vector <- unique (trial2$concat)

write.csv(trial2, "C:/Files for Deletion/Block Group Vars.csv", row.names = FALSE, quote = T)

some_function_that_may_fail <- function() {
  if( runif(1) < .5 ) stop()
  return(1)
}

r <- NULL
attempt <- 1
while( is.null(r) && attempt <= 3 ) {
  attempt <- attempt + 1
  try(
    r <- some_function_that_may_fail()
  )
} 


f.data <- function(url,geography_fields){  
  furl <- content(RETRY("GET",url,times=5))
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
  for(j in 2:(ncol(output_data)-geography_fields)) {
    output_data[,j] <- as.numeric(output_data[,j])
  }
  return (output_data)
}

write.csv(bg_df1, "TAZ1454 Block Group Vars1.csv", row.names = FALSE, quote = T)
write.csv(bg_df2, "TAZ1454 Block Group Vars2.csv", row.names = FALSE, quote = T)
write.csv(bg_df3, "TAZ1454 Block Group Vars3.csv", row.names = FALSE, quote = T)
