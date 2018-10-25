
# ACS 2012-2016 create TAZ data for 2015.R
# Create "2015" TAZ data from ACS 2012-2016 
# SI
# October 25, 2018

# Notes
"

1. ACS data here is downloaded for the 2012-2016 5-year dataset. The end year can be updated 
   by changing the *ACS_year* variable. 

2. ACS block group variables used in all instances where not suppressed. If suppressed at the block group 
   level, tract-level data used instead. Suppressed variables may change if ACS_year is changed. This 
   should be checked, as this change could cause the script not to work.

"
# Import Libraries

suppressMessages(library(dplyr))
library(tidycensus)

# Set up directories, import TAZ/block equivalence, install census key, set ACS year,set CPI inflation

wd <- "C:/Users/sisrae/Documents/GitHub/petrale/output/"
setwd(wd)

blockTAZ2010 <- "M:/Data/GIS layers/TM1_taz_census2010/block_to_TAZ1454.csv"
censuskey <- readLines("H:/Census/API.txt")
baycounties <- c("01","13","41","55","75","81","85","95","97")
census_api_key(censuskey, install = TRUE, overwrite = TRUE)

ACS_year <- 2016
CPI_current <- 266.34  # CPI value for 2016
CPI_reference <- 180.20 # CPI value for 2000
CPI_ratio <- CPI_current/CPI_reference # 2016 CPI/2000 CPI

# Income table - Guidelines for HH income values used from ACS
"

    2000 income breaks 2016 CPI equivalent   Nearest 2016 ACS breakpoint
    ------------------ -------------------   ---------------------------
    $30,000            $44,341               $45,000
    $60,000            $88,681               $88,681* 
    $100,000           $147,802              $150,000
    ------------------ -------------------   ---------------------------

    * Because the 2016$ equivalent of $60,000 in 2000$ ($88,681) doesn't closely align with 2016 ACS income 
      categories, households within the $75,000-$99,999 category will be apportioned above and below $88,681. 
      Using the ACS 2012-2016 PUMS data, the share of households above $88,681 within the $75,000-$99,999 
      category is 0.4155574.That is, approximately 42 percent of HHs in the $75,000-$99,999 category will be 
      apportioned above this value (Q3) and 58 percent below it (Q2). The table below compares 2000$ and 2016$.

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

# Set up ACS block group and tract variables for later API download. 

ACS_BG_variables <- c(tothh = "B25009_001",        #Total HHs, pop, HH pop, and GQ pop
                      totpop = "B01003_001",
                      hhpop = "B11002_001",
                      gqpop = "B09019_038",
                   
                      employed = "B23025_004",     # Employed residents is "employed" + "armed forces"
                      armedforces = "B23025_006", 
                   
                      #total_income = "B19001_001",
                      hhinc0_10 = "B19001_002",    # Income categories 
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
                   
                      male0_4 = "B01001_003",      # Age data
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
                   
                      unit1d = "B25024_002",       # Single and multi-family dwelling unit data
                      unit1a = "B25024_003",
                      unit2 = "B25024_004",
                      unit3_4 = "B25024_005",
                      unit5_9 = "B25024_006",
                      unit10_19 = "B25024_007",
                      unit20_49 = "B25024_008",
                      unit50p = "B25024_009",
                      mobile = "B25024_010",
                      boat_RV_Van = "B25024_011",
                   
                      own1 = "B25009_003",        # Household size data
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
                   
                        ownkidsyes = "B25012_003",  # Presence of related kids under 18, by tenure
                        rentkidsyes = "B25012_011", 
                        ownkidsno = "B25012_009",
                        rentkidsno = "B25012_017"
                        )

# Bring in 2010 block/TAZ equivalency, create block group ID and tract ID fields for later joining to ACS data

blockTAZ <- read.csv(blockTAZ2010,header=TRUE) %>% mutate(      
  blockgroup = paste0("0",substr(GEOID10,1,11)),
  tract = paste0("0",substr(GEOID10,1,10))) 

# Summarize block population by block group and tract 

blockTAZBG <- blockTAZ %>% 
  group_by(blockgroup) %>%
  summarize(BGTotal=sum(block_POPULATION))
  
blockTAZTract <- blockTAZ %>% 
  group_by(tract) %>%
  summarize(TractTotal=sum(block_POPULATION))

# Create 2010 block share of total population for block/block group and block/tract, append to comnbined_block file
# Be mindful of divide by zero error associated with 0-pop block groups and tracts

combined_block <- left_join(blockTAZ,blockTAZBG,by="blockgroup") %>% mutate(
  sharebg=if_else(block_POPULATION==0,0,block_POPULATION/BGTotal)) 

combined_block <- left_join(combined_block,blockTAZTract,by="tract") %>% mutate(
  sharetract=if_else(block_POPULATION==0,0,block_POPULATION/TractTotal))

# Peform ACS calls for raw block group and tract data

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

# Join 2016 ACS block group and tract variables to combined_block file
# Combine and collapse ACS categories to get land use control totals, as appropriate
# Apply block share of 2016 ACS variables using block/block group and block/tract shares of 2010 total population
# Note that "E" on the end of each variable is appended by tidycensus package to denote "estimate"

