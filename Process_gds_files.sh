#!/bin/bash
clear
if [ -e "*.tmp" ];then
	rm *.tmp
fi
if [ -e "*.txt" ];then
	rm *.txt
fi
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
normal=$(tput sgr0)
printf "File name to process? "
read input_file
#input_file="GeoB17610-2-319.gds"
export file_name=$(echo $input_file |cut -f 1 -d ".")
output_file=${file_name}.txt
cp $input_file $output_file

echo "Loading and parsing file:" $input_file
export i_height=$(sed -n '1p' $input_file | sed 's/[^0-9]//g')
export i_diameter=$(sed -n '2p' $input_file | sed 's/[^0-9]//g')
export e0="0.963"
# Parsing field separators, information lines and headers
sed -i 's/","/\t/g' $output_file
sed -i 's/"//g' $output_file
sed -i 's/,/./g' $output_file


# Check parsed file exitst
if [ -s $output_file ]; then
	printf "File converted and saved!!\n"
	
	else
	echo "A problem occurred during file  manipulation (error_code=1) exit!"
	exit
fi

test_type=$(echo $input_file |cut -f 1 -d "_")
if [[ $test_type == "RB" ]] || [[ $test_type == "CRS" ]] || [[ $test_type == "TAS" ]]; then
	if [ $test_type == "RB" ]; then
		printf "Process a R&B test? (y/n) "
		read test_type_check

	elif [ $test_type == "CRS" ]; then
		printf "Process a CRS test? (y/n) "
		read test_type_check

	elif [ $test_type == "TAS" ]; then
		printf "Process a Triaxial test? (y/n) "
		read test_type_check
	fi
	if [ "$test_type_check" == "n" ]; then
		printf "Enter test type (RB, CRS, TAS): "
		read test_type
	fi
else 
	printf "\n${RED}Test type not recognized.${normal}\nPlease enter test type (RB, CRS, TAS): "
	read test_type
	test_type_check="y"

fi
if [[ $test_type != "RB" ]] && [[ $test_type != "CRS" ]] && [[ $test_type != "TAS" ]]; then
	printf "${RED}Test type not recognized. Exiting!!!!\n${normal}"
	exit
fi
printf "\n${GREEN}Test type is set to: ${normal}%s\n" $test_type

printf "Test crashed? Do you want to skip stages? (y/n) "
	read crash
if [ $crash == "y" ]; then
	printf "From which stage do you want to skip? "
	read stage_skip
fi

########################################
###### Process file for R&B test #######
########################################

if [ $test_type == "RB" ]; then
o_cons_file_type="Cons_"
o_perm_file_type="Perm_"
o_file_ext=".txt"
o_file_name_cons=$o_cons_file_type$file_name$o_file_ext
# Check if Consolidation results file exist and remove
if [ -e ${o_file_name_cons} ];then
	echo "Consolidation Ouput file already exists, removing ..."
	rm ${o_file_name_cons}
fi
o_file_name_perm=$o_perm_file_type$file_name$o_file_ext
# Check if Permeability results file exist and remove
if [ -e ${o_file_name_perm} ];then
	echo "Permeability Ouput file already exists, removing ..."
	rm ${o_file_name_perm}
fi



printf "\nProcessing file ...\n"
## Output header
head_line=$(grep -n "Stage Number" $output_file | awk -F  ":" '{print $1}')
sed -n ''$head_line'p' $output_file > header.tmp
# Output file without header
awk '{if (NR>'$head_line') print $0}' $output_file > ${file_name}.tmp
# Find maximum number of stages
number_stages=$(awk 'END {print  $1}' $output_file)
real_stages_stored=$(awk '{if (NR>'$head_line') print $1}' ${file_name}.tmp)
# Compression sign (+ or -)
Def_sign_i=$(head -1 ${file_name}.tmp | awk '{print $10}')
Def_sign_f=$(tail -1 ${file_name}.tmp | awk '{print $10}')
Def_sign_subs_k=$(echo ${Def_sign_f} - ${Def_sign_i} | bc)
# Export variable to python
if [[ $Def_sign_subs_k > "0" ]]; then
	export Def_sign_subs="pos"
else
	export Def_sign_subs="neg"
fi

