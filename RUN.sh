#!/bin/bash
N=$(expr 1000)	# Number of water molecules
j=$(expr 18)	# Number of Li2SO4's per 1m solution

for Temp in 298.15 232.15
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
		sed -i 's/JOB_NAME/preproccessing/' runMD
		sed -i 's/INPUT/simulation_preprocessing.in/' runMD

		# Create initial configuration using fftool and packmol
		mkdir config
		mv ./water.xyz config/
		mv ./params.ff config/
		mv ./SO4.xyz config/
		mv ./Li.xyz config/
		cd config

		~/software/lammps/la*22/fftool/fftool $N water.xyz 2*$j*$m Li.xyz $j*$m SO4.xyz -r 55 > /dev/null
		~/software/lammps/la*22/packmol*/packmol < pack.inp > packmol.out
		~/software/lammps/la*22/fftool/fftool $N water.xyz 2*$j*$m Li.xyz $j*$m SO4.xyz -r 55 -l > /dev/null

		# removing the force data from packmol as I use my own forcefield.data. copy data.lmp remove rest
		rm -f in.lmp
		rm -f *.xyz pa*
		sed -i '12,31d' ./data.lmp
		cp data.lmp ../data.lmp
		cd ..
		rm -r config
		sbatch runMD

		cd ..
	done

	cd ..
done