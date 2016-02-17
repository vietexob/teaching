# Adjacency Matrices
These instructions pertinent to the programming project of [IS421: Enterprise Analytics for Decision Support](http://sisapps.smu.edu.sg/CDDR/Courses.aspx?P=104&C=737), Semester 2, 2016.

This folder contains the adjacency matrices for the **Singapore road network**. Specifically, the following **three** CSV files are contained in the ZIP file:
- **seg_len_matrix.csv** -- adjacent nodes (i.e., edges) are represented by the non-zero segment lengths (in meters)
- **max_speed_matrix.csv** -- adjacent nodes are represented by the non-zero max speed values (i.e., speed limit in km/h)
- **edge_idx_matrix** -- adjacency of the nodes are represented by the non-zero edge indices (i.e., positive integers) between all pairs of adjacent nodes.

All the matrices are sparse and of dimension 9,948 x 9,948 each. The first matrix represents the node adjacencies via the segment lengths, the second one via the speed limit on each road segment (i.e., edge), and the third one via the edges. Therefore, a zero entry in each matrix means that the respective row and column nodes are *not* adjacent. In addition, all the matrices are symmetrical and have zero diagonals. All three matrices should be employed to solve the problems in the programming project.

Each CSV file is a square matrix **with headers**. The rows and columns are exactly identical. The headers name the columns from 0 to the number of columns (rows) - 1. This can  be conveniently used to name the nodes. Otherwise, for most practical purposes, each header line (i.e., the first line of each CSV file) can be ignored when reading the file. Note that each of these CSV file, once expanded, can be quite large. It is essential that you write a program to read these files and construct an *undirected* graph out of them to represent the road network.