### Split each stage in one file ###
for (( s=1;s<=$number_stages;s=s+1 ))
do
	# Check only for existing stages (in case the .gds file do not contain all the stages)
	if [[ "${real_stages_stored[@]}" =~ "${s}" ]]; then
	
		stages_array+=($s)
	#Writing each stage in separate temporary file
		awk '{if ($1=='$s') print $0}' ${file_name}.tmp > ${file_name}_data_stage_${s}.tmp

	#Looking for Permeability(4) stages and previous consolidation(3) stage
		BeVi=$(head -1 ${file_name}_data_stage_${s}.tmp | awk '{print $17}')
		BeVf=$(tail -1 ${file_name}_data_stage_${s}.tmp | awk '{print $17}')
		diffBeV=$(echo ${BeVi} - ${BeVf} | bc)
	
		ASi=$(head -1 ${file_name}_data_stage_${s}.tmp | awk '{print $11}')
		ASf=$(tail -1 ${file_name}_data_stage_${s}.tmp | awk '{print $11}')
		diAS=$(echo ${ASi} - ${ASf} | bc)
		diffAS=$(printf "%.0f" ${diAS})
		diAS2=$(echo ${ASf} - ${ASi} | bc)
		diffAS2=$(printf "%.0f" ${diAS2})
	
		BPi=$(head -1 ${file_name}_data_stage_${s}.tmp | awk '{print $6}')
		BPf=$(tail -1 ${file_name}_data_stage_${s}.tmp | awk '{print $6}')
		diBP=$(echo ${BPi} - ${BPf} | bc)
 		diffBPx=$(awk 'BEGIN {x = '${diBP}'; print x < 0 ? -x : x}')
 		diffBP=$(printf "%.0f" ${diffBPx})
 	
 		AxDi=$(head -1 ${file_name}_data_stage_${s}.tmp | awk '{print $10}')
		AxDf=$(tail -1 ${file_name}_data_stage_${s}.tmp | awk '{print $10}')
		diAxD=$(echo ${AxDi} - ${AxDf} | bc)
		diffAxD=$(awk 'BEGIN {x = '${diAxD}'; print x < 0 ? -x : x}')
		check=$(echo "$diffAxD < 0.005" | bc -l)
#	echo "Stage, diffBP, diffAxStr, dissBeV, diffAxD, check"
#	echo $s, $diffBP, $diffAS2, $diffBeV, $diffAxD, $check
	
#Write array of stage type:(1)Saturation, (2)B-check, (3)Consolidation, (4)Permeability, (5) Unloading
		if [[ ${diffBP} -lt "5" ]] && [[ ${diffAS2} -gt "0" ]] && [[ $check -eq "0" ]]; then
			stage_type+=(3)
		# Check started the consolidation
			cons_start="True"
		#echo "Stage type: Consolidation" 
		
		elif [ ${diffBeV} -gt "0" ]; then
			stage_type+=(4)
		#echo "Stage type: Permeability"

		elif [[ ${diffAS} -gt "0" ]] && [[ "${cons_start}" == "True" ]]; then
			stage_type+=(5)
		#echo "Stage type: Unloading"

		else
			stage_type+=(1)
		#echo "Stage type: Saturation/B-check"
		fi	
	fi
done
#echo "(1)Saturation, (2)B-check, (3)Consolidation, (4)Permeability, (5) Unloading"
#echo "${stage_type[@]}"
# Skipping stages 
if [[ $number_stages -gt $stage_skip ]] && [[ $stage_skip -ne "" ]]; then
	number_stages=$(echo "$stage_skip - 1" | bc)
fi
### Process consolidation stages ###
echo "Doing calculations trough python ..."
for (( s=1;s<=$number_stages;s=s+1))
do
	s0=$(echo $s-1 | bc)
	#Process consolidation stages
	if [ "${stage_type[$s0]}" == "3" ]; then
	export process_file=${file_name}_data_stage_${s}.tmp
	
#### Embeding python code ######
python3 Process_RB_Cons.py
################################
	
	#Process unloading stages
	elif [ "${stage_type[$s0]}" == "5" ]; then
	process_file=${file_name}_data_stage_${s}.tmp
#### Embeding python code ######
python3 Process_RB_Cons.py
################################
	
	#Process permeability stages
	elif [ "${stage_type[$s0]}" == "4" ]; then
	process_file=${file_name}_data_stage_${s}.tmp
	export Le=$(tail -1 ${o_file_name_cons} | awk '{print $2}')
#### Embeding python code ######
python3 Process_RB_Perm.py
################################
	fi
done

echo "Processing finished"
echo "Plotting"
#### Embeding python code ######
python3 Plot_RB.py
################################



fi
### END Process file for R&B test ###
#####################################
if [ -e $fils ];then 
	echo "Removing temporary files and finishing ..."
	rm *.tmp
fi
