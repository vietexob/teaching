# Road network data
This folder contains the road network data of three (3) global cities:
- **pgh_road_network** -- Pittsburgh, PA
- **was_road_network** -- Washington, DC
- **sin_road_network** -- Singapore

All road networks are described in an XML-based format specifically suited for graph data called [GraphML](http://graphml.graphdrawing.org/). GraphML file can be easily read and parsed as a standard XML. Depending on which dataset, the edge (road segment) attributes may vary.

Here are the edge attributes of each dataset. Attributes not mentioned in here should be ignored in your solutions.

## Singapore:
- **from.x**, **from.y** -- the longitude and latitude coordinates of one end of the segment
- **to.x**, **to.y** -- the longitude and latitude of the other end of the segment
- **RD_CD** -- the edge id
- **SHAPE_LEN** -- the segment length (in meters)
- **RD_CD_DESC** -- the street name of the segment
- **max_speed** -- the speed limit (in km/h) over the segment

For US cities, we assume the stochastic speed over a segment follows a Gaussian distribution.

## Pittsburgh, PA and Washington, DC:
- **from.x**, **from.y**, **to.x**, **to.y** -- as before
- **unique.Id** -- the segment id
- **length** -- the segment length (in miles)
- **street.name** -- the street name of the segment
- **avg_speed** and **var_speed** -- the mean and variance (in miles per hour) of the speed random variable.
