'''
Created on Mar 3, 2016

Solve the new training and test instances using the subgraph.

@author: trucvietle
'''

from igraph import *
import csv

graph_filename = '../../data/networks/sin_road_subgraph.graphml'
graph = Graph.Read_GraphML(f=graph_filename)
summary(graph)
print(graph.is_directed())

def write_path(writer, g, path=[], is_od_path=False):
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
        
#         travel_time = g.es['travel_time'][edge_idx]
        output_row = [indicator, edge_idx]
        writer.writerow(output_row)

## Load the instances
num_taxis = [5, 10, 20, 50, 100]
num_ods_a = [5, 10, 20, 50, 100] # part a: N = K
num_ods_b = [6, 15, 25, 60, 120] # part b: N < K

for i in range(len(num_taxis)):
    a_num_taxi = num_taxis[i]
    a_num_ods_a = num_ods_a[i]
    a_num_ods_b = num_ods_b[i]
    
    if a_num_taxi == a_num_ods_a:
        ## Read the assignment
        assign_filename = '../../data/training/sin/assign_' + str(a_num_taxi) + '_' + str(a_num_ods_a) + '.txt'
        f = open(assign_filename, 'rU')
        assignment = f.readlines()
        ## Read the original OD pairs
        instance_filename = '../../data/training/sin/sin_train_' + str(a_num_taxi) + '_' + str(a_num_ods_a) + '.txt'
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
        out_filename = '../../data/training/sin/path_' + str(a_num_taxi) + '_' + str(a_num_ods_a) + '.csv'
        with open(out_filename, 'wb') as csvfile:
            out_writer = csv.writer(csvfile, delimiter=',')
            for a_taxi_loc in taxi_origin.keys():
                an_origin = taxi_origin[a_taxi_loc]
                assign_path = graph.get_shortest_paths(v=a_taxi_loc, to=an_origin, weights='travel_time', output='epath')
                assign_path = assign_path[0]
                write_path(out_writer, graph, assign_path, is_od_path=False)
                
                a_dest = origin_dest[an_origin]
                od_path = graph.get_shortest_paths(v=an_origin, to=a_dest, weights='travel_time', output='epath')
                od_path = od_path[0]
                write_path(out_writer, graph, od_path, is_od_path=True)
        print('Written to file: ' + out_filename)
