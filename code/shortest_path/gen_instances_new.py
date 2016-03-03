'''
Created on Mar 3, 2016

To generate new training and test instances based on the giant connected subgraph.

@author: trucvietle
'''

from igraph import *
import random
import csv

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






