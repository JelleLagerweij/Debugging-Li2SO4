#!/bin/bash
N_wat=$(expr 1000)	# Number of water molecules
N_salt=$(expr 18)	# Number of Li2SO4's per 1m solution
n=$(expr 2)			# Number of Li's per salt molecule'

for Temp in 298.15 323.15
do
	mkdir temp_${Temp%.*}
	cd temp_${Temp%.*}

	for m in 1 2 3
	do
		mkdir molality_$m
		cd molality_$m

		# Coppying all needed files to run folder (alphabetical order)
		cp ../../input/forcefield.data .
		cp ../../input/Li.xyz .
		cp ../../input/params.ff .
		cp ../../input/runMD .
		cp ../../input/simulation_preprocessing.in .
		cp ../../input/SO4.xyz .
		cp ../../input/water.xyz .

		# Set simulation_preprocessing.in file values
		randomNumber=$(shuf -i 1-100 -n1)
		sed -i 's/R_VALUE/'$randomNumber'/' simulation_preprocessing.in
		sed -i 's/T_VALUE/'$Temp'/' simulation_preprocessing.in

		# Set runMD variables
		sed -i 's/JOB_NAME/Li2SO4 T='$T' m='$m'/' runMD
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
