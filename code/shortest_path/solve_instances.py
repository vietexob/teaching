'''
Created on Feb 29, 2016

Solve the shortest path matching from taxi locations to customer origins.

@author: trucvietle
'''

from igraph import *
import pandas as pd
import numpy as np
import csv

## Read the adjacency matrices
time_filename = '../../data/adj_matrices/adj_matrices/travel_time_matrix.csv'
edge_idx_filename = '../../data/adj_matrices/adj_matrices/edge_idx_matrix.csv'
node_idx_filename = '../../data/adj_matrices/adj_matrices/node_idx_id.csv'

## Read the CSV file, ignore the header (first row)
travel_time_df = pd.read_csv(time_filename, skiprows=1, header=None)
edge_idx_df = pd.read_csv(edge_idx_filename, skiprows=1, header=None)
node_idx_df = pd.read_csv(node_idx_filename)

## Get the value as np.array
travel_time_val = travel_time_df.values
edge_idx_val = edge_idx_df.values

## Create a graph using non-zero matrix entries
travel_time_graph = Graph.Adjacency((travel_time_val > 0).tolist(), mode=ADJ_UNDIRECTED)
## Add edge attributes and node labels
travel_time_graph.es['weight'] = travel_time_val[travel_time_val.nonzero()]
travel_time_graph.es['index'] = edge_idx_val[edge_idx_val.nonzero()]
travel_time_graph.vs['label'] = node_idx_df['id'].values
travel_time_graph.vs['index'] = node_idx_df['idx'].values

## Load the training instances
num_taxis = [5, 5, 10, 10, 10, 20, 20, 25]
num_ods = [5, 10, 10, 15, 20, 20, 25, 25]

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
        
        travel_time = g.es['weight'][edge_idx]
        ## TODO: Is this still needed?
#         edge_idx = edge_idx + 1
        output_row = [indicator, edge_idx, travel_time]
        writer.writerow(output_row)

for i in range(len(num_taxis)):
    a_num_taxis = num_taxis[i]
    
    ## Get the shortest-path distance matrix
    a_num_ods = num_ods[i]
    instance_filename = '../../data/training/sin/sin_test_' + str(a_num_ods) + '_' + str(a_num_taxis) + '.txt'
    f = open(instance_filename, 'rU')
    contents = f.readlines()
    if len(contents) > 2:
        if int(contents[0]) == int(contents[1]): # for part a) only
            ## Assume having the assignment
            assign_filename = '../../data/training/sin/assign_' + str(a_num_ods) + '_' + str(a_num_taxis) + '.txt'
            g = open(assign_filename, 'rU')
            assignment = g.readlines()
            destinations = [] # list of destinations
            assigned_taxis = [] # list of assigned taxis
            assigned_origins = [] # list of assigned origins
            
            od_pairs = contents[2:(2+a_num_taxis)]
            taxi_locs = contents[(2+a_num_taxis):len(contents)]
            
            ## Create a shortest-path distance matrix between taxi locations and origins
            dist_matrix = np.zeros(shape=(a_num_taxis, a_num_ods))
            row_names = [] # taxi locations
            col_names = [] # origin nodes
            for r in range(a_num_taxis):
                a_taxi_loc = int(taxi_locs[r])
                row_names.append(a_taxi_loc)
                an_origin = od_pairs[r].split(', ')[0]
                
                ## Extract the assigned taxi-origin pair
                assigned_taxi = assignment[r].split(', ')[0]
                assigned_taxi = int(assigned_taxi)
                assigned_taxis.append(assigned_taxi)
                
                assigned_origin = assignment[r].split(', ')[1]
                assigned_origin = int(assigned_origin)
                assigned_origins.append(assigned_origin)
                
                ## Extract the destination node
                destination = od_pairs[r].split(', ')[1]
                destination = int(destination)
                destinations.append(destination)
                
                an_origin = int(an_origin)
                col_names.append(an_origin)
                 
                ## Find the index of the node label
                taxi_loc_idx = travel_time_graph.vs.select(label = a_taxi_loc)['index']
                taxi_loc_idx = int(taxi_loc_idx[0])
                 
#                 for c in range(a_num_ods):
#                     an_origin = od_pairs[c].split(',')[0]
#                     an_origin = int(an_origin)
#                      
#                     ## Find the index of the node label
#                     origin_idx = travel_time_graph.vs.select(label = an_origin)['index']
#                     origin_idx = int(origin_idx[0])
#                     path = travel_time_graph.get_shortest_paths(v=taxi_loc_idx, to=origin_idx, weights='weight', mode=OUT, output='epath')
#                     shortest_path = path[0]
#                      
#                     ## Traverse the path and sum the total travel time
#                     total_travel_time = 0
#                     for edge_idx in shortest_path:
#                         travel_time = travel_time_graph.es['weight'][edge_idx]
#                         total_travel_time = total_travel_time + travel_time
#                     dist_matrix[r, c] = total_travel_time
            
            g.close() 
            ## Save the distance matrix
#             dist_matrix_df = pd.DataFrame(dist_matrix, index=row_names)
#             ## Set the column names
#             dist_matrix_df.columns = col_names
#             output_filename = '../../data/test/sin/dist_mat_' + str(a_num_ods) + '_' + str(a_num_taxis) + '.csv'
#             dist_matrix_df.to_csv(output_filename)
#             print('Written to file ' + output_filename)
            
            ## Do shortest-path routing from assigned taxi to origin, and then to destination
            out_filename = '../../data/training/sin/path_' + str(a_num_ods) + '_' + str(a_num_taxis) + '.csv'
            with open(out_filename, 'wb') as csvfile:
                out_writer = csv.writer(csvfile, delimiter=',')
                for i in range(a_num_taxis):
                    taxi_loc = assigned_taxis[i]
                    origin = assigned_origins[i]
                    destination = destinations[i]
                    
                    ## Find the indices of the node labels
                    taxi_loc_idx = travel_time_graph.vs.select(label=taxi_loc)['index']
                    taxi_loc_idx = int(taxi_loc_idx[0])
                    origin_idx = travel_time_graph.vs.select(label=origin)['index']
                    origin_idx = int(origin_idx[0])
                    dest_idx = travel_time_graph.vs.select(label=destination)['index']
                    dest_idx = int(dest_idx[0])
                    
                    ## Get shortest paths
                    assign_path = travel_time_graph.get_shortest_paths(v=taxi_loc_idx, to=origin_idx, weights='weight', mode=OUT, output='epath')
                    assign_path = assign_path[0]
                    write_path(out_writer, travel_time_graph, assign_path, is_od_path=False)
                    
                    od_path = travel_time_graph.get_shortest_paths(v=origin_idx, to=dest_idx, weights='weight', mode=OUT, output='epath')
                    od_path = od_path[0]
                    write_path(out_writer, travel_time_graph, od_path, is_od_path=True)
            
            print('Written to file: ' + out_filename)
    f.close()
    