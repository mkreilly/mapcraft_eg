# BASIS

This repository contains land use data and related code for Bay Area Metro. The major categories of data and code (equivalent to the directory structure above) are:

* basemap: information on the current state of buildings and their inhabitants
* control totals: region-wide forecasts for households and employment
* deed restricted units: a database of current housing with low income residency requirements
* institutions: a current and forecast database of large entities (e.g., universities, hospitals) and group quarters
* pipeline: a list of building projects recently completed, under construction, or approved
* policies: information on local and regional land use policies
* scripts: code to modify or integrate datasets
* tests: code to assure the validity of database changes
* zones: various boundary files and related data for TAZs, MAZs, Jurisdictions, PDAs, etc

BASIS is the working name for Bay Area Metro's land use and urban economics database. It stands for Bay Area Spatial Information System, the same name used by ABAG in the 1970's for the region's first digital geographic information system.

Questions should be directed to:
* Cynthia Kroll on control totals and policies: ckroll@bayareametro.gov
* Kearey Smith on the pipeline: ksmith@bayareametro.gov
* Michael Reilly on the basemap or other topics: mreilly@bayareametro.gov


-----------------------------


The directory structure maintains one county directory for each of the 9 counties, and a jurisdictional directory for each city and unincorporated county.  A list of counties and jurisdictions is kept in the top level of this repository in [cities_and_counties.yaml](https://github.com/oaklandanalytics/badata/blob/master/zones/cities_and_counties.yaml).



### Building Types

* HS - single family residential
* HT - townhomes
* HM - multi family residential
* OF - office
* HO - hotel
* SC - school
* IL - light industrial
* IW - warehouse industrial
* IH - heavy industrial
* RS - strip retail
* RB - big box retail
* MR - mixed use residential focused
* MT - 
* ME - mixed use employment focused

### badata.py

`scripts/badata.py` is a script used to operate on this data.  There are several modes of operation (use the --mode command line option), analagous to baus.py in the bayarea_urbansim directory.  The modes include:

* `merge_gp_data` which merges the general plan data from each jurisdiction into a single file (edit the code to pick which output format you'd prefer)
* `diagnose_merge` which is used to find rows in zoning_lookup.csv which are currently assigned to parcels, which do not occur in the general plan shapefiles.  There are currently about 190 rows which are missing which are written to [missing_zoning_ids.csv](https://github.com/oaklandanalytics/badata/blob/master/missing_zoning_ids.csv) - this csv includes an attribute "Parcel Count" which is the number of parcels which have that id.  These missing shapes are an issue because these zones will not be assigned in future merges of the parcels and general plan shapes.
