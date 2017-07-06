import geopandas as gpd

# throw away script to convert plu data from crs 3740 to 4326

files = [
	"./alameda/unincorporated_alameda/unincorporated_alameda_plu.geojson",
	"./contra_costa/richmond/richmond_general_plan_plu.geojson",
	"./contra_costa/unincorporated_contra_costa/unincorporated_contra_costa_plu.geojson",
	"./santa_clara/unincorporated_santa_clara/unincorporated_santa_clara_plu.geojson",
	"./solano/unincorporated_solano/unincorporated_solano_plu.geojson",
	"./solano/vallejo/vallejo_plu.geojson"
]

for file in files:
	print file
	gdf = gpd.GeoDataFrame.from_file(file)
	gdf.crs = {'init' :'epsg:26910'}
	gdf = gdf.to_crs({'init' :'epsg:4326'})
	open(file, "w").write(gdf.to_json())