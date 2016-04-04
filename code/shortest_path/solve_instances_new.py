'''
Created on Mar 3, 2016

Solve the new training and test instances using the subgraph.

@author: trucvietle
'''

from igraph import *
import pandas as pd
import numpy as np
import csv

# graph_filename = '../../data/networks/sin_road_subgraph.graphml'
# graph = Graph.Read_GraphML(f=graph_filename)
# summary(graph)
# print(graph.is_directed())

## Second method: Construct the graph using adjacency lists
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

def write_path(writer, g, path=[], is_od_path=False,
               is_scheduling=False, taxi_no=0, pickup_time=0):
    total_travel = 0
    for i in range(len(path)):
        edge_idx = path[i]
        indicator = 'Trans'
        if is_od_path:
            if i == 0:
                indicator = 'Start'
            elif i == len(path)-1:
                indicator = 'End'
        else:
            if i == 0:
                indicator = 'Taxi'
        
        travel_time = g.es['travel_time'][edge_idx]
        total_travel += travel_time
        ## Get the 'real' edge index
        real_idx = g.es['index'][edge_idx]
        
        if is_scheduling:
            if indicator == 'Start':
#                 output_row = [taxi_no, indicator, pickup_time, edge_idx]
                output_row = [taxi_no, indicator, pickup_time, real_idx]
            else:
#                 output_row = [taxi_no, indicator, 'NA', edge_idx]
                output_row = [taxi_no, indicator, 'NA', real_idx]
        else:
#             output_row = [indicator, edge_idx]
            output_row = [indicator, real_idx]
        writer.writerow(output_row)
    return total_travel

## Load the instances
# num_taxis = [5, 10, 20, 50, 100]
# num_ods_a = [5, 10, 20, 50, 100] # part a: N = K
# num_ods_b = [6, 15, 25, 60, 120] # part b: N < K
## The TEST instances
num_taxis = [10, 13, 16]
num_ods_a = [10, 13, 16] # part (a)
num_ods_b = [13, 18, 23] # part (b)

## The result outputs
results_a = np.zeros(shape=(len(num_taxis), 3))
results_b = np.zeros(shape=(len(num_ods_b), 3))

for i in range(len(num_taxis)):
    a_num_taxi = num_taxis[i]
    a_num_ods_a = num_ods_a[i]
    a_num_ods_b = num_ods_b[i]
    
    results_a[i, 0] = a_num_taxi
    results_a[i, 1] = a_num_ods_a
    total_travel = 0
    
    ## Do part a)
    if a_num_taxi == a_num_ods_a:
        ## Read the assignment
#         dir_str = '../../data/training/sin/assign_'
        dir_str = '../../data/test/sin/assign_'
        assign_filename = dir_str + str(a_num_taxi) + '_' + str(a_num_ods_a) + '.txt'
        f = open(assign_filename, 'rU')
        assignment = f.readlines()
        ## Read the original OD pairs
#         dir_str = '../../data/training/sin/sin_train_'
        dir_str = '../../data/test/sin/sin_train_'
        instance_filename = dir_str + str(a_num_taxi) + '_' + str(a_num_ods_a) + '.txt'
        g = open(instance_filename, 'rU')
        instance = g.readlines()
        instance = instance[a_num_taxi:]
        
        taxi_origin = {} # mapping from taxi to assigned origin
        origin_dest = {} # mapping from origin to destination
        for j in range(len(assignment)):
            an_assignment = assignment[j]
            a_taxi_loc = int(an_assignment.split(', ')[0])
            an_origin = int(an_assignment.split(', ')[1])
            taxi_origin[a_taxi_loc] = an_origin
            
            an_instance = instance[j]
            an_origin = int(an_instance.split(', ')[0])
            a_dest = int(an_instance.split(', ')[1])
            origin_dest[an_origin] = a_dest
        f.close()
        g.close()
        
        ## Perform shortest-path routing
#         dir_str = '../../data/training/sin/path_'
        dir_str = '../../data/test/sin/path_'
        out_filename = dir_str + str(a_num_taxi) + '_' + str(a_num_ods_a) + '.csv'
        with open(out_filename, 'wb') as csvfile:
            out_writer = csv.writer(csvfile, delimiter=',')
            for a_taxi_loc in taxi_origin.keys():
                an_origin = taxi_origin[a_taxi_loc]
                assign_path = graph.get_shortest_paths(v=a_taxi_loc, to=an_origin, weights='travel_time', output='epath')
                assign_path = assign_path[0]
                assign_path_time = write_path(out_writer, graph, assign_path, is_od_path=False)
                
                a_dest = origin_dest[an_origin]
                od_path = graph.get_shortest_paths(v=an_origin, to=a_dest, weights='travel_time', output='epath')
                od_path = od_path[0]
                od_path_time = write_path(out_writer, graph, od_path, is_od_path=True)
                
                ## Calculate the total travel time
