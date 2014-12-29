import pandas as pd
import numpy as np
import pandas_format as pf
from bs4 import BeautifulSoup

np.random.seed(0)

df = pd.read_csv("iris.csv")
mi = pd.MultiIndex.from_tuples([(a, b, c) for a in range(5) 
                                for b in range(5) for c in range(5)])
mi_df = pd.DataFrame(np.random.rand(125, 5), index=mi)

named = mi_df.reindex(mi.rename(["test", "really long test", 5]))

runs = [dict(df=df, max_rows=11, formatters={"Name":str.upper}),
        dict(df=df, max_rows=20, max_cols=4, show_dimensions=True),
        dict(df=mi_df, max_rows=20, max_cols=4),
        dict(df=named, classes="sdfsdf"),
        dict(df=mi_df, sparsify=True, justify="right", index=False, col_space=20),
        dict(df=df, float_format=lambda x: "{0:.2f}".format(x), na_rep="NAAAAA", classes=["a", "b"]),
       ]

for key, value in enumerate(runs):
    with open("correct/{}.html".format(key), "w") as fout:
        pf.to_html(buf=fout, **value)
    with open("correct/{}.txt".format(key), "w") as fout:
        if "classes" in value:
            del value["classes"]
        pf.to_string(buf=fout, **value)
"""
for key, value in enumerate(runs):
    with open("correct/{}.html".format(key)) as fin:
        assert BeautifulSoup(pf.to_html(**value)) == BeautifulSoup(fin.read()), \
                "Failed on to_html {}".format(key)
    with open("correct/{}.txt".format(key)) as fin:
        if "classes" in value:
            del value["classes"]
        assert pf.to_string(**value) == fin.read(), \
                "Failed on to_string {}".format(key)
                """
