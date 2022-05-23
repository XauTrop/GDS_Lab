#!/usr/bin/python3

import os
import numpy as np
import pandas as pd

in_file = os.environ['process_file']
in_file_name = os.environ['file_name']
height_i = float(os.environ['i_height'])
diameter_i = float(os.environ['i_diameter'])
e0 = float(os.environ['e0'])
def_sign = os.environ['Def_sign_subs']
o_file_type = "Cons_"
o_file_ext = ".txt"
o_file_name = o_file_type + in_file_name + o_file_ext

Hs = height_i / (1 + e0)
with open (in_file) as f:
	table = pd.read_table(f, sep='\t', header=None, lineterminator='\n')
f.close()
size =(len(table[0]))
ASt = table[10]
Bkt = table[5]
AStf = np.mean(ASt[size-11:size-1])
Bkf = np.mean(Bkt[size-11:size-1])
Eff = [AStf - Bkf]
AD = table[9]
AD_inc = -(np.mean(AD[size-11:size-1]))

if def_sign == 'pos':
	AD_inc = -(np.mean(AD[size-11:size-1]))
else:
	AD_inc = -(np.mean(AD[size-11:size-1]))
	
height_st = height_i - AD_inc
e = [( height_st - Hs) / Hs]

with open(o_file_name,'a') as f:
        for a, b in zip(Eff, e):
            print("%.*f\t%.*f" % (2, a, 3, b), file=f)
f.close()








