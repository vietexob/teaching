'''
Created on Oct 4, 2015

Generate the learning/test instances for the routing programming assignment.

@author: trucvietle
'''

from igraph import *
import random
import csv
# import sys

filename = '../../data/networks/sin_road_network.graphml'
# filename = '../../data/networks/pgh_road_network.graphml'
# filename = '../../data/networks/was_road_network.graphml'
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

N = 100 # the number of OD pairs
K = 80 # the number of taxis

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

out_filename = '../../data/instances/sin_train_' + str(N) + '_' + str(K) + '.txt'
# out_filename = '../../data/instances/pgh_train_' + str(N) + '_' + str(K) + '.txt'
# out_filename = '../../data/instances/was_train_' + str(N) + '_' + str(K) + '.txt'
out_file = open(out_filename, 'w')
out_file.write(str(N) + '\n')
out_file.write(str(K) + '\n')
for i in range(N):
    out_file.write(str(source_list[i]) + ", " + str(target_list[i]) + "\n")
for i in range(K):
    out_file.write(str(loc_list[i]) + "\n")
out_file.close()

## Randomly match vehicles to origins
match_paths = []
for i in range(K):
    source = loc_list[i]
    target = source_list[i]
    match_path = g.get_shortest_paths(v=source, to=target, weights='SHAPE_LEN', mode=ALL, output='epath')
    match_path = match_path[0]
    match_paths.append(match_path)
# print(match_paths)
## Perform shortest path routings for all OD pairs
shortest_paths = []
for i in range(K):
    source = source_list[i]
    target = target_list[i]
    shortest_path = g.get_shortest_paths(v=source, to=target, weights='SHAPE_LEN', mode=ALL, output='epath')
#     shortest_path = g.get_shortest_paths(v=source, to=target, weights='length', mode=ALL, output='epath')
    shortest_path = shortest_path[0]
    shortest_paths.append(shortest_path)
# print(shortest_paths)

## Save the shortest paths to output file
out_filename = '../../data/instances/sin_shortest_path_' + str(N) + '_' + str(K) + '.csv'
# out_filename = '../../data/instances/pgh_shortest_path_' + str(N) + '_' + str(K) + '.csv'
# out_filename = '../../data/instances/was_shortest_path_' + str(N) + '_' + str(K) + '.csv'

def write_path(writer, g, is_us=False, is_shortest_path=False, path=[]):
    for j in range(len(path)):
            edge_idx = path[j]
            indicator = 'Trans'
            if is_shortest_path:
                if j == 0:
                    indicator = 'Start'
                elif j == len(path)-1:
                    indicator = 'End'
            else:
                if j == 0:
                    indicator = 'Taxi'
            
            from_lon = g.es['from.x'][edge_idx]
            from_lat = g.es['from.y'][edge_idx]
            to_lon = g.es['to.x'][edge_idx]
            to_lat = g.es['to.y'][edge_idx]
            if is_us:
                st_name = g.es['street.name'][edge_idx]
                seg_len = g.es['length'][edge_idx]
                speed = g.es['avg_speed'][edge_idx]
            else:
                st_name = g.es['RD_CD_DESC'][edge_idx]
                seg_len = g.es['SHAPE_LEN'][edge_idx]
                speed = g.es['max_speed'][edge_idx]
            
            output_row = [indicator, from_lon, from_lat, to_lon, to_lat, st_name, seg_len, speed]
            print(output_row)
            writer.writerow(output_row)

with open(out_filename, 'wb') as csvfile:
    out_writer = csv.writer(csvfile, delimiter=',')
    for i in range(K):
        match_path = match_paths[i]
        shortest_path = shortest_paths[i]
        write_path(out_writer, g, is_us=False, is_shortest_path=False, path=match_path)
        write_path(out_writer, g, is_us=False, is_shortest_path=True, path=shortest_path)