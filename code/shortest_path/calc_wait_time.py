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
            travel_time = float(row[2])
            edge_len_list.append(travel_time)
        counter += 1

## Add the attributes (edge index and travel time) to the edges
counter = 0
for edge in graph.es:
    edge['index'] = edge_idx_list[counter]
    edge['travel_time'] = edge_len_list[counter]
    counter += 1 
summary(graph)

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
        travel_time = found_edge['travel_time']
        if travel_time > 0:
            time_cost += travel_time
        else:
            print (edge['index'], travel_time)
    return time_cost

## Read the CSV output path_df as pandas data frame
path_filename = '../../data/test/sin/student/sanjay_path_30_100.csv'
path_df = pd.read_csv(path_filename, sep=',', header=None)

## Read the corresponding input filename
taxi_loc = {} # mapping from taxi_no (location node) to list of its incident edges (indices)
origin_edges = {} # mapping from origin node to list of its incident edges (indices) 
dest_edges = {} # mapping from destination node to list of its incident edges (indices)
origin_dest = {} # mapping from origin to destination node 
origin_time = {} # mapping from origin node to its pickup time
taxi_counter = 1
## TODO: Remember to change this input file correspondingly!!
input_filename = '../../data/test/sin/rand_c/sin_test_30_100.txt'
f = open(input_filename, 'r')
for line in f:
    tokens = line.split(', ')
    if len(tokens) > 1:
        origin_node = int(tokens[0])
        dest_node = int(tokens[1])
        ## Mapping from origin to destination
        origin_dest[origin_node] = dest_node
        ## Get all the incident edges to the origin and destination node
        origin_node_edges = graph.incident(origin_node)
        edge_list = []
        for edge in origin_node_edges:
            edge_list.append(edge)
        origin_edges[origin_node] = edge_list
        
        dest_node_edges = graph.incident(dest_node)
        edge_list = []
        for edge in dest_node_edges:
            edge_list.append(edge)
        dest_edges[dest_node] = edge_list
        ## Mapping from origin node to pickup time
        pickup_time = int(tokens[2])
        origin_time[origin_node] = pickup_time
    else:
        a_taxi_loc = int(tokens[0])
        ## Get all incident edges to the node
        taxi_loc_edges = graph.incident(a_taxi_loc)
        edge_list = []
        for edge in taxi_loc_edges:
            edge_list.append(graph.es[edge]['index'])
        taxi_loc[taxi_counter] = edge_list
        taxi_counter += 1
f.close()

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
    subset_path_df = path_df.loc[path_df['taxi'] == taxi_no]
    
    ## Find row indices that indicate 'Taxi', 'Start' and 'End'
    taxi_idx = subset_path_df[subset_path_df['indicator'] == 'Taxi'].index.tolist()
    start_idx = subset_path_df[subset_path_df['indicator'] == 'Start'].index.tolist()
    end_idx = subset_path_df[subset_path_df['indicator'] == 'End'].index.tolist()
    
    ## Make sure equal number of taxis, starts and ends
    if len(taxi_idx) == len(start_idx) and len(start_idx) == len(end_idx):
        ## The cumulative wait time for *this* taxi
        cumulative_wait_time = 0
        ## Go through each trip
        for i in range(len(taxi_idx)):    
            sub_path_wait = subset_path_df.loc[taxi_idx[i]:(start_idx[i]-1)]
            status = sub_path_wait['indicator'].tolist()
            wait_edges = sub_path_wait['edge']
            
            if i == 0:
                ## Check if the taxi's path is incident on its original location node
                assert status[0] == 'Taxi', 'Wrong status: %s' % status[0]
                taxi_edges = wait_edges.tolist()
                a_taxi_edge = taxi_edges[0]
                big_edge_list = [item for sublist in taxi_loc.values() for item in sublist]
#                 assert a_taxi_edge in big_edge_list, 'a_taxi_edge not found in big_edge_list: %s' % a_taxi_edge
                if a_taxi_edge not in big_edge_list:
                    print 'taxi_edge cannot be verified: ' + str(a_taxi_edge)
            ## Time from taxi's location to origin node    
            time_to_origin = get_time_cost(graph, wait_edges)
            
            ## Time from origin to destination node
            sub_path_travel = subset_path_df.loc[start_idx[i]:end_idx[i]]
            status = sub_path_travel['indicator'].tolist()
            travel_edges = sub_path_travel['edge']
            travel_edge_list = travel_edges.tolist()
            time_list = sub_path_travel['time'].tolist()
            
            for j in range(len(status)):
                if status[j] == 'Start':
                    ## Check if pickup edge contains the origin;
                    start_edge = travel_edge_list[j]
                    ## Determine check origin node it contains
                    this_origin_node = None
                    dest_node = None # the supposed destination
                    for origin_node in origin_edges.keys():
                        start_edges = origin_edges[origin_node]
                        if start_edge in start_edges:
                            this_origin_node = origin_node
                            break
#                     assert this_origin_node is not None, 'origin_node could not be found: %s' % this_origin_node
                    if this_origin_node is None:
                        print 'start_edge cannot be verified: ' + str(start_edge)
                    if this_origin_node is not None:
                        dest_node = origin_dest[this_origin_node]
                        ## Check if the origin node matches the pickup time
                        this_pickup_time = origin_time[this_origin_node]
                        pickup_time = int(time_list[j])
#                         assert this_pickup_time == pickup_time, 'pickup_time does not match: %s' % pickup_time
                        if this_pickup_time != pickup_time:
                            print 'pickup_time cannot be verified: ' + str(pickup_time)
                if status[j] == 'End':
                    ## Check if the destination matches the right origin
                    end_edge = travel_edge_list[j]
                    this_dest_node = None
                    for a_dest_node in dest_edges.keys():
                        end_edges = dest_edges[a_dest_node]
                        if end_edge in end_edges:
                            this_dest_node = a_dest_node
                            break
                    if this_dest_node is None:
                        print 'end_edge cannot be verified: ' + str(end_edge)
                    if this_dest_node is not None and dest_node is not None:
#                         assert this_dest_node == dest_node, 'this_dest_node does not match: %s' % this_dest_node
                        if this_dest_node != dest_node:
                            print 'this_dest_node cannot be matched: ' + str(this_dest_node)
            
            ## TODO: Check if the 'Start' edge is the destination of the previous trip
            
            time_to_dest = get_time_cost(graph, travel_edges)
            total_time += (time_to_origin + time_to_dest)
            
            if is_scheduling:
                request_time = subset_path_df.loc[start_idx[i]]['time']
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
