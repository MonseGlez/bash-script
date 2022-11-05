#!/usr/bin/env python3
import pandas as pd
import xlsxwriter



file_loc = "listaAsistencia.xls"
matriculas = pd.read_excel(file_loc, usecols= 'D',skiprows= lambda x: x<11)
nombres = pd.read_excel(file_loc, usecols= 'H',skiprows= lambda x: x<11)
print(tuple(x.strip('()').split(',') for x in matriculas.dropna() ))
print(nombres.dropna())
matricula_data=matriculas.dropna().values.tolist()    
df = pd.DataFrame({'Matricula': matricula_data,'Nombre Alumno':nombres.dropna().values.tolist(),'DNS':'','Apache':''}).to_excel('listaEvaluacion.xlsx',index=False)