#                 assign_path_time = graph.shortest_paths(source=a_taxi_loc, target=an_origin, weights='travel_time')
#                 assign_path_time = assign_path_time[0][0]
#                 od_path_time = graph.shortest_paths(source=a_taxi_loc, target=an_origin, weights='travel_time')
#                 od_path_time = od_path_time[0][0]
                total_travel += assign_path_time + od_path_time
        print('Written to file: ' + out_filename)
    
    results_a[i, 2] = total_travel
    results_b[i, 0] = a_num_taxi
    results_b[i, 1] = a_num_ods_b
    total_wait = 0
    
    ## Do part b)
    if a_num_taxi < a_num_ods_b:
        ## Read the instance
#         dir_str = '../../data/training/sin/sin_train_'
        dir_str = '../../data/test/sin/sin_train_'
        instance_filename = dir_str + str(a_num_taxi) + '_' + str(a_num_ods_b) + '.txt'
        f = open(instance_filename, 'rU')
        instance = f.readlines()
        taxi_locs = instance[0:a_num_taxi]
        od_pairs = instance[a_num_taxi:]
        f.close()
        
#         dir_str = '../../data/training/sin/path_'
        dir_str = '../../data/test/sin/path_'
        out_filename = dir_str + str(a_num_taxi) + '_' + str(a_num_ods_b) + '.csv'
        with open(out_filename, 'wb') as csvfile:
            out_writer = csv.writer(csvfile, delimiter=',')
            assign_travel_times = []
            od_travel_times = []
            ## Perform random assignment
            for j in range(a_num_ods_b):
                taxi_idx = j % a_num_taxi
                a_taxi_loc = int(taxi_locs[taxi_idx])
                an_origin = int(od_pairs[j].split(', ')[0])
                a_dest = int(od_pairs[j].split(', ')[1])
                a_time = int(od_pairs[j].split(', ')[2])
                
                if taxi_idx < j: # taxi location is the 'previous' destination
                    a_taxi_loc = int(od_pairs[taxi_idx].split(', ')[1])
                
                assign_path = graph.get_shortest_paths(v=a_taxi_loc, to=an_origin, weights='travel_time', output='epath')
                assign_path = assign_path[0]
                assign_path_time = write_path(out_writer, graph, assign_path, is_od_path=False,
                                              is_scheduling=True, taxi_no=(taxi_idx+1), pickup_time=a_time)
                assign_travel_times.append(assign_path_time)
                
                if taxi_idx == j: # no 'scheduled'
                    wait_time = assign_path_time - a_time
                else: # is 'scheduled'
                    wait_time = (assign_travel_times[taxi_idx] + od_travel_times[taxi_idx] + assign_path_time) - a_time
                wait_time = max(0, wait_time)
                total_wait += wait_time
                
                od_path = graph.get_shortest_paths(v=an_origin, to=a_dest, weights='travel_time', output='epath')
                od_path = od_path[0]
                od_path_time = write_path(out_writer, graph, od_path, is_od_path=True, 
                                          is_scheduling=True, taxi_no=(taxi_idx+1), pickup_time=a_time)
                od_travel_times.append(od_path_time)
        print('Written to file: ' + out_filename)
    
    avg_wait_time = total_wait / a_num_ods_b
    results_b[i, 2] = avg_wait_time
    
results_a_df = pd.DataFrame(results_a)
results_a_df.columns = ['num_taxis', 'num_ods', 'total_time']
# out_filename = '../../data/training/sin/results_a.csv'
out_filename = '../../data/test/sin/results_a.csv'
results_a_df.to_csv(out_filename, index=False)
print('Written to file: ' + out_filename)

results_b_df = pd.DataFrame(results_b)
results_b_df.columns = ['num_taxis', 'num_ods', 'avg_wait']
# out_filename = '../../data/training/sin/results_b.csv'
out_filename = '../../data/test/sin/results_b.csv'
results_b_df.to_csv(out_filename, index=False)
print('Written to file: ' + out_filename)
