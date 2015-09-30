# Road network data
This folder contains the road network data of three (3) global cities:
- **pgh_road_network** -- Pittsburgh, PA
- **was_road_network** -- Washington, DC
- **sin_road_network** -- Singapore

All road networks are described in an XML-based format specifically suited for graph data called [GraphML](http://graphml.graphdrawing.org/). GraphML data can be easily read and parsed as a standard XML.

Depending on which dataset, the edge (road segment) attributes may vary. Here are the attributes of each dataset. Attributes not mentioned in here should be ignored in your solutions.

## Singapore:
- **from.x**, **from.y** -- the longitude and latitude coordinates of one end of the segment
- **to.x**, **to.y** -- the longitude and latitude of the other end of the segment
- **RD_CD** -- the edge id
- **SHAPE_LEN** -- the segment length (in meters)
- **max_speed** -- the speed limit over the segment

## Pittsburgh, PA:

