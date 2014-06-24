###

1. Get seed triangle from user
2. Find a MLE distribution on edge lengths.
3. Choose two length by sampling from distribution
4. From exterior points of graph: Randomly choose a pair of adjacent points.
5. Compute extra point
6. Add new point to data structure (Don't add if edges cross existing ones)

Repeat



# Data structures

set of points :: (x,y) coordinates
set of edges [point,point]
list of exterior points [point,point,point ... point]

###



# returns true if the line between the first two points intersects the
# one between the second two points
intersects = ([a,b],[c,d],[p,q],[r,s]) ->
  # two intersecting vector lines. solve as a matrix problem.
  det = (c-a)*(s-q) - (r-p)*(d-b)
  if det is 0
    return false # matrix isn't invertible => colinear
  else
    lambda = ((s-q)*(r-a) + (p-r)*(s-b)) / det
    gamma = ((b-d)*(r-a) + (c-a)*(s-b)) / det
    return 0<lambda<1 and 0<gamma<1

# length of an edge
edgelen = ([[x1,y1],[x2,y2]]) -> Math.sqrt((x2-x1)**2 + (y2-y1)**2)

# finds new points such that p3 is len1 from p1 and len2 from p2
# returns two possibilities
newpoints = (p1,p2,l1,l2) ->
  [r,s] = p1
  [p,q] = p2

  # perform translation to move p1 to origin, simplifies calcs
  w = p-r
  z = q-s
  w2z2 = w**2 + z**2
  lambda = w2z2 + l1**2 - l2**2

  # fails when two points are exactly horizontal or vertical
  discx = w**2*lambda**2 - 4*w2z2*(0.25*lambda**2 - z**2*l1**2)
  discy = z**2*lambda**2 - 4*w2z2*(0.25*lambda**2 - w**2*l1**2)

  if discx < 0 or discy < 0
    return []
  # discriminant = 0 is allowed if both points are vertical or horizontal
  else
    x1 = (w*lambda + Math.sqrt(discx)) / (2*w2z2) #quadratic formula
    x2 = (w*lambda - Math.sqrt(discx)) / (2*w2z2)

    y1 = (z*lambda + Math.sqrt(discy)) / (2*w2z2)
    y2 = (z*lambda - Math.sqrt(discy)) / (2*w2z2)

    if Math.round(l1) isnt Math.round(edgelen([p1,[x1+r,y1+s]]))
      return [[x1+r,y2+s], [x2+r,y1+s]]  # translate away from origin
    else
      return [[x1+r,y1+s], [x2+r,y2+s]]  # translate away from origin


class NormalDistribution
  # mean     :
  # variance :
  # stdev    :

  # construct a normal distribution given three weights as representative sample
  # uses Central Limit Theorem
  constructor: (len1, len2, len3) -> # TODO rewrite to take list
    # If X1,...,Xn is a sample from a distribution with mean, m, and variance,
    # v2, then for large n, the sample mean has approximately a normal
    # distribution with mean m and variance v2/n.
    @mean = (len1+len2+len3) / 3
    @variance = ((len1-@mean)**2 + (len2-@mean)**2 + (len3-@mean)**2) / 9
    @stdev = Math.sqrt(@variance)


  sample: () ->
    # Math.random has mean 0.5 and variance 1/12.
    x = (Math.random() - 0.5)*2*Math.sqrt(3)
    # we need a variable x that has mean 0 and variance 1.
    return @stdev*x + @mean



class Graph
  points        : []
  exteriors: [] # invariant: adjacent points have an edge between them
  edges         : [] # only stores one direction, but edges are bi-directional

  constructor: (p1,p2,p3) ->
    @points = [p1,p2,p3]
    @exteriors = [p1,p2,p3]
    @edges = [[p1,p2], [p2,p3], [p3,p1]]

  # returns null
  extend: (origp1,origp2,newpoint) ->
    unless origp1 in @points and origp2 in @points
      console.error "extendGraph must extend an existing point"

    @points.push(newpoint)
    @edges.push([origp1, newpoint])
    @edges.push([newpoint, origp2])

    # update exterior points
    i = @exteriors.indexOf(origp1)
    j = @exteriors.indexOf(origp2)
    console.error "exterior invariant broken" unless i-j is 1 or j-i is 1
    a = Math.min(i,j)
    b = Math.max(i,j)

    @exteriors = @exteriors[0..a].concat [newpoint], @exteriors[b..]

    return

  # list of all points in graph
  getPoints: () -> @points

  # list of points that are on the exterior of the graph
  # getExteriors: () -> @exteriors

  # e.g. e1= [[0,0],[1,1]] e2=[[3,4],[4,5]]  returns: [e1,e2]
  getEdges: () -> @edges




# initial triangle:
graph = new Graph([110,110],[150,110],[130,190])

dist = new NormalDistribution(edgelen(graph.edges[0]),
                              edgelen(graph.edges[1]),
                              edgelen(graph.edges[2]))


paper = new Raphael(document.getElementsByTagName('div')[0], 600, 400);

window.onload = () -> drawgraph()

drawgraph = () ->
  paper.clear()

  for [[x1,y1],[x2,y2]] in graph.getEdges()
    # console.log "M #{x1} #{y1} l #{x2-x1} #{y2-y1}"
    paper.path("M #{x1} #{y1} l #{x2-x1} #{y2-y1}")

  for [x,y] in graph.exteriors
    circle = paper.circle(x, y, 4);
    circle.attr({fill: "#f00", 'stroke-width':0});

  #line1 = paper.path("M 20 10 l 100 200")
  #line1.attr({stroke: '#ddd', 'stroke-width': 5});

grow = () ->
  # sample two new lengths
  l1 = dist.sample()
  l2 = dist.sample()

  # randomly select two exterior points to augment
  i = Math.floor(Math.random()*(graph.exteriors.length - 1))
  p1 = graph.exteriors[i]
  p2 = graph.exteriors[i+1]

  nps = newpoints(p1,p2,l1,l2) # can return an empty list if impossible
  if nps.length > 0
    [n1, n2] = nps

    safeToAdd = (testpoint) ->
      # return false if isNaN(testpoint[0]) or isNaN(testpoint[1]) #NaN checks
      for [a,b] in graph.edges
        # check both new edges don't overlap with anything
        if intersects(a,b,testpoint,p1) then return false
        if intersects(a,b,testpoint,p2) then return false
      return true

    if safeToAdd(n2)
      graph.extend(p1,p2,n2)
      drawgraph()
    else if safeToAdd(n1)
      graph.extend(p1,p2,n1)
      drawgraph()
  else
    console.log 'impossible'