workingdata <- left_join(combined_block,ACS_BG_raw, by=c("blockgroup"="GEOID"))
workingdata <- left_join(workingdata,ACS_tract_raw, by=c("tract"="GEOID"))%>% mutate(
  TOTHH=tothhE*sharebg,
  TOTPOP=totpopE*sharebg,
  HHPOP=hhpopE*sharebg,
  GQPOP=gqpopE*sharebg,
  EMPRES=(employedE+armedforcesE)*sharebg,
  HHINCQ1=(hhinc0_10E+
             hhinc10_15E+
             hhinc15_20E+
             hhinc20_25E+
             hhinc25_30E+
             hhinc30_35E+
             hhinc35_40E+
             hhinc40_45E)*sharebg,
  HHINCQ2=(hhinc45_50E+
             hhinc50_60E+
             hhinc60_75E+
             (hhinc75_100E*(1-shareabove88681)))*sharebg, # Apportions HHs below $88,681 within $75,000-$100,000
  HHINCQ3=((hhinc75_100E*shareabove88681)+                # Apportions HHs above $88,681 within $75,000-$100,000
             hhinc100_125E+
             hhinc125_150E)*sharebg,
  HHINCQ4=(hhinc150_200E+hhinc200pE)*sharebg,
  AGE0004=(male0_4E+female0_4E)*sharebg,
  AGE0519=(male5_9E+
             male10_14E+
             male15_17E+
             male18_19E+
             female5_9E+
             female10_14E+
             female15_17E+
             female18_19E)*sharebg,
  AGE2044=(male20E+
             male21E+
             male22_24E+
             male25_29E+
             male30_34E+
             male35_39E+
             male40_44E+
             female20E+
             female21E+
             female22_24E+
             female25_29E+
             female30_34E+
             female35_39E+
             female40_44E)*sharebg,
  AGE4564=(male45_49E+
             male50_54E+
             male55_59E+
             male60_61E+
             male62_64E+
             female45_49E+
             female50_54E+
             female55_59E+
             female60_61E+
             female62_64E)*sharebg,
  AGE65P=(male65_66E+
            male67_69E+
            male70_74E+
            male75_79E+
            male80_84E+
            male85pE+
            female65_66E+
            female67_69E+
            female70_74E+
            female75_79E+
            female80_84E+
            female85pE)*sharebg,
  SFDU=(unit1dE+
          unit1aE+
          mobileE+
          boat_RV_VanE)*sharebg,
  MFDU=(unit2E+
          unit3_4E+
          unit5_9E+
          unit10_19E+
          unit20_49E+
          unit50pE)*sharebg,
  hh_size1=(own1E+rent1E)*sharebg,
  hh_size2=(own2E+rent2E)*sharebg,
  hh_size3=(own3E+rent3E)*sharebg,
  hh_size4_plus=(own4E+
                   own5E+
                   own6E+
                   own7pE+
                   rent4E+
                   rent5E+
                   rent6E+
                   rent7pE)*sharebg,
  hh_wrks_0=hhwrks0E*sharetract,
  hh_wrks_1=hhwrks1E*sharetract,
  hh_wrks_2=hhwrks2E*sharetract,
  hh_wrks_3_plus=hhwrks3pE*sharetract,
  hh_kids_yes=(ownkidsyesE+rentkidsyesE)*sharetract,
  hh_kids_no=(ownkidsnoE+rentkidsnoE)*sharetract
)

# Summarize to TAZ and select only variables of interest, round data to nearest whole number, export csv

final <- workingdata %>%
  group_by(TAZ1454) %>%
  summarize(  TOTHH=sum(TOTHH),
              TOTPOP=sum(TOTPOP),
              HHPOP=sum(HHPOP),
              GQPOP=sum(GQPOP),
              EMPRES=sum(EMPRES),
              HHINCQ1=sum(HHINCQ1),
              HHINCQ2=sum(HHINCQ2),
              HHINCQ3=sum(HHINCQ3),
              HHINCQ4=sum(HHINCQ4),
              AGE0004=sum(AGE0004),
              AGE0519=sum(AGE0519),
              AGE2044=sum(AGE2044),
              AGE4564=sum(AGE4564),
              AGE65P=sum(AGE65P),
              SFDU=sum(SFDU),
              MFDU=sum(MFDU),
              hh_size1=sum(hh_size1),
              hh_size2=sum(hh_size2),
              hh_size3=sum(hh_size3),
              hh_size4_plus=sum(hh_size4_plus),
              hh_wrks_0=sum(hh_wrks_0),
              hh_wrks_1=sum(hh_wrks_1),
              hh_wrks_2=sum(hh_wrks_2),
              hh_wrks_3_plus=sum(hh_wrks_3_plus),
              hh_kids_yes=sum(hh_kids_yes),
              hh_kids_no=sum(hh_kids_no)) 

final_rounded <-final %>%
  mutate_if(is.numeric,round,0)

write.csv(final_rounded, "TAZ1454 2015 Land Use.csv", row.names = FALSE, quote = T)





               