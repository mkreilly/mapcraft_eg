# badata

This repository contains land use data for the Metropolitan Transportation Commission.  The primary data sources at this time are:

* Parcel data by county
* General plan data by jurisdiction

The directory structure maintains one county directory for each of the 9 counties, and a jurisdictional directory for each city and unincorporated county.  The parcel data for each county is kept inside the county level directory, and the general plan data for each jurisdiction is kept inside each jurisdictional directory.  A list of counties and jurisdictions is keps in the top level of this repository in [cities_and_counties.yaml](https://github.com/oaklandanalytics/badata/blob/master/cities_and_counties.yaml).

The parcel data is stored using git large file support - to get the files you need to install [git lfs](https://git-lfs.github.com/) and run git pull.

Because the general plan data is smaller, it is stored in geojson format.  Each geojson file contains one attribute, which is `general_plan_name`, this name and the jurisdiction name define a unique record in [zoning_lookup.csv]() which defined the attributes for each general plan designation.
