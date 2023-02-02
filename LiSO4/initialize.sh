
N=$(expr 1000);    #Number of water molecules
i=$(expr 36);      #Number of Li molecules
j=$(expr 18);	  #Number of SO4

mkdir config
cp ./water.xyz config/; cp ./params.ff config/;
cp ./SO4.xyz config/; cp ./Li.xyz config/;
cd config;

~/software/lammps/la*22/fftool/fftool $N water.xyz $i Li.xyz $j SO4.xyz -r 50 > /dev/null
~/software/lammps/la*22/packmol*/packmol < pack.inp > packmol.out
~/software/lammps/la*22/fftool/fftool $N water.xyz $i Li.xyz $j SO4.xyz -r 50 -l > /dev/null

rm -f in.lmp
rm -f *.xyz pa*
sed -i '12,31d' ./data.lmp
cp data.lmp ../data.lmp
cd ..
rm -r config

# Random Seed Setting
randomNumber=$(shuf -i 1-100 -n1)
sed -i 's/VALUE/'$randomNumber'/' simulation_preprocessing.in
sed -i 's/JOB_NAME/preproccessing/' runMD
sed -i 's/INPUT/simulation_preprocessing.in/' runMD
sbatch runMD
