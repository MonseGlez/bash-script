#!/usr/bin/env python3
from unittest import result
import pandas as pd
import numpy as np
import re
file_loc = "listaAsistencia.xls"

matriculas = pd.read_excel(file_loc, usecols= 'D')
nombres = pd.read_excel(file_loc, usecols= 'H')

my_list = file_loc.columns.tolist()
reordered_cols = reorder_columns(my_list, first_cols=['fourth', 'third'], last_cols=['second'], drop_cols=['fifth'])
df = file_loc[reordered_cols]