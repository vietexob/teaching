'''
Created on Sep 21, 2015

Try to read graphml road network input file and perform basic analysis using igraph.

@author: trucvietle
'''

from igraph import *
import random
import csv

filename = '../data/networks/sin_road_network.graphml'
# filename = '../data/networks/pgh_road_network.graphml'
g = Graph.Read_GraphML(f=filename)
summary(g)
# print(g.is_directed())
# print(g.degree_distribution())
# 
# adj_list = g.get_adjlist()
# print(len(adj_list))
# print(adj_list[0:9])
# 
# adj_matrix = g.get_adjacency(attribute='SHAPE_LEN', default=0)
# print(adj_matrix.min())
# print(adj_matrix.max())

comps = g.components(mode=WEAK)
print(len(comps)) # how many connected components there are
## The first connected component is the giant component because it contains > 60% of the nodes
giant = comps[0]
print(len(giant))

## Compute the shortest path (in terms of SHAPE_LEN) between two random nodes in giant
source = random.choice(giant)
target = random.choice(giant)
while target == source:
    target = random.choice(giant)

print(source, target)
shortest_dist = g.shortest_paths(source=source, target=target, weights='SHAPE_LEN', mode=ALL)
print(shortest_dist)

shortest_path = g.get_shortest_paths(v=source, to=target, weights='SHAPE_LEN', mode=ALL, output='vpath')
shortest_path = shortest_path[0]
print(shortest_path)
print(len(shortest_path))

shortest_path = g.get_shortest_paths(v=source, to=target, weights='SHAPE_LEN', mode=ALL, output='epath')
shortest_path = shortest_path[0]
print(shortest_path)
print(len(shortest_path))

# for idx in shortest_path:
# #     print(g.es['from.x'][idx], g.es['from.y'][idx])
#     print(g.es['RD_CD_DESC'][idx])
# #     print(g.es['to.x'][idx], g.es['to.y'][idx])

## Save the shortest path as CSV
out_filename = '../data/output/shortest_path_' + str(source) + '_' + str(target) + '.csv'
with open(out_filename, 'wb') as csvfile:
    outputwriter = csv.writer(csvfile, delimiter=',')
    for idx in shortest_path:
        seg_id = g.es['RD_CD'][idx]
        from_lon = g.es['from.x'][idx]
        from_lat = g.es['from.y'][idx]
        to_lon = g.es['to.x'][idx]
        to_lat = g.es['to.y'][idx]
        seg_name = g.es['RD_CD_DESC'][idx]
        seg_len = g.es['SHAPE_LEN'][idx]
        max_speed = g.es['max_speed'][idx]
        outputrow = [seg_id, from_lon, from_lat, to_lon, to_lat, seg_name, seg_len, max_speed]
        print(outputrow)
        outputwriter.writerow(outputrow)

# ebs = g.edge_betweenness()
# max_eb = max(ebs)
# print(max_eb)
# [g.es[idx].tuple for idx, eb in enumerate(ebs) if eb == max_eb]
