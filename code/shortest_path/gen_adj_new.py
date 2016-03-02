'''
Created on Mar 2, 2016

Generate the adjacency matrices and lists based on the new giant subgraph.

@author: trucvietle
'''

from igraph import *
import pandas as pd

subgraph_filename = '../../data/networks/sin_road_subgraph.graphml'
graph = Graph.Read_GraphML(f=subgraph_filename)
summary(graph)
print(graph.is_directed())

## Get the adjacency matrices
adj_matrix_edge_idx = graph.get_adjacency(eids=True)
adj_matrix_travel_time = graph.get_adjacency(attribute='travel_time')
## Convert them into pandas data frames
adj_data_edge_idx = pd.DataFrame(adj_matrix_edge_idx.data)
adj_data_travel_time = pd.DataFrame(adj_matrix_travel_time.data)
## Output to CSV files
out_filename = '../../data/adj_matrices/edge_idx_matrix.csv'
adj_data_edge_idx.to_csv(out_filename, index=False)
print('Written to file: ' + out_filename)
out_filename = '../../data/adj_matrices/travel_time_matrix.csv'
adj_data_travel_time.to_csv(out_filename, index=False)
print('Written to file: ' + out_filename)
