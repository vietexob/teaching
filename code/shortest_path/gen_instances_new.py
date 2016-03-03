'''
Created on Mar 3, 2016

To generate new training and test instances based on the giant connected subgraph.

@author: trucvietle
'''

from igraph import *
import pandas as pd
import numpy as np
import random

graph_filename = '../../data/networks/sin_road_subgraph.graphml'
graph = Graph.Read_GraphML(f=graph_filename)
summary(graph)
print(graph.is_directed())

num_taxis = [5, 10, 20, 50, 100]
num_ods_a = [5, 10, 20, 50, 100] # part a: N = K
num_ods_b = [6, 15, 25, 60, 120] # part b: N < K

## Generate random taxi locations and OD pairs
for i in range(len(num_taxis)):
    taxi_loc_list = []
    origin_list = []
    dest_list = []
    
    ## Generate equal numbers of taxi locs and OD pairs
    a_num_taxis = num_taxis[i]
    a_num_ods = num_ods_a[i]
    
    if a_num_taxis == a_num_ods:
        for j in range(a_num_taxis):
            taxi_loc = random.choice(graph.vs)
            taxi_loc = taxi_loc.index
            while taxi_loc in taxi_loc_list or taxi_loc in origin_list or taxi_loc in dest_list:
                taxi_loc = random.choice(graph.vs)
                taxi_loc = taxi_loc.index
            taxi_loc_list.append(taxi_loc)
            
            origin = random.choice(graph.vs)
            origin = origin.index
            while origin in taxi_loc_list or origin in origin_list or origin in dest_list:
                origin = random.choice(graph.vs)
                origin = origin.index
            origin_list.append(origin)
            
            destination = random.choice(graph.vs)
            destination = destination.index
            while destination in taxi_loc_list or destination in origin_list or destination in dest_list:
                destination = random.choice(graph.vs)
                destination = destination.index
            dest_list.append(destination)
        
        ## Write to an output text file
        out_filename = '../../data/training/sin/sin_train_' + str(a_num_taxis) + '_' + str(a_num_ods) + '.txt'
        f = open(out_filename, 'w')
        for j in range(a_num_taxis):
            f.write(str(taxi_loc_list[j]) + '\n')
        for j in range(a_num_ods):
            f.write(str(origin_list[j]) + ', ' + str(dest_list[j]) + '\n')
        f.close()
        print('Written to file: ' + out_filename)
        
        ## Create a shortest-path distance matrix between each taxi location and each origin
        dist_matrix = np.zeros(shape=(a_num_taxis, a_num_ods))
        for j in range(a_num_taxis):
            a_taxi_loc = taxi_loc_list[j]
            for k in range(a_num_ods):
                an_origin = origin_list[k]
                dist = graph.shortest_paths(source=a_taxi_loc, target=an_origin, weights='travel_time')
                dist = dist[0][0]
                dist_matrix[j, k] = dist
        
        ## Save the distance matrix
        dist_matrix_df = pd.DataFrame(dist_matrix, index=taxi_loc_list)
        dist_matrix_df.columns = origin_list
        out_filename = '../../data/training/sin/dist_mat_' + str(a_num_taxis) + '_' + str(a_num_ods) + '.csv'
        dist_matrix_df.to_csv(out_filename)
        print('Written to file: ' + out_filename)
        
    ## Generate OD pairs for part b
    origin_list = []
    dest_list = []
    time_list = []
    a_num_ods = num_ods_b[i]
    
    if a_num_taxis < a_num_ods:
        for j in range(a_num_ods):
            origin = random.choice(graph.vs)
            origin = origin.index
            while origin in taxi_loc_list or origin in origin_list or origin in dest_list:
                origin = random.choice(graph.vs)
                origin = origin.index
            origin_list.append(origin)
            
            destination = random.choice(graph.vs)
            destination = destination.index
            while destination in taxi_loc_list or destination in origin_list or destination in dest_list:
                destination = random.choice(graph.vs)
                destination = destination.index
            dest_list.append(destination)
            
            ## Generate a random pickup time in 60 minutes
            pickup_time = random.randint(0, 60)
            time_list.append(pickup_time)
        
        ## Write to an output text file
        out_filename = '../../data/training/sin/sin_train_' + str(a_num_taxis) + '_' + str(a_num_ods) + '.txt'
        f = open(out_filename, 'w')
        for j in range(a_num_taxis):
            f.write(str(taxi_loc_list[j]) + '\n')
        for j in range(a_num_ods):
            f.write(str(origin_list[j]) + ', ' + str(dest_list[j]) + ', ' + str(time_list[j]) + '\n');
        f.close()
        print('Written to file: ' + out_filename)
