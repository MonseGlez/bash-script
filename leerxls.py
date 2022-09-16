#!/usr/bin/env python3
from threading import main_thread
from unittest import result
import pandas as pd
import numpy as np
import re
file_loc = "listaAsistencia.xls"

matriculas = pd.read_excel(file_loc, usecols= 'D',skiprows= lambda x: x<12)
nombres = pd.read_excel(file_loc, usecols= 'H',skiprows= lambda x: x<12)

print(matriculas.dropna())
print(nombres.dropna())

