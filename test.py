import pandas as pd
import numpy as np
import pandas_format as pf

df = pd.read_csv("/home/alan/workspace/vind/test/iris.csv")
mi = pd.MultiIndex.from_tuples([(a, b, c) for a in range(5) 
                                for b in range(5) for c in range(5)])
mi_df = pd.DataFrame(np.random.rand(125, 5), index=mi)

with open("pandas.html", "w") as fout:
    fout.write(df.to_html(max_cols=4, max_rows=11))

with open("jinja2.html", "w") as fout:
    fout.write(pf.to_html(df, max_cols=4, max_rows=11))
