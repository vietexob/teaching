'''
Created on Sep 21, 2015

Try to read graphml road network input file and perform basic analysis using igraph.

@author: trucvietle
'''

from igraph import *

filename = '../data/networks/sin_road_network.graphml'
g = Graph.Read_GraphML(f=filename)
summary(g)
print(g.is_directed())
