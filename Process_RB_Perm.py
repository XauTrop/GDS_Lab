#!/usr/bin/python3

import os
import numpy as np
import pandas as pd
import math

in_file = os.environ['process_file']
#in_file = "RB_1397B_3H2_1866B_data_stage_4.tmp"
in_file_name = os.environ['file_name']
#in_file_name = "RB_1397B_3H2_1866B"
height_i = float(os.environ['i_height'])
#height_i = 20
diameter_i = float(os.environ['i_diameter'])
#diameter_i = 50
eL = [float(os.environ['Le'])]
#eL = [1.5]
o_file_type = "Perm_"
o_file_ext = ".txt"
o_file_name = o_file_type + in_file_name + o_file_ext

# Read data file
with open (in_file) as f:
	table = pd.read_table(f, sep='\t', header=None, lineterminator='\n')
f.close()

size =(len(table[0]))
timet = table[2]
BPt = table[5]
BePt = table[15]
BeVt = table[16]
timef = (timet[size-1])
#print ("Time is (s): ", timef)
ADt = table[9]
AD_inc = -(np.mean(ADt[size-11:size-1]))

height_st = (height_i - AD_inc) / 1000
#print ("Sample height is (m): ", height_st)
BeP = np.mean(BePt[10:size-1])
BP = np.mean(BPt[10:size-1])
#print ("Mean Back Pressure: ", BP)
#print ("Mean Base Pressure: ", BeP)
AP = (BP - BeP) / 9.8
#print ("Pressure gradient is (kPa): ", AP)
AQ = (BeVt[0] - BeVt[size-1]) / timef
#print ("Flow is (mm/s): ", AQ)
Hyd_cond = [(height_st / (AP * ((math.pow((diameter_i / 2), 2) * 3.1415)/1000000)) * (AQ / 1000000000))]
#print ("Hydraulic conductivity is (m/s): ", Hyd_cond)
with open(o_file_name,'a') as f:
        for a, b in zip(eL, Hyd_cond):
            print("%.*f\t%.*e" % (3, a, 3, b), file=f)
f.close()








