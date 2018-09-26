# BASIS

* General plan data by jurisdiction

The directory structure maintains one county directory for each of the 9 counties, and a jurisdictional directory for each city and unincorporated county.  A list of counties and jurisdictions is kept in the top level of this repository in [cities_and_counties.yaml](https://github.com/oaklandanalytics/badata/blob/master/cities_and_counties.yaml)(Dead Link).


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

We categorize existing, allowed, and future buildings into 14 types.

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
