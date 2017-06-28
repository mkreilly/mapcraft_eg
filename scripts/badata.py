import argparse
import yaml
import glob
import geopandas as gpd
import pandas as pd


cities_and_counties = yaml.load(open("cities_and_counties.yaml"))

# read all the general plan spatial data in and merge it
def merge_gp_spatial_data(cities_and_counties, path_format="{}/{}/*.geojson"):
    gdfs = []
    for county, cities in cities_and_counties.items():
        for city in cities:
            for geojson in glob.glob(path_format.format(county, city)):
                print geojson
                gdf = gpd.GeoDataFrame.from_file(geojson)
                gdf["city"] = city
                gdfs.append(gdf)

    return gpd.GeoDataFrame(pd.concat(gdfs))


# we store general plan data in a set of shapefiles and zoning attribuets in a csv
# this method tells us which join keys are missing from each dataset
def diagnose_merge(df, gdf):
    print "Number of records in zoning data that have a shape to join to:"
    df["zoning_id"] = df.id  # need to rename so names don't clash in merge
    df["city"] = df.city.str.upper().replace('ST. HELENA', 'SAINT HELENA')
    df["name"] = df.name.str.upper()
    gdf["city"] = gdf.city.str.upper().str.replace('_', ' ')
    df["city"] = df.city.apply(lambda n: n if "COUNTY" not in n else
        "UNINCORPORATED " + n.replace(" COUNTY", ""))
    gdf["general_plan_name"] = gdf.general_plan_name.str.upper()

    df["name"] = df.name.str.replace(r'^[0-9][0-9][0-9] - ', '')
    gdf["general_plan_name"] = gdf.general_plan_name.str.replace(r'^[0-9][0-9][0-9] - ', '')

    df2 = pd.merge(df, gdf,
                   left_on=["city", "name"],
                   right_on=["city", "general_plan_name"])
    print df2.columns
    missing = df[~df.zoning_id.isin(df2.zoning_id)]
    print "{} missing zoning ids (data written to missing_zoning_ids.csv".\
        format(len(missing))
    missing.to_csv("missing_zoning_ids.csv", index=False)


parser = argparse.ArgumentParser(description='Run capacity calculator.')

parser.add_argument('--mode', action='store', dest='mode',
                    help='which mode to run (see code for mode options)')

options = parser.parse_args()

MODE = options.mode

if MODE == "merge_gp_data":
    print "Reading geojson data by juris"
    gdf = merge_gp_spatial_data(cities_and_counties)
    print "Writing general plan data as shapefile"
    gdf.to_csv("merged_general_plan_data.csv")

elif MODE == "diagnose_merge":
    print "Reading gp data"
    gdf = pd.read_csv("merged_general_plan_data.csv")
    print gdf.head(1).transpose()
    print gdf.columns
    df = pd.read_csv("zoning_lookup.csv")
    df2 = pd.read_csv("2015_12_21_zoning_parcels.csv")
    print len(df)
    df = df[df.id.isin(df2.zoning_id)]  # drop rows which aren't linked to parcels
    df["Parcel Count"] = df2.zoning_id.value_counts().loc[df.id].values
    df.to_csv("foo.csv")
    print len(df)
    diagnose_merge(df, gdf)
