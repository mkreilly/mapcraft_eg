
# ACS 2012-2016 create TAZ data for 2015.R
# Create "2015" TAZ data from ACS 2012-2016 PUMS files in r format
# SI
# October 24, 2018

# Import Libraries

suppressMessages(library(dplyr))
library(tidycensus)

# Set up directories and variables, import TAZ/block equivalence, install census key, set ACS year, set CPI deflation

wd <- "C:/Users/sisrae/Documents/GitHub/petrale/output/"
setwd(wd)
blockTAZ2010 <- "M:/Data/GIS layers/TM1_taz_census2010/block_to_TAZ1454.csv"
censuskey <- readLines("H:/Census/API.txt")
baycounties <- c("01","13","41","55","75","81","85","95","97")
census_api_key(censuskey, install = TRUE, overwrite = TRUE)
ACS_year <- 2016
CPI_current <- 266.34  # CPI value for 2016
CPI_reference <- 180.20 # CPI value for 2000
CPI_ratio <- CPI_reference/CPI_current # 2000 CPI/2016 CPI

# Income table - Guidelines for HH income values used from ACS

    # 2000 income breakpoints       2016 equivalent   Nearest ACS breakpoint
    # $30,000                       $44,341           $45,000
    # $60,000                       $88,681           $100,000
    # $100,000                      $147,802          $150,000

# Import ACS library for variable inspection

ACS_table <- load_variables(year=2016, dataset="acs5", cache=TRUE)

# Set up ACS variables for later API download

ACS_variables <- c(TOTHH = "B25009_001",
                   TOTPOP = "B01003_001",
                   HHPOP = "B11002_001",
                   GQPOP = "B26001_001E",
                   employed = "B23025_004",           # Employed residents is "employed" + "armed forces", summed below
                   armedforces = "B23025_006", 
                   hhinc0_10 = "B19001_",
                   hhinc10_15 = "B19001_",
                   hhinc15_20 = "B19001_",
                   hhinc20_25 = "B19001_",
                   hhinc25_30 = "B19001_",
                   hhinc30_35 = "B19001_",
                   hhinc35_40 = "B19001_",
                   hhinc40_45 = "B19001_",
                   hhinc45_50 = "B19001_",
                   hhinc50_60 = "B19001_",
                   hhinc60_75 = "B19001_",
                   hhinc75_100 = "B19001_",
                   hhinc100_125 = "B19001_",
                   hhinc125_150 = "B19001_",
                   hhinc150_200 = "B19001_",
                   hhinc200p = "B19001_",
                   
                   )



# Bring in 2010 block/TAZ equivalency, create block group ID field for later joining

blockTAZ <- read.csv(blockTAZ2010,header=TRUE) %>% mutate(      
  blockgroup = paste0("0",substr(GEOID10,1,11))) 


blockTAZBG <- blockTAZ %>% 
  group_by(blockgroup) %>%
  summarize(BGTotal=sum(block_POPULATION))

combined_block <- left_join(blockTAZ,blockTAZBG,by="blockgroup") %>% mutate(
  sharebg=if_else(block_POPULATION==0,0,block_POPULATION/BGTotal)
)


trial <- get_acs(geography = "block group", variables = ACS_variables,
                 state = "06", county=baycounties,
                 year=ACS_year,
                 output="wide",
                 survey = "acs5")

write.csv(sum.commuters15, paste0(SUMMARY_OUT,"PUMS",Year,"_Inter_regional_commuters.csv"), row.names = FALSE, quote = T)

