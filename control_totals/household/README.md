# Household Control Totals

The household control totals provide regionwide forecast information on household counts and characterstics in future years. They bring information from the regional models (REMI and demographic model) into UrbanSim. They also provide the only route for moving regional forecast information into the travel model. There are two types of household control totals:

## 1. Unified Household Level Counts
This is the preferred style of household control total. It divides the entire count of households into categories based on their attributes. For example, in PBA40 household were divided into four categories based on (approximate) income quartiles. In the next round, we might categorize households by income (4 categories), size (4), and householder age (3). This would see the entire count of households in each future year divided into 48 categories (or cells in a table). 

This type of categorization has three advantages:
* it aids in understanding the region's composition (as with PUMS data) in that we can talk about the share of large, well-off, middle-aged households as opposed to discussing means across different variables which lack joint-attribute information
* UrbanSim uses the household as the unit of analysis in its location choice models so each category of household will be modeled and tracked separately meaning that the information used to build the categories is explicitly considered in the intra-regional forecast
* the travel model slso uses households (along with persons) as its unit of analysis so this categoriztion does a better job of transmitting regional forecast information through to the travel forecast


## 2. Regional or Group-Specific Characteristics

