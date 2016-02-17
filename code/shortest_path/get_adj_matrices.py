'''
Created on Feb 4, 2016

Retrieve the adjacency matrices of the Singapore road network. Each matrix represents
an edge attribute (length, speed limit, street names, etc.)

@author: trucvietle
'''

from igraph import *
import numpy as np
import pandas as pd

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
# print(max_index, max_comp)
giant = comps[max_index]

## Construct an adjacency matrix representing the segment lengths
len_matrix = np.zeros(shape=(len(giant), len(giant)))
## Adjacency matrix representing the speed limit
speed_matrix = np.zeros(shape=(len(giant), len(giant)))
## Matrix to store the edge indices
edge_matrix = np.zeros(shape=(len(giant), len(giant)))

## Iterate through all the edges and populate the adjacency matrix
for edge in g.es:
    edge_idx = edge.index + 1
    source_node_id = edge.source
    target_node_id = edge.target
    if source_node_id in giant and target_node_id in giant:
        seg_len = g.es['SHAPE_LEN'][edge.index]
        max_speed = g.es['max_speed'][edge.index]
        
        row = giant.index(source_node_id)
        col = giant.index(target_node_id)
        if len_matrix[row, col] == 0:
            len_matrix[row, col] = seg_len
            len_matrix[col, row] = seg_len
        
        if speed_matrix[row, col] == 0:
            speed_matrix[row, col] = max_speed
            speed_matrix[col, row] = max_speed
        
        if edge_matrix[row, col] == 0:
            edge_matrix[row, col] = edge_idx
            edge_matrix[col, row] = edge_idx

len_data = pd.DataFrame(len_matrix)
speed_data = pd.DataFrame(speed_matrix)
edge_data = pd.DataFrame(edge_matrix)

## Add column names (attributes)
# len_data.columns = giant
# speed_data.columns = giant

## Create a mapping from giant's index to value
# idx_val = np.zeros(shape=(len(giant), 2))
# idx_val[:, 0] = range(len(giant))
# idx_val[:, 1] = [str(x) for x in giant]
# idx_val_data = pd.DataFrame(idx_val)
# idx_val_data.columns = ['idx', 'val']
# out_filename = '../../data/adj_matrices/giant_idx_val.csv'
# idx_val_data.to_csv(out_filename, index=False)
# print('Written to file ' + out_filename)

out_filename = '../../data/adj_matrices/seg_len_matrix.csv'
len_data.to_csv(out_filename, index=False)
print('Written to file ' + out_filename)

out_filename = '../../data/adj_matrices/max_speed_matrix.csv'
speed_data.to_csv(out_filename, index=False)
print('Written to file ' + out_filename)

out_filename = '../../data/adj_matrices/edge_idx_matrix.csv'
edge_data.to_csv(out_filename, index=False)
print('Written to file ' + out_filename)
