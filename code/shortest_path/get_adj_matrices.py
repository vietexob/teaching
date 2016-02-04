'''
Created on Feb 4, 2016

Retrieve the adjacency matrices of the Singapore road network. Each matrix represents
an edge attribute (length, speed limit, street names, etc.)

@author: trucvietle
'''

from igraph import *
import numpy as np
import csv

## Read the road network
filename = '../../data/networks/sin_road_network.graphml'
g = Graph.Read_GraphML(f=filename)
summary(g)

## Find the giant component
comps = g.components(mode=WEAK)
# print(len(comps)) # how many connected components there are
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

## Construct an adjacency matrix representing the segment lengths
len_matrix = np.zeros(shape=(len(giant), len(giant)))
## Iterate through all the edges and populate the adjacency matrix
for edge in g.es:
    source_node_id = edge.source
    target_node_id = edge.target
    if source_node_id in giant and target_node_id in giant:
        seg_len = g.es['SHAPE_LEN'][edge.index]
        row = giant.index(source_node_id)
        col = giant.index(target_node_id)
        print(row, col)
#             len_matrix[source_node_id, target_node_id] = seg_len
#             len_matrix[target_node_id, source_node_id] = seg_len
        
