#!/bin/bash
runfile=$(expr runMD_D)	# Server where to run
N_wat=$(expr 1000)	# Number of water molecules
N_salt=$(expr 18)	# Number of Li2SO4's per 1m solution
n=$(expr 2)			# Number of Li's per salt molecule
dt=$(expr 1)			# Timestepsize 1fs

cd input
mkdir restarts
cd restarts
for Temp in 298.15 323.15
do
	mkdir temp_${Temp%.*}
	cd temp_${Temp%.*}

	for m in 3 2 1
	do
		mkdir molality_$m
		cd molality_$m

		# Coppying all needed files to run folder (alphabetical order)
		cp ../../../forcefield.data .
		cp ../../../Li.xyz .
		cp ../../../params.ff .
		cp ../../../$runfile runMD
		cp ../../../simulation_preprocessing.in .
		cp ../../../SO4.xyz .
		cp ../../../water.xyz .

		# Set simulation_preprocessing.in file values
		randomNumber=$(shuf -i 1-100 -n1)
		sed -i 's/R_VALUE/'$randomNumber'/' simulation_preprocessing.in
		sed -i 's/T_VALUE/'$Temp'/' simulation_preprocessing.in
		sed -i 's/dt_VALUE/'$dt'/' simulation_preprocessing.in

		# Set runMD variables
		sed -i 's/JOB_NAME/Li2SO4 T is '${Temp%.*}' m is'$m'/' runMD
		sed -i 's/INPUT/simulation_preprocessing.in/' runMD

		# Create config folder with right files
		mkdir config
		mv ./water.xyz config/
		mv ./params.ff config/
		mv ./SO4.xyz config/
		mv ./Li.xyz config/
		cd config

		# compute total number of Li and SO4
		N_Li=$(($m*$N_salt*$n))
		N_SO4=$(($m*$N_salt))

		# Create initial configuration using fftool and packmol
		~/software/lammps/la*22/fftool/fftool $N_wat water.xyz $N_Li Li.xyz $N_SO4 SO4.xyz -r 55 > /dev/null
		~/software/lammps/la*22/packmol*/packmol < pack.inp > packmol.out
		~/software/lammps/la*22/fftool/fftool $N_wat water.xyz $N_Li Li.xyz $N_SO4 SO4.xyz -r 55 -l > /dev/null

		# removing the force data from packmol as I use my own forcefield.data. copy data.lmp remove rest
		rm -f in.lmp
		rm -f *.xyz pa*
		sed -i '12,31d' ./data.lmp
		cp data.lmp ../data.lmp
		cd ..
		rm -r config

		# Commiting run and reporting that
		sbatch runMD
		echo "Runtask commited: T="$Temp", m="$m"."
		cd ..
	done

	cd ..
done
