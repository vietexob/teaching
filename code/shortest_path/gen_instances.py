'''
Created on Oct 4, 2015

Generate the learning/test instances for the routing programming assignment.

@author: trucvietle
'''

from igraph import *
import random
import csv

is_sin = True # is Singapore
is_pgh = False # is Pittsburgh

K = 25 # the number of demands (OD pairs)
N = 20 # the number of taxis

filename = ''
if is_sin:
    filename = '../../data/networks/sin_road_network.graphml'
else:
    if is_pgh:
        filename = '../../data/networks/pgh_road_network.graphml'
    else:
        filename = '../../data/networks/was_road_network.graphml'
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

## Generate K random OD pairs
source_list = []
target_list = []
time_list = [] # pickup times
for i in range(K):
    source = random.choice(giant)
    while source in source_list:
        source = random.choice(giant)
    source_list.append(source)
    
    target = random.choice(giant)
    while target in target_list or source == target:
        target = random.choice(giant)
    target_list.append(target)
    
    if N != K:
        ## Generate a random pickup time within 1 hour
        pickup_time = random.randint(0, 60)
        time_list.append(pickup_time)

## Generate N vehicle locations
loc_list = []
for i in range(N):
    loc = random.choice(giant)
    while loc in source_list or loc in target_list or loc in loc_list:
        loc = random.choice(giant)
    loc_list.append(loc)

## Write the generated OD pairs and taxi locations
out_filename = ''
if is_sin:
    out_filename = '../../data/test/sin/sin_test_' + str(K) + '_' + str(N) + '.txt'
else:
    if is_pgh:
        out_filename = '../../data/test/pgh/pgh_test_' + str(K) + '_' + str(N) + '.txt'
    else:
        out_filename = '../../data/test/was/was_test_' + str(K) + '_' + str(N) + '.txt'
out_file = open(out_filename, 'w')
out_file.write(str(K) + '\n')
out_file.write(str(N) + '\n')
for i in range(K):
    if len(time_list) > 0:
        out_file.write(str(source_list[i]) + ", " + str(target_list[i]) + ", " + str(time_list[i]) + "\n")
    else:
        out_file.write(str(source_list[i]) + ", " + str(target_list[i]) + "\n")
for i in range(N):
    out_file.write(str(loc_list[i]) + "\n")
out_file.close()

def write_path(writer, g, is_us=False, is_shortest_path=False,
               path=[], is_scheduling=False, taxi_no=0, pickup_time=0):
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
            
#             from_lon = g.es['from.x'][edge_idx]
#             from_lat = g.es['from.y'][edge_idx]
#             to_lon = g.es['to.x'][edge_idx]
#             to_lat = g.es['to.y'][edge_idx]
            
            if is_us:
#                 st_name = g.es['street.name'][edge_idx]
                seg_len = g.es['length'][edge_idx]
                speed = g.es['avg_speed'][edge_idx]
            else:
#                 st_name = g.es['RD_CD_DESC'][edge_idx]
                seg_len = g.es['SHAPE_LEN'][edge_idx]
                speed = g.es['max_speed'][edge_idx]
            
#             output_row = [indicator, from_lon, from_lat, to_lon, to_lat, seg_len, speed]
#             output_row = [indicator, from_node, to_node, seg_len, speed]
#             edge_idx = edge_idx + 1
            if is_scheduling:
                if indicator == 'Start':
                    output_row = [taxi_no, indicator, pickup_time, edge_idx, seg_len, speed]
                else:
                    output_row = [taxi_no, indicator, 'NA', edge_idx, seg_len, speed]
            else:
                output_row = [indicator, edge_idx, seg_len, speed]
            writer.writerow(output_row)

## Randomly match vehicles to origins
match_paths = []
taxi_source = [] # matching from taxis to origins
for i in range(K): # iterate over each OD pair
    ## Assign taxis to origins
    if i < N:
        taxi_source.append(i)
    else:
        taxi_source.append(random.choice(range(N)))

## Sort by taxi ID
taxi_source = sorted(taxi_source)
for i in range(K):
    target = source_list[i] # go to the origin
    this_taxi = taxi_source[i]
    source = loc_list[this_taxi]
    
    if i > 0:
        prev_taxi = taxi_source[i-1]
        if this_taxi == prev_taxi: # the same taxi is reused
            source = target_list[i] # because it has to deliver the previous passenger
    
    match_path = g.get_shortest_paths(v=source, to=target, weights='SHAPE_LEN', mode=ALL, output='epath')
    match_path = match_path[0]
    match_paths.append(match_path)
 
## Perform shortest path routings for all OD pairs
shortest_paths = []
for i in range(K):
    source = source_list[i]
    target = target_list[i]
    if is_sin:
        shortest_path = g.get_shortest_paths(v=source, to=target, weights='SHAPE_LEN', mode=ALL, output='epath')
    else:
        shortest_path = g.get_shortest_paths(v=source, to=target, weights='length', mode=ALL, output='epath')
    shortest_path = shortest_path[0]
    shortest_paths.append(shortest_path)
 
## Save the shortest paths to output file
if is_sin:
    out_filename = '../../data/instances/sin_random_' + str(N) + '_' + str(K) + '.csv'
else:
    if is_pgh:
        out_filename = '../../data/instances/pgh_shortest_path_' + str(N) + '_' + str(K) + '.csv'
    else:
        out_filename = '../../data/instances/was_shortest_path_' + str(N) + '_' + str(K) + '.csv'
 
with open(out_filename, 'wb') as csvfile:
    out_writer = csv.writer(csvfile, delimiter=',')
    is_us = not is_sin # is this a US city?
    for i in range(K):
        taxi_no = taxi_source[i] + 1
        is_scheduling = K > N
        if is_scheduling:
            pickup_time = time_list[i]
        else:
            pickup_time = 0
        
        match_path = match_paths[i] # taxi to passenger assignment
        shortest_path = shortest_paths[i] # the routed shortest path
        write_path(out_writer, g, is_us=is_us, is_shortest_path=False, path=match_path,
                   is_scheduling=is_scheduling, taxi_no=taxi_no, pickup_time=pickup_time)
        write_path(out_writer, g, is_us=is_us, is_shortest_path=True, path=shortest_path,
                   is_scheduling=is_scheduling, taxi_no=taxi_no, pickup_time=pickup_time)
