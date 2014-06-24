###

1. Get seed triangle from user
2. Find a MLE distribution on edge lengths.
3. Choose two length by sampling from distribution
4. From exterior points of graph: Randomly choose a pair of adjacent points.
5. Compute extra point
6. Add new point to data structure

Repeat



# Data structures

set of points :: (x,y) coordinates
set of edges [point,point]
list of exterior points [point,point,point ... point]

###


# finds new points p3 such that p3 is len1 from p1 and len2 from p2
# returns two possibilities
trilaterate = (p1,p2,len1,len2) ->



class NormalDistribution
  # mean     : 
  # variance :
  # stdev    :

  # construct a normal distribution given three weights as representative sample
  # uses Central Limit Theorem
  constructor: (len1, len2, len3) ->
    # If X1,...,Xn is a sample from a distribution with mean, m, and variance,
    # v2, then for large n, the sample mean has approximately a normal
    # distribution with mean m and variance v2/n.
    @mean = (len1+len2+len3) / 3
    @variance = ((len1-mean)**2 + (len2-mean)**2 + (len3-mean)**2) / 9
    @stdev = Math.sqrt(@variance)

  sample: () ->
    # Math.random has mean 0.5 and variance 1/12.
    x = (Math.random() - 0.5)*Math.sqrt(3)
    # we need a variable x that has mean 0 and variance 1.
    return @stdev*x + @mean



class Graph

  # returns null
  extendGraph: (origp1,origp2,newpoint) -> #can compute new edges
    return

  # list of all points in graph
  getPoints: () -> []

  # list of points that are on the exterior of the graph (ie not all angles covered)
  getExteriors: () -> []

  # e.g. e1= [[0,0],[1,1] e2=[[3,4],[4,5]]  returns: [e1,e2]
  getEdges: () -> []
