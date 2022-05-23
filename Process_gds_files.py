#!/usr/bin/python3

import numpy as np


input_file = np.loadtxt('RB_1397B_3H2_1866B.gds', 'r')
output_file = 'RB_1397B_3H2_1866B.txt'

output_f  = input_file.replace('","','\t').replace('"','').replace(',','.')
print (output_f)
#np.savetxt(output_file, output_f)
#sed -i 's/","/\t/g' $output_file
#sed -i 's/"//g' $output_file
#sed -i 's/,/./g' $output_file
# file_type=$(echo ${input_file:0:3})
# if [ $file_type -eq "RB_" ]; then
	# printf "Process a R&B test?\n"
# fi
# if [ $file_type -eq "CRS" ]; then
	# printf "Process a CRS test?\n"
# fi
# if [ $file_type -eq "TAS" ]; then
	# printf "Process a Triaxial test?\n"
# fi
# 
# echo $file_type
