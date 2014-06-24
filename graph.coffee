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

  shortcut:(p1,p2,p3) ->
    # update exterior points
    j = @exteriors.indexOf(p2) #p2 to be removed
    @exteriors = @exteriors[0..j-1].concat @exteriors[j+1..]

    # add edge
    @edges.push([p1,p3])

  # list of all points in graph
  getPoints: () -> @points

  # list of points that are on the exterior of the graph
  # getExteriors: () -> @exteriors

  # e.g. e1= [[0,0],[1,1]] e2=[[3,4],[4,5]]  returns: [e1,e2]
  getEdges: () -> @edges

  adjacentpoints: (p) ->
    @edges.filter(([u,v]) -> u is p or v is p).
      map(([u,v]) -> if u is p then v else u)
