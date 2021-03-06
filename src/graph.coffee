class Graph
  points        : []
  exteriors: [] # invariant: adjacent points have an edge between them
  edges         : [] # only stores one direction, but edges are bi-directional

  intialise3points: (p1,p2,p3) ->
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
    a = Math.min(i,j)
    b = Math.max(i,j)

    if a+1 is b # need to insert a new point into the middle of exteriors
      @exteriors = @exteriors[0..a].concat [newpoint], @exteriors[b..]
    else # simply append one (exteriors list wraps round!)
      @exteriors.unshift newpoint

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

  hasEdge: ([p1,p2]) ->
    for [u,v] in @edges
      if eq(u,p1) and eq(v,p2) then return true
      if eq(u,p2) and eq(v,p1) then return true
    return false

  adjacentpoints: (p) ->
    @edges.filter(([u,v]) -> u is p or v is p).
      map(([u,v]) -> if u is p then v else u)

  clone: () ->
    g = new Graph()
    g.points = @points
    g.exteriors = @exteriors
    g.edges = @edges
    return g
