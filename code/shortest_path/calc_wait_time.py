'''
Created on Apr 6, 2016

Compute the total and average wait time of a given output path.

@author: trucvietle
'''

from progressbar import ProgressBar
from igraph import *
import pandas as pd
import math
import csv
import sys

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
            time_to_dest = float(row[2])
            edge_len_list.append(time_to_dest)
        counter += 1

## Add the attributes (edge index and travel time) to the edges
counter = 0
for edge in graph.es:
    edge['index'] = edge_idx_list[counter]
    edge['time_to_dest'] = edge_len_list[counter]
    counter += 1 
# summary(graph)

def get_time_cost(graph=None, edges=[]):
    '''
    Returns the total time cost of the given path (edges).
    '''
    time_cost = 0
    if graph is None or len(edges) == 0:
        sys.exit('Invalid input!')
    
    for edge in edges:
        edge = int(edge)
        found_edge = graph.es.find(index = edge)
        time_to_dest = found_edge['time_to_dest']
        if time_to_dest > 0:
            time_cost += time_to_dest
        else:
            print (edge['index'], time_to_dest)
    return time_cost

## Read the CSV output path_df as pandas data frame
path_filename = '../../data/test/sin/student/sanjay_path_30_100.csv'
path_df = pd.read_csv(path_filename, sep=',', header=None)

## Read the corresponding input filename
taxi_loc = {} # mapping of taxi_no to its original location
origin_dest = {} # mapping of origin node to its destination node
origin_time = {} # mapping of origin node to its requested pickup time
input_filename = '../../data/test/sin/rand_c/sin_test_30_100.txt'
f = open(input_filename, 'r')
for line in f:
    tokens = line.split(', ')
    if len(tokens) > 1:
        print tokens[len(tokens)-1]
    else:
        print tokens[0]
f.close()
sys.exit()

## Determine if part (a) [assignment] or (b) [scheduling]
is_scheduling = False
if path_df.shape[1] == 4: # part (b)
    ## Assign the header
    path_df.columns = ['taxi', 'indicator', 'time', 'edge']
    is_scheduling = True
else: # part (a)
    ## Assign the header
    path_df.columns = ['indicator', 'edge']
    ## Add a dummy taxi number column
    path_df['taxi'] = [1] * path_df.shape[0]

max_taxi_no = max(path_df['taxi'])
print max_taxi_no
total_wait_time = 0
total_time = 0
total_num_trips = 0

## Go through each taxi no
progress = ProgressBar(maxval=max_taxi_no).start()
for taxi_no in range(max_taxi_no):
    taxi_no += 1
    progress.update(taxi_no)
    ## Subset by taxi_no
    sub_path_df = path_df.loc[path_df['taxi'] == taxi_no]
    
    ## Find row indices that indicate 'Taxi', 'Start' and 'End'
    taxi_idx = sub_path_df[sub_path_df['indicator'] == 'Taxi'].index.tolist()
    start_idx = sub_path_df[sub_path_df['indicator'] == 'Start'].index.tolist()
    end_idx = sub_path_df[sub_path_df['indicator'] == 'End'].index.tolist()
    
    ## Make sure equal number of taxis, starts and ends
    if len(taxi_idx) == len(start_idx) and len(start_idx) == len(end_idx):
        ## The cumulative wait time for *this* taxi
        cumulative_wait_time = 0
        ## Go through each trip
        for i in range(len(taxi_idx)):
            ## Time from taxi's location to origin node
            sub_path_wait = sub_path_df.loc[taxi_idx[i]:(start_idx[i]-1)]
            wait_edges = sub_path_wait['edge']
            time_to_origin = get_time_cost(graph, wait_edges)
            
            ## Time from origin to destination node
            sub_path_travel = sub_path_df.loc[start_idx[i]:end_idx[i]]
            travel_edges = sub_path_travel['edge']
            time_to_dest = get_time_cost(graph, travel_edges)
            total_time += (time_to_origin + time_to_dest)
            
            if is_scheduling:
                request_time = sub_path_df.loc[start_idx[i]]['time']
                if request_time is math.isnan(request_time):
                    sys.exit('request_time is NA!')
                else:
                    arrival_time = time_to_origin + cumulative_wait_time
                    passenger_wait_time = max(0, arrival_time - request_time)
                    total_wait_time += passenger_wait_time
                    actual_wait_time = max(arrival_time, request_time)
                    cumulative_wait_time = (actual_wait_time + time_to_dest)
            else:
                total_wait_time += time_to_origin
            total_num_trips += 1
    else:
        progress.finish()
        sys.exit('taxi_idx, start_idx and/or end_idx length mismatched!')

avg_wait_time = total_wait_time / total_num_trips
avg_total_time = total_time / total_num_trips
if is_scheduling:
    print '\ntotal_wait_time = {0:.2f}'.format(total_wait_time)
    print 'avg_wait_time = {0:.2f}'.format(avg_wait_time)
else:
    print '\ntotal_time = {0:.2f}'.format(total_time)
    print 'avg_total_time = {0:.2f}'.format(avg_total_time)
