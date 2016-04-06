'''
Created on Apr 6, 2016

Compute the average wait time of a given output path_df for Part (b) only.

@author: trucvietle
'''

from igraph import *
import pandas as pd
import numpy as np
import csv

## Construct the graph using adjacency lists
graph = Graph()
## Read the CSV adjacency lists (edge indices)
edge_idx_filename = '../../data/adj_matrices/edge_idx_list.csv'
edge_list = []
edge_idx_list = []
max_node_idx = 0
with open(edge_idx_filename, 'rb') as csvfile:
    f = csv.reader(csvfile, delimiter=',')
    counter = 0
    for row in f:
        if counter > 0:
            node_u = int(row[0])
            node_v = int(row[1])
            edge_idx = int(row[2])
            edge_list.append((node_u, node_v))
            edge_idx_list.append(edge_idx)
            max_node = node_u if node_u > node_v else node_v
            if max_node > max_node_idx:
                max_node_idx = max_node
        counter += 1
max_node_idx += 1 # because 0 is a valid node index
graph.add_vertices(max_node_idx)
graph.add_edges(edge_list)

## Read the CSV adjacency lists (travel times)
edge_len_filename = '../../data/adj_matrices/travel_time_list.csv'
edge_len_list = []
with open(edge_len_filename, 'rb') as csvfile:
    f = csv.reader(csvfile, delimiter=',')
    counter = 0
    for row in f:
        if counter > 0:
            travel_time = float(row[2])
            edge_len_list.append(travel_time)
        counter += 1

## Add the attributes to the edges
counter = 0
for edge in graph.es:
    edge['index'] = edge_idx_list[counter]
    edge['travel_time'] = edge_len_list[counter]
    counter += 1 
summary(graph)
print graph.is_directed()

## Read the CSV output path_df as pandas data frame
filename = '../../data/test/sin/khoi/path_30_100_a.csv'
path_df = pd.read_csv(filename, sep=',', header=None)
path_df.columns = ['taxi', 'indicator', 'time', 'edge']
print path_df






