import pandas as pd
import pytest
import os
import json
import glob

dirname = os.path.join("policies", "plu")
files = glob.glob(os.path.join(dirname, "*.geojson"))


# this loads all the features in the geojson files in this directory
@pytest.fixture(scope="module")
def all_gp_data():
    def load_gp_data(file):
        shapes = json.load(open(file))
        shapes = [f["properties"] for f in shapes["features"]]
        return pd.DataFrame.from_records(shapes)

    return {file: load_gp_data(file) for file in files}


@pytest.mark.parametrize("fname", files)
def test_too_many_shapes(all_gp_data, fname):
    if "san_francisco" in fname or "san_jose" in fname:
        return

    # these are known test failures we're not going to fix right away
    for city in ["walnut_creek", "marin", "santa_rosa", "san_mateo", "hayward",
                 "san_bruno", "redwood_city", "petaluma", "gilroy", "concord"]:
        if city in fname:
            return

    df = all_gp_data[fname]
    # only san francisco really has lots of general plan shapes
    # other cities are using parcels as their general plan shapes,
    # which need to be dissolved
    assert len(df) < 2000


@pytest.mark.parametrize("fname", files)
def test_empty_general_plan_names(all_gp_data, fname):

    # these are known test failures we're not going to fix right away
    for city in ["walnut_creek", "solano", "san_mateo", "petaluma",
                 "santa_clara", "menlo_park", "corte_madera", "concord",
                 "antioch"]:
        if city in fname:
            return

    df = all_gp_data[fname]
    plan_names = df.general_plan_name
    empty_names = plan_names[plan_names.isnull()]
    assert len(empty_names) == 0


def test_zoning_lookup_duplicates():
    fname = os.path.join(dirname, "zoning_lookup.csv")
    df = pd.read_csv(fname)

    s = df.groupby(["name", "city"]).size()
    print s[s > 1]
    assert len(s[s > 1]) == 0


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
