#!/bin/bash
runfile=$(expr runMD_H)	# Server where to run
dt=$(expr 1)			# Timestepsize 1fs
Nrun=$(expr 2000000)	# dt*Nrun = 2 ns of data per step
Temp=$(expr 298.15)		# Temperature in K
m=$(expr 3)				# Concentration file to use
# How is it now?

for folder in running
do
	mkdir $folder
	cd $folder

	for i in 1 2 3 4
	do
		mkdir $i
		cd $i

		# Coppying all needed files to run folder (alphabetical order)
		cp ../../input/$runfile runMD
		cp ../../input/simulation.in .
		cp ../../input/restarts/temp_${Temp%.*}/molality_$m/1.restart .
		cp ../../input/copy_files.sh .

		# Set simulation_preprocessing.in file values
		randomNumber=$(shuf -i 1-100 -n1)
		sed -i 's/R_VALUE/'$randomNumber'/' simulation.in
		sed -i 's/T_VALUE/'$Temp'/' simulation.in
		sed -i 's/dt_VALUE/'$dt'/' simulation.in
		sed -i 's/Nrun_VALUE/'$Nrun'/' simulation.in

		# Set filder location
		sed -i 's/run_FOLDER/'$i'/' copy_files.sh

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
