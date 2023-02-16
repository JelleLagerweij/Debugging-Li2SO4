# -*- coding: utf-8 -*-
"""
Created on Thu Feb 16 16:33:01 2023

@author: Jelle
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
plt.close('all')
plt.rcParams['svg.fonttype'] = 'none'

tmin = 2
tmax = 50

time = ['02ns', '04ns', '06ns', '08ns', '10ns',
        '12ns', '14ns', '16ns', '18ns', '20ns',
        '22ns', '24ns', '26ns', '28ns', '30ns',
        '32ns', '34ns', '36ns', '38ns', '40ns',
        '42ns', '44ns', '46ns', '48ns', '50ns']


for j in range(len(time)):
    time[j] += '.csv'

properties = list(pd.read_csv(time[0]).columns.values)[1:]

for i in range(len(properties)):
    run_t = np.linspace(tmin, tmax, num=len(time))
    data = np.zeros(len(time))
    data_error = np.zeros(len(time))

    for j in range(len(time)):
        info = pd.read_csv(time[j])[properties[i]]
        data[j] = info[0]
        data_error[j] = info[1]

    data = np.nan_to_num(data)
    data_error = np.nan_to_num(data_error)

    plt.figure(properties[i])
    plt.plot(run_t, data)
    plt.fill_between(run_t, data-data_error, y2=data+data_error,  alpha=.25)
    plt.xlabel('runtime/[ns]')
    plt.ylabel(properties[i])
    # plt.xlim(2, 24)
    # plt.ylim(min(data[:12]-data_error[:12]), max(data[:12]+data_error[:12]))
