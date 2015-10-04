'''
Created on Oct 4, 2015

Generate the learning/test instances for the routing programming assignment.

@author: trucvietle
'''

from igraph import *

filename = '../data/networks/sin_road_network.graphml'
# filename = '../data/networks/pgh_road_network.graphml'
# filename = '../data/networks/was_road_network.graphml'
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

N = 100
K = 100
out_filename = '../data/instances/sin_train_k_eq_n.txt'
out_file = open(out_filename, 'w')
out_file.write(str(N) + '\n')
out_file.write(str(K) + '\n')
out_file.close()
