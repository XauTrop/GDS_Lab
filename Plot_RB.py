#!/usr/bin/python3

import os
import matplotlib.pyplot as plt


ini_file_name = os.environ['file_name']
#ini_file_name = "GeoB17610-2-319"
c_file_type = "Cons_"
p_file_type = "Perm_"
i_file_ext = ".txt"
c_file_name = c_file_type + ini_file_name + i_file_ext
p_file_name = p_file_type + ini_file_name + i_file_ext

Eff = []
e = []
perm = []
e_p = []
with open(c_file_name) as cons_file:
	for line in cons_file:
		cols = [float(x) for x in line.split()]
		Eff.append(cols[0])
		e.append(cols[1])
		
with open(p_file_name) as perm_file:
	for line in perm_file:
		cols = [float(x) for x in line.split()]
		e_p.append(cols[0])
		perm.append(cols[1])

minX = min(Eff)
maxX = max(Eff)
minY = min(e)
maxY = max(e)
plt.figure(1)
plt.subplot(121)
plt.xlabel('Effective stress (kPa)')
plt.ylabel('Void ratio (e)')
plt.plot(Eff, e, 'bo-')
plt.axis([minX, maxX+200, minY-0.1, maxY+0.1])
#plt.set_xlabel('Effective stress (kPa)')
plt.xscale('log')

plt.subplot(122)
plt.xlabel('Hydraulic coductivity (m/s)')
plt.ylabel('Void ratio (e)')
plt.plot(perm, e_p, 'go-')
plt.axis([min(perm), max(perm), minY-0.1, maxY+0.1])
#plt.set_xlabel('Effective stress (kPa)')
plt.xscale('log')
plt.show()








