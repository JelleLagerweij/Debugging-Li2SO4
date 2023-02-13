#!/bin/bash
Nrun = 500		# 1 ns of data per step
Temp = 298.15
m = 3


for folder in tests_times
do
	mkdir $folder
	cd $folder

	for i in 1 2 3 4 5
	do
		mkdir run_$i
		cd run_$i

		# Coppying all needed files to run folder (alphabetical order)
		cp ../../../../input/runMD .
		cp ../../../../input/simulation.in .
		cp ../../../../input/restarts/temp_${Temp%.*}/molality_$m/1.restart .

		# Set simulation_preprocessing.in file values
		randomNumber=$(shuf -i 1-100 -n1)
		sed -i 's/R_VALUE/'$randomNumber'/' simulation.in
		sed -i 's/T_VALUE/'$Temp'/' simulation.in
		sed -i 's/Nrun_VALUE/'$Nrun'/' simulation.in

		# Set runMD variables
		sed -i 's/JOB_NAME/Li2SO4 T is '${Temp%.*}' m is '$m' run '$i'/' runMD
		sed -i 's/INPUT/simulation.in/' runMD

		# Commiting run and reporting that
		sbatch runMD
		echo "Runtask commited: T="$Temp", m="$m", run " $i"."
		cd ..
	done
	cd ..
done
cd ..