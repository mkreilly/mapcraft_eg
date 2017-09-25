# Demographics in BAM's Regional Modeling Suite

Demographics are the characteristics of households and persons in the modeling suite. This information moves through all three major models:
* REMI and associated regional demograpics model produce region-wide data such as the count of households by type and the count of person by age category
* Bay Area UrbanSim Two forecasts the movement of different types of households within the region
* The Population Synthesizer takes info from 
* Bay Area Travel Model Two 



## Geographies
REMI and the associated demographics models pass their data to UrbanSim at the regional level.

BAUST creates 



## Census Data

Block group data (basis for the new TAZ system) is released for the 5-year estimate. The 5-year release (2013-2017) will be the census control for RTP21. It should be released on Dec 7, 2018. Until then, we will use the most up-to-date release (same time every year). 


## Flow
REMI and associated regional models produce two tables of regional level demographic data to send to BAUST and/or BATMT:
* household_controls
* regional_controls

Each five-year period BAUST is run, the model ensures that the total household count by type is the same as represented in the control totals. At the end of the forecast, two demographic data flows are summarized at the MAZ level and passed to both the Population Synthesizer and BATMT:
* household count by type
* other households and persons forecasts produced by associated scripts for data in the regional_controls file that is not explicitly used in BAUST

The Population Synthesizer is run to build an artificial population that:
* conforms to the household count from BAUST (and thus is also consistent with the regional control counts)
* is similar to the other demographic forecasts caried through from the regional models
* is similar to the households structure of households within that location's PUMA

Popsyn has been used to date with Travel Model One. The plan has been to shift to popsyn3 for use with Travel Model Two. Popsyn3 tracks demographics on multiple geographic scales. To date:
* total hhs in a maz (super important weight)
* income category by taz
* hh size categories by county
* worker count by county
* person age category by county
* person occupation by county

Two microsimulation tables come out of the Population Synthesizer:
* household file: one row with attributes for each household, located in a MAZ
* persons file: one row with attributes for each person, located in a household

BATMT is run on these two files. Persons make choices based on their own and their household's attribute. People in the same household my coordinate. The most important demographic factors influencing travel behavior include:
* income
* relationship between worker count and auto count in a household
* mandatory trip status (worker vs student vs other)
* presence of children
