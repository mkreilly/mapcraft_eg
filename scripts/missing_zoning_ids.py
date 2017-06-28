import pandas as pd
import geopandas as gpd

baus_zoning_ids = pd.read_csv("zoning_lookup.csv")
utilized_zoning_ids = pd.read_csv("utilized_zoning_ids.csv")

utilized_zoning_ids = utilized_zoning_ids[utilized_zoning_ids["count"] > 1]

baus_zoning_ids = baus_zoning_ids[baus_zoning_ids.id.isin(utilized_zoning_ids.zoning_id)]

print "{} utilized zoning ids".format(len(baus_zoning_ids))

found_zoning_ids = pd.read_csv("zoning_records.csv")

alameda = gpd.GeoDataFrame.from_file("unincorporated_alameda_plu.shp")
alameda["city"] = "UNINCORPORATED ALAMEDA"
alameda["JOINKEY"] = alameda.city + "___" + alameda.ORIGGPLU.str.upper()

santa_clara = gpd.GeoDataFrame.from_file("unincorporated_santa_clara_plu.shp")
santa_clara["city"] = "SANTA CLARA COUNTY"
santa_clara["JOINKEY"] = santa_clara.city + "___" + santa_clara.GEN_PLAN.str.upper()

solano = gpd.GeoDataFrame.from_file("unincorporated_solano_plu.shp")
solano["city"] = "SOLANO COUNTY"
solano["FULL_NAME"] = solano.FULL_NAME.map({
	"Medium (8 to 15 units per acre)": "MEDIUM DENSITY RESIDENTIAL (8 TO 15 UNITS PER ACRE)",
	"Rural (2.5 to 10 acres per unit)": "RURAL RESIDENTIAL (2.5 TO 10 ACRES PER UNIT)"
}).fillna(solano.FULL_NAME)
solano["JOINKEY"] = solano.city + "___899 - " + solano.FULL_NAME.str.upper()
print solano.JOINKEY

contra_costa = gpd.GeoDataFrame.from_file("unincorporated_contra_costa.shp")
contra_costa["city"] = "CONTRA COSTA COUNTY"
contra_costa["GP_TEXT"] = contra_costa.GP_TEXT.map({
	"Multiple-Family Residential - High Density": "MULTIPLE FAMILY RESIDENTIAL - HIGH",
	"Multiple-Family Residential - Medium Density": "MULTIPLE FAMILY RESIDENTIAL - MEDIUM",
	"Multiple-Family Residential - Low Density": "MULTIPLE FAMILY RESIDENTIAL - LOW",
	"Single-Family Residential - High Density": "Single FAMILY RESIDENTIAL - HIGH",
	"Single-Family Residential - Medium Density": "Single FAMILY RESIDENTIAL - MEDIUM",
	"Single-Family Residential - Low Density": "Single FAMILY RESIDENTIAL - LOW",
	"Single-Family Residential - Very Low Density": "Single FAMILY RESIDENTIAL - VERY LOW",
	"Public and Semi-Public": "PUBLIC/SEMI-PUBLIC",
	"Agricultural Lands and Off-Island Bonus Area": "AGRICULTURAL LANDS & OFF ISLAND BONUS AREA"

}).fillna(contra_costa.GP_TEXT)
contra_costa["JOINKEY"] = contra_costa.city + "___299 - " + contra_costa.GP_TEXT.str.upper()


vallejo = gpd.GeoDataFrame.from_file("vallejo_plu.shp")
vallejo["JOINKEY"] = vallejo.JURIS.str.upper() + "___" + vallejo.ORIGGPLU.str.upper()

for col in ["city", "name"]:
	baus_zoning_ids[col] = baus_zoning_ids[col].str.upper()
	found_zoning_ids[col] = found_zoning_ids[col].str.upper()

found_zoning_ids["city"] = found_zoning_ids.city.str.replace('_', ' ')

baus_zoning_ids["JOINKEY"] = baus_zoning_ids.city + "___" + baus_zoning_ids.name
found_zoning_ids["JOINKEY"] = found_zoning_ids.city + "___" + found_zoning_ids.name

missing_zoning_ids = baus_zoning_ids[
	~baus_zoning_ids.JOINKEY.isin(found_zoning_ids.JOINKEY)]

missing_zoning_ids = missing_zoning_ids[
	~missing_zoning_ids.JOINKEY.isin(alameda.JOINKEY)]

missing_zoning_ids = missing_zoning_ids[
	~missing_zoning_ids.JOINKEY.isin(santa_clara.JOINKEY)]

missing_zoning_ids = missing_zoning_ids[
	~missing_zoning_ids.JOINKEY.isin(contra_costa.JOINKEY)]

missing_zoning_ids = missing_zoning_ids[
	~missing_zoning_ids.JOINKEY.isin(solano.JOINKEY)]

missing_zoning_ids = missing_zoning_ids[
	~missing_zoning_ids.JOINKEY.isin(vallejo.JOINKEY)]

missing_zoning_ids.to_csv("missing.csv")

print missing_zoning_ids.city.value_counts()
