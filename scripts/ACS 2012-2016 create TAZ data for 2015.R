
# ACS 2012-2016 create TAZ data for 2015.R
# Create "2015" TAZ data from ACS 2012-2016 PUMS files in r format
# SI
# October 26, 2018

# Import Libraries

suppressMessages(library(dplyr))
library(tidycensus)

# Set up directories, import TAZ/block equivalence, install census key, set ACS year,set CPI deflation

wd <- "C:/Users/sisrae/Documents/GitHub/petrale/output/"
setwd(wd)
blockTAZ2010 <- "M:/Data/GIS layers/TM1_taz_census2010/block_to_TAZ1454.csv"
censuskey <- readLines("H:/Census/API.txt")
baycounties <- c("01","13","41","55","75","81","85","95","97")
census_api_key(censuskey, install = TRUE, overwrite = TRUE)
ACS_year <- 2016
CPI_current <- 266.34  # CPI value for 2016
CPI_reference <- 180.20 # CPI value for 2000
CPI_ratio <- CPI_current/CPI_reference # 2000 CPI/2016 CPI

# Income table - Guidelines for HH income values used from ACS
"

    2000 income breaks 2016 equivalent   Nearest ACS breakpoint
    ------------------ ---------------   ----------------------
    $30,000            $44,341           $45,000
    $60,000            $88,681           $88,681* 
    $100,000           $147,802          $150,000
    ------------------ ---------------   ----------------------

    * Because the 2016 equivalent doesn't closely align with income categories, the $75,000-$99,999 
      category will have households split between categories. Using the ACS 2012-2016 PUMS data, the 
      share of households above $88,681 within the 75,000-99,999 category was calculated to be 0.4155574.

Household Income Category Equivalency, 2000$ and 2016$

          Year      Lower Bound     Upper Bound
          ----      ------------    -----------
HHINCQ1   2000      $-inf           $29,999
          2016      $-inf           $44,999
HHINCQ2   2000      $30,000         $59,999
          2016      $45,000         $88,680
HHINCQ3   2000      $60,000         $99,999
          2016      $88,681         $149,999
HHINCQ4   2000      $100,000        $inf
          2016      $150,000        $inf
          ----      -------------   -----------
"
shareabove88681 <- 0.4155574 # Use this value to later divvy up HHs in the 30-60k and 60-100k respective quartiles

# Import ACS library for variable inspection

ACS_table <- load_variables(year=2016, dataset="acs5", cache=TRUE)

# Set up ACS variables for later API download

ACS_BG_variables <- c(tothh = "B25009_001",
                      totpop = "B01003_001",
                      hhpop = "B11002_001",
                      gqpop = "B09019_038",
                   
                      employed = "B23025_004",     # Employed residents is "employed" + "armed forces", summed in later step
                      armedforces = "B23025_006", 
                   
                      hhinc0_10 = "B19001_002",    # Income categories collapsed in later step
                      hhinc10_15 = "B19001_003",
                      hhinc15_20 = "B19001_004",
                      hhinc20_25 = "B19001_005",
                      hhinc25_30 = "B19001_006",
                      hhinc30_35 = "B19001_007",
                      hhinc35_40 = "B19001_008",
                      hhinc40_45 = "B19001_009",
                      hhinc45_50 = "B19001_010",
                      hhinc50_60 = "B19001_011",
                      hhinc60_75 = "B19001_012",
                      hhinc75_100 = "B19001_013",
                      hhinc100_125 = "B19001_014",
                      hhinc125_150 = "B19001_015",
                      hhinc150_200 = "B19001_016",
                      hhinc200p = "B19001_017",
                   
                      male0_4 = "B01001_003",      # Ages and sexes collapsed in later step
                      male5_9 = "B01001_004",
                      male10_14 = "B01001_005",
                      male15_17 = "B01001_006",
                      male18_19 = "B01001_007",
                      male20 = "B01001_008",
                      male21 = "B01001_009",
                      male22_24 = "B01001_010",
                      male25_29 = "B01001_011",
                      male30_34 = "B01001_012",
                      male35_39 = "B01001_013",
                      male40_44 = "B01001_014",
                      male45_49 = "B01001_015",
                      male50_54 = "B01001_016",
                      male55_59 = "B01001_017",
                      male60_61 = "B01001_018",
                      male62_64 = "B01001_019",
                      male65_66 = "B01001_020",
                      male67_69 = "B01001_021",
                      male70_74 = "B01001_022",
                      male75_79 = "B01001_023",
                      male80_84 = "B01001_024",
                      male85p = "B01001_025",
                      female0_4 = "B01001_027",
                      female5_9 = "B01001_028",
                      female10_14 = "B01001_029",
                      female15_17 = "B01001_030",
                      female18_19 = "B01001_031",
                      female20 = "B01001_032",
                      female21 = "B01001_033",
                      female22_24 = "B01001_034",
                      female25_29 = "B01001_035",
                      female30_34 = "B01001_036",
                      female35_39 = "B01001_037",
                      female40_44 = "B01001_038",
                      female45_49 = "B01001_039",
                      female50_54 = "B01001_040",
                      female55_59 = "B01001_041",
                      female60_61 = "B01001_042",
                      female62_64 = "B01001_043",
                      female65_66 = "B01001_044",
                      female67_69 = "B01001_045",
                      female70_74 = "B01001_046",
                      female75_79 = "B01001_047",
                      female80_84 = "B01001_048",
                      female85p = "B01001_049",
                   
                      unit1d = "B25024_002",       # Single and multi-family DUs collapsed in later step
                      unit1a = "B25024_003",
                      unit2 = "B25024_004",
                      unit3_4 = "B25024_005",
                      unit5_9 = "B25024_006",
                      unit10_19 = "B25024_007",
                      unit20_49 = "B25024_008",
                      unit50p = "B25024_009",
                      mobile = "B25024_010",
                      boat_RV_Van = "B25024_011",
                   
                      own1 = "B25009_003",        # Household size collapsed across tenure in later step
                      own2 = "B25009_004",
                      own3 = "B25009_005",
                      own4 = "B25009_006",
                      own5 = "B25009_007",
                      own6 = "B25009_008",
                      own7p = "B25009_009",
                      rent1 = "B25009_011",
                      rent2 = "B25009_012",
                      rent3 = "B25009_013",
                      rent4 = "B25009_014",
                      rent5 = "B25009_015",
                      rent6 = "B25009_016",
                      rent7p = "B25009_017")
                   
        
ACS_tract_variables <-c(hhwrks0 = "B08202_002",     # Households by number of workers
                        hhwrks1 = "B08202_003",
                        hhwrks2 = "B08202_004",
                        hhwrks3p = "B08202_005",
                   
                        ownkidsyes = "B25012_003",  # Presence of related kids under 18
                        rentkidsyes = "B25012_011", 
                        ownkidsno = "B25012_009",
                        rentkidsno = "B25012_017"
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


ACS_BG_raw <- get_acs(geography = "block group", variables = ACS_BG_variables,
                 state = "06", county=baycounties,
                 year=ACS_year,
                 output="wide",
                 survey = "acs5")

ACS_tract_raw <- get_acs(geography = "tract", variables = ACS_tract_variables,
                      state = "06", county=baycounties,
                      year=ACS_year,
                      output="wide",
                      survey = "acs5")

#write.csv(sum.commuters15, paste0(SUMMARY_OUT,"PUMS",Year,"_Inter_regional_commuters.csv"), row.names = FALSE, quote = T)

summary(ACS_tract_raw)
