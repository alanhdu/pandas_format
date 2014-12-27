import pandas as pd
import blaze as bz
import pandas_format as pf

#df = bz.get_multiindexed_support()
df = pd.read_csv("/home/alan/workspace/vind/test/iris.csv")

with open("jinja2.html", "w") as fout:
    fout.write(df.to_html(show_dimensions=True))

with open("pandas.html", "w") as fout:
    fout.write(pf.to_html(df, show_dimensions=True))
