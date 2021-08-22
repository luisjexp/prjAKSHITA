#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jul 20 10:32:15 2021

@author: luis
"""

# import matplotlib.pyplot as plt

def time_vs_X(df, var1_name):
    # ax = df.plot(kind = 'line', x = 'time',
    #                   y = var1_name, color = 'Blue',
    #                   linewidth = 3, figsize=(20, 5))
    

    ax = plt.scatter(x = 'time', y = var1_name, color = 'Blue')
    plt.hist(df[var1_name])
    #title of the plot
    plt.title(var1_name + "~" + 'time')
    
    
    #labeling x and y-axis
    # ax.set_xlabel('time', color = 'g')
    # ax.set_ylabel(var1_name, color = "b")

    #defining display layout
    plt.tight_layout()

    #show plot
    plt.show()
    
def time_vs_XY(df, var1_name, var2_name, ax, ax2):
    df.plot( kind = 'line',
                      y = var1_name, color = 'Blue',
                      linewidth = 3, figsize=(20, 5), ax = ax)
    
    ax2 = df.plot(kind = 'line', 
                        y = var2_name, secondary_y = True,
                        color = 'Red',  linewidth = 5,
                        ax = ax2)

    #title of the plot
    # plt.title(var1_name + "~" + var2_name + "~" + 'time')
    
    #labeling x and y-axis
    # ax.set_xlabel('time', color = 'g')
    # ax.set_ylabel(var1_name, color = "b")
    # ax2.set_ylabel(var2_name, color = 'r')

    #defining display layout
    # plt.tight_layout()

    # #show plot
    # plt.show()
