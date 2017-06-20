import pandas as pd
import geopandas as gpd
import os
import sys
sys.path.insert(0, ".")
from tests.test_gen_plan import counties


def get_merged_general_plan_data(county):
	# now iterate through general plan shapes and assign general plan names to parcel data
	gen_plan_gdfs = []
	# walk each city
	for city in next(os.walk('%s' % county))[1]:
	    print "Reading general plan:", city
		# read general plan data
	    gen_plan = gpd.GeoDataFrame.from_file('%s/%s/general_plan/%s.geojson' % (county, city, city))
	    gen_plan["city"] = city
	    del gen_plan["id"]
	    gen_plan_gdfs.append(gen_plan)

	# merge all gen plan dfs together
	return pd.concat(gen_plan_gdfs, axis=0).reset_index(drop=True)


def merge_county(county):
	# unzip and read parcel geometry shapesfiles
	shpfile = '%s/%s_parcels_geom.shp' % (county, county)
	if not os.path.exists(shpfile):
		os.system('cd %s ; unzip %s_parcels_geom.zip' % (county, county))
	print "Reading parcel shapefile"
	gdf = gpd.GeoDataFrame.from_file(shpfile)

	# we're going to do a point in polygon, so get centroid
	gdf_centroid = gpd.GeoDataFrame({"gid": gdf.gid}, geometry=gdf.centroid)

	# get general plan data
	gen_plan_gdf = get_merged_general_plan_data(county)

	# spatial join
	joined = gpd.sjoin(gdf_centroid, gen_plan_gdf, how="left", op='within')
	# in many degenerate cases we join to multiple general plans
	# XXX resolve general plan assignment priority in those cases
	return joined.drop_duplicates("gid")


# convert geodataframe to dataframe
def gdf_to_df(gdf):
	df = pd.DataFrame()
	for col in gdf.columns:
		if col != "geometry":
			df[col] = gdf[col]
	return df


parcels_and_gen_plans = []
for county in counties:
	print county
	gdf = merge_county(county)
	print gdf.head()
	df = gdf_to_df(gdf)
	print df.head()
	parcels_and_gen_plans.append(gdf)

pd.concat(parcels_and_gen_plans, axis=0).to_csv("parcel_general_plan_merge.csv", index=False)