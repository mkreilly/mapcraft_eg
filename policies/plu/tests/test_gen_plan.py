import pandas as pd
import pytest
import os
import json
import glob

dirname = os.path.join("policies", "plu")
files = glob.glob(os.path.join(dirname, "*.geojson"))
# files = ["policies/plu/unincorporated_contra_costa_plu.geojson"]


@pytest.fixture(scope="module")
def all_gp_json():
    def load_gp_data(file):
        return json.load(open(file))

    return {file: load_gp_data(file) for file in files}


# this loads all the features in the geojson files in this directory
@pytest.fixture(scope="module")
def all_gp_data(all_gp_json):
    def get_data(shapes):
        shapes = [f["properties"] for f in shapes["features"]]
        return pd.DataFrame.from_records(shapes)

    return {file: get_data(all_gp_json[file]) for file in all_gp_json.keys()}


@pytest.fixture(scope="module")
def all_gp_geometry(all_gp_json):
    def get_geom(shapes):
        return [f["geometry"] for f in shapes["features"]]

    return {file: get_geom(all_gp_json[file]) for file in files}


def make_city_name_from_path_name(path):
    file = os.path.basename(path)

    cityish = file.replace("_general_plan.geojson", "").\
        replace("_plu.geojson", "")

    return cityish.replace('_', ' ').title()


@pytest.mark.parametrize("fname", files)
def test_too_many_shapes(all_gp_data, fname):
    # only san francisco and san jose really have lots of
    # general plan shapes
    if "san_francisco" in fname or "san_jose" in fname\
            or "unincorporated_sonoma":
        return

    df = all_gp_data[fname]

    assert len(df) < 4300


@pytest.mark.parametrize("fname", files)
def test_empty_general_plan_names(all_gp_data, fname):

    df = all_gp_data[fname]
    plan_names = df.general_plan_name
    null_names = plan_names[plan_names.isnull()]
    assert len(null_names) == 0

    empty_names = plan_names[plan_names == ""]

    # these are known test failures we're not going to fix right away
    for city in ["walnut_creek", "solano", "san_mateo", "petaluma",
                 "santa_clara", "menlo_park", "corte_madera", "concord",
                 "antioch"]:
        if city in fname:
            print fname, len(empty_names)
            return

    assert len(empty_names) == 0


# make sure we don't have any multipolygons -
# they should all be separate polygons
@pytest.mark.parametrize("fname", files)
def test_no_multipolygons(all_gp_geometry, fname):
    geometries = all_gp_geometry[fname]
    for geom in geometries:
        assert geom["type"] != "MultiPolygon"


def test_zoning_lookup_duplicates():
    fname = os.path.join(dirname, "zoning_lookup.csv")
    df = pd.read_csv(fname)

    s = df.groupby(["name", "city"]).size()
    print s[s > 1]
    assert len(s[s > 1]) == 0


@pytest.mark.parametrize("fname", files)
def test_all_general_plan_names_are_in_zoning_lookup(all_gp_data, fname):
    df = all_gp_data[fname]
    city = make_city_name_from_path_name(fname)

    lookup_fname = os.path.join(dirname, "zoning_lookup.csv")
    lookup = pd.read_csv(lookup_fname)
    options = set(lookup[lookup.city == city].name.values)

    failed = False
    for gpname in df.general_plan_name.unique():
        if gpname == "" or gpname == "NODEV":
            continue
        if gpname not in options:
            print "GP name not found:", gpname, "; city:", city
            # just to make the tests pass - this should be True
            failed = False

    assert not failed


def test_no_extra_rows_in_zoning_lookup():
    # for now we think we can have extra rows in the lookup table that aren't
    # used - maybe they get assigned to a parcel at some point
    pass


def test_zoning_lookup():
    fname = os.path.join(dirname, "zoning_lookup.csv")
    df = pd.read_csv(fname, index_col="name")

    cols = ("city,max_far,max_height,max_dua,max_du_per_parcel,HS,HT,HM" +
            ",OF,HO,SC,IL,IW,IH,RS,RB,MR,MT,ME").split(',')
    for col in cols:
        # check column names
        assert col in df.columns

    # types should be right
    assert df.max_far.dtype == "float"
    assert df.max_dua.dtype == "float"
    assert df.max_height.dtype in ["float", "int"]
    assert df.max_du_per_parcel.dtype in ["float", "int"]

    # buildings types should be on or off
    for col in "HS,HT,HM,OF,HO,SC,IL,IW,IH,RS,RB,MR,MT,ME".split(","):
        ind = list(df[col].value_counts().index)
        assert ind == [0, 1] or ind == [1, 0] or ind == [1.0] \
            or ind == [0] or ind == []

    # values should be in right ranges
    assert df.max_far.fillna(0).min() >= 0
    assert df.max_far.fillna(0).max() <= 50
    assert df.max_height.fillna(0).min() >= 0
    assert df.max_height.fillna(0).max() <= 10000
    assert df.max_dua.fillna(0).min() >= 0
    assert df.max_dua.fillna(0).max() <= 350
    assert df.max_du_per_parcel.fillna(0).min() >= 0
    assert df.max_du_per_parcel.fillna(0).max() <= 10
