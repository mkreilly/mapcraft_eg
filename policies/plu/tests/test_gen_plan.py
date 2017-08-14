import pandas as pd
import pytest
import os
import json
import glob

dirname = os.path.join("policies", "plu")
files = glob.glob(os.path.join(dirname, "*.geojson"))


def load_gp_data(file):
    shapes = json.load(open(file))
    shapes = [f["properties"] for f in shapes["features"]]
    df = pd.DataFrame.from_records(shapes)
    return file, df

gpdata = [load_gp_data(file) for file in files]
print gpdata


@pytest.mark.parametrize("fname, df", gpdata)
def test_too_many_shapes(fname, df):
    if "san_francisco" in fname or "san_jose" in fname:
        return
    # only san francisco really has lots of general plan shapes
    # other cities are using parcels as their general plan shapes,
    # which need to be dissolved
    assert len(df) < 2000


@pytest.mark.parametrize("fname, df", gpdata)
def test_empty_general_plan_names(fname, df):
    plan_names = df.general_plan_name
    empty_names = plan_names[plan_names.isnull()]
    assert len(empty_names) == 0


# test join to zoning_lookup.csv
# test duplicate general plan names on zoning_lookup.csv
# (not in gp files, where it's a-ok)

'''
@pytest.mark.parametrize("fname", jurises)
def test_csv_schema(fname):

    dirname = os.path.join(county, juris, 'general_plan')
    csvname = os.path.join(dirname, '%s.csv' % juris)

    df = pd.read_csv(csvname, index_col="name")

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
    assert df.max_far.fillna(0).max() <= 30
    assert df.max_height.fillna(0).min() >= 0
    assert df.max_height.fillna(0).max() <= 1000
    assert df.max_dua.fillna(0).min() >= 0
    assert df.max_dua.fillna(0).max() <= 350
    assert df.max_du_per_parcel.fillna(0).min() >= 0
    assert df.max_du_per_parcel.fillna(0).max() <= 10
'''
