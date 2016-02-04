# Adjacency Matrices
These instructions are for the programming project of [IS421: Enterprise Analytics for Decision Support](http://sisapps.smu.edu.sg/CDDR/Courses.aspx?P=104&C=737), Spring semester, 2016.

This folder contains the adjacency matrices for the **Singapore road network**. Specifically, the following two CSV files are contained in the ZIP file:
- **seg_len_matrix.csv** -- adjacent nodes (i.e., edges) are represented by the non-zero segment lengths (in meters)
- **max_speed_matrix.csv** -- adjacent nodes are represented by the non-zero max speed values (i.e., speed limit in km/h)

Both matrices are sparse and of dimension 9,948 x 9,948 each. The first matrix represents the node adjacencies via the segment lengths, while the second one via the speed limit on each road segment (i.e., edge). Therefore, a zero entry means that the respective row and column nodes are *not* adjacent. In addition, both matrices are symmetrical and have zero diagonals.

Each CSV file is a square matrix. Headers of each CSV file represent the indices (names) of the nodes in the graph. Thus, the row names of each matrix are identical to its column names (headers). If it often necessary to ignore the headers (the first line of each CSV file) when constructing the graph or performing computations on it, except, of course, for naming the nodes.
