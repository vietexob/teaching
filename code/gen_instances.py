'''
Created on Oct 4, 2015

Generate the learning/test instances for the routing programming assignment.

@author: trucvietle
'''

from igraph import *
import random

# filename = '../data/networks/sin_road_network.graphml'
# filename = '../data/networks/pgh_road_network.graphml'
filename = '../data/networks/was_road_network.graphml'
g = Graph.Read_GraphML(f=filename)
summary(g)

## Find the giant component
comps = g.components(mode=WEAK)
print(len(comps)) # how many connected components there are
max_comp = 1
max_index = 0
index = 0
for comp in comps:
    if len(comp) > max_comp:
        max_comp = len(comp)
        max_index = index
    index += 1
print(max_index, max_comp)
giant = comps[max_index]

N = 100 # the number of OD pairs
K = 100 # the number of taxis

## Generate N random OD pairs
source_list = []
target_list = []
for i in range(N):
    source = random.choice(giant)
    while source in source_list:
        source = random.choice(giant)
    source_list.append(source)
    
    target = random.choice(giant)
    while target in target_list or source == target:
        target = random.choice(giant)
    target_list.append(target)

## Generate K vehicle locations
loc_list = []
for i in range(K):
    loc = random.choice(giant)
    while loc in source_list or loc in target_list or loc in loc_list:
        loc = random.choice(giant)
    loc_list.append(loc)

# out_filename = '../data/instances/sin_train_k_eq_n.txt'
# out_filename = '../data/instances/pgh_train_k_eq_n.txt'
out_filename = '../data/instances/was_train_k_eq_n.txt'
out_file = open(out_filename, 'w')
out_file.write(str(N) + '\n')
out_file.write(str(K) + '\n')
for i in range(N):
    out_file.write(str(source_list[i]) + ", " + str(target_list[i]) + "\n")
for i in range(K):
    out_file.write(str(loc_list[i]) + "\n")

out_file.close()
