'''
Created on Mar 2, 2016

To generate a GraphML file for the giant components with 'useful' attributes only.

@author: trucvietle
'''

from igraph import *

## Read the original graph
graph_filename = '../../data/networks/sin_road_network.graphml'
graph = Graph.Read_GraphML(f=graph_filename)
summary(graph)
print(graph.is_directed())

## Find the giant component
comps = graph.components(mode=WEAK)
max_comp = 1
max_index = 0
index = 0
for comp in comps:
    if len(comp) > max_comp:
        max_comp = len(comp)
        max_index = index
    index += 1
giant = comps[max_index]

giant_subgraph = graph.subgraph(giant)
summary(giant_subgraph)
print(giant_subgraph.is_directed())

## Add travel time attribute to the edges
travel_times = []
for edge in giant_subgraph.es:
    edge_idx = edge.index
    seg_len = giant_subgraph.es['SHAPE_LEN'][edge_idx]
    seg_len = seg_len / 1000 # convert to km
    max_speed = giant_subgraph.es['max_speed'][edge_idx]
    travel_time = seg_len / max_speed
    travel_time = travel_time * 60 # covert to minutes
    travel_times.append(travel_time)
giant_subgraph.es['travel_time'] = travel_times
summary(giant_subgraph)

## Save the subgraph as XML file
out_filename = '../../data/networks/sin_road_subgraph.graphml'
giant_subgraph.write_graphml(out_filename)
print('Written to file: ' + out_filename)
