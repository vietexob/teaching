'''
Created on Sep 22, 2015

@author: trucvietle
'''

from pygraphml import Graph
from pygraphml import GraphMLParser

g = Graph()

n1 = g.add_node('A')
n2 = g.add_node('B')
n3 = g.add_node('C')
n4 = g.add_node('D')
n5 = g.add_node('E')

g.add_edge(n1, n3)
g.add_edge(n2, n3)
g.add_edge(n3, n4)
g.add_edge(n3, n5)

# g.show()
# print(g.nodes()[0])
# nodes = g.BFS(root=g.nodes()[0])
# for node in nodes:
#     print(node)

parser = GraphMLParser()
filename = '../data/networks/sin_road_network.graphml'
g = parser.parse(filename)
print(len(g.nodes()))
# nodes = g.BFS(root=g.nodes()[0])
# for node in nodes:
#     print(node)
