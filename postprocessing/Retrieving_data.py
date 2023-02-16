# -*- coding: utf-8 -*-
"""
Created on Wed Feb 15 14:29:42 2023

@author: Jelle
"""

import OCTP_postprocess_CLASS as octp

time = ['02ns', '04ns', '06ns', '08ns', '10ns',
        '12ns', '14ns', '16ns', '18ns', '20ns',
        '22ns', '24ns', '26ns', '28ns', '30ns',
        '32ns', '34ns', '36ns', '38ns', '40ns',
        '42ns', '44ns', '46ns', '48ns', '50ns' ]
loc = '../stored/'


#for i in range(len(time)):
i = 24
folder = loc+time[i]  # Path to the main folder

f_runs = ['1', '2', '3', '4']  # All internal runs
groups = ['wat', 'S', 'Li']

# Load the class
mixture = octp.PP_OCTP(folder, f_runs, groups, dt=2, plotting=True)

# Change the file names
mixture.filenames(density='../../../input/restarts/temp_298/molality_3/density.dat',
                  volume='../../../input/restarts/temp_298/molality_3/volume.dat',
                  Diff_self='selfdiffusivity.dat',
                  Diff_Onsag='onsagercoefficient.dat',
                  T_conduc='thermconductivity.dat',
                  log='../../../input/restarts/temp_298/molality_3/log.lammps')

mixture.changefit(margin=0, Minc=8, Mmax=40, er_max=0.1)
mixture.pressure()
# mixture.tot_energy()
# mixture.pot_energy()
# mixture.density()
# mixture.molarity('S')
# mixture.molality('S', 'wat', 18.01528)
# mixture.viscosity()
# mixture.thermal_conductivity()
# mixture.self_diffusivity(YH_correction=True, box_size_check=True)
# mixture.onsager_coeff(box_size_check=True)

mixture.store(location='', name=time[i] + '.csv')
