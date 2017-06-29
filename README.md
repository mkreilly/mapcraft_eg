# badata

This repository contains land use data for the Metropolitan Transportation Commission.  The primary data sources at this time are:

* Parcel data by county
* General plan data by jurisdiction

The directory structure maintains one county directory for each of the 9 counties, and a jurisdictional directory for each city and unincorporated county.  A list of counties and jurisdictions is kept in the top level of this repository in [cities_and_counties.yaml](https://github.com/oaklandanalytics/badata/blob/master/cities_and_counties.yaml).

### Parcel Data

The parcel data is stored using git large file support - to get the files you need to install [git lfs](https://git-lfs.github.com/) and run `git lfs pull`.  There are two zip files in each county directory.  The [county]_geom.zip is a zipped shapefile of parcel shapes and a unique identifer.  [county].zip is a csv file of all the attributes associated with each parcel (which joins to the shapes using the same unique identifier).  These include:

* gid - unique identifier of parcels
* county_id - the county name
* apn - the unique parcel identifier
* land_use_type_id - ???
* res_type - whether single or multi family (string "multi" or "single")
* land_value - the last assessed land value
* improvement_value - the last assessed improvement value
* year_assessed - the year assessed
* year_built - the year the property was built
* building_sqft - total building square footage
* non_residential_sqft - non-residential square footage
* residential_units - the number of residential units
* stories - the number of stories of the building
* tax_exempt - whether the parcel is tax exempt (either 0 or 1)
* condo_identifier - not used
* imputation_flag - not used
* development_type_id - not used
* calc_area - the area of the parcel

### General Plan Data

Because the general plan data is smaller, it is stored in geojson format.  Each geojson file contains one attribute, which is `general_plan_name`, this name combined with the jurisdiction name defines a unique record in [zoning_lookup.csv](https://github.com/oaklandanalytics/badata/blob/master/zoning_lookup.csv) which gives the attributes for each general plan designation.  All of the general plan attributes are kept in the file linked above which allows editing of general plan attributes easily in one place in a trivial file format.  This also allows us to maintain history from the use of this file in the Plan Bay Area 2040 planning process.

Attributes in the zoning_lookup.csv file are:

* city - the jurisdiction the row came from
* max_far - maximum floor area ratio in the zone
* max_height - maximum height in the zone
* max_dua - maximum dwelling units per acre in the zone
* max_du_per_parcel - maximum dwelling units per parcel (overrides max_dua)
* and a column per building type which identifies if that building type is allowed in this zone (see building type list below)

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
