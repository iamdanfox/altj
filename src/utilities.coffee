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
distbetween = (p1,p2) -> edgelen [p1,p2]

eq = ([a1,a2],[b1,b2]) -> a1 is b1 and a2 is b2

# returns true if the last argument, testp, falls inside the triangle <p1,p2,p3>
intriangle = (p1,p2,p3,testp) ->
  leftmost = Math.min p1[0],p2[0],p3[0]
  rightmost = Math.max p1[0],p2[0],p3[0]
  lower = Math.min p1[1],p2[1],p3[1]
  upper = Math.max p1[1],p2[1],p3[1]
  # if testpoint in triangle p1,p2,c return false
  return leftmost<=testp[0]<=rightmost and lower<=testp[1]<=upper

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


shortcut = (graph) ->
  # console.log 'shortcut'
  if graph.edges.length < 5 then return false

  # select two random points (with one inbetween) to shortcut
  # i = Math.floor(Math.random()*(graph.exteriors.length - 2))
  # [p1,p2,p3] = graph.exteriors[i..i+2]

  bestshortcut = Infinity
  # evaluate each possible shortcut, choose shortest
  for i in [0...graph.exteriors.length]
    t1 = graph.exteriors[i]
    t2 = graph.exteriors[(i+1) % graph.exteriors.length]
    t3 = graph.exteriors[(i+2) % graph.exteriors.length]
    d = distbetween(t1,t3)
    # check new edge doesn't overlap with anything
    nointersections = () ->
      for [a,b] in graph.edges
        if intersects(a,b,t1,t3) then return false
      return true
    if d < bestshortcut and not graph.hasEdge([t1,t3]) and nointersections()
      bestshortcut = d
      [p1,p2,p3] = [t1,t2,t3] # hoists vars for later

  # do the shortcut!
  if bestshortcut < Infinity
    graph.shortcut(p1,p2,p3)
    console.log 'shortcut success!'
    return true
  else
    console.log 'convex'
    return false

augment = (graph, dist) ->
  # sample two new lengths
  l1 = dist.sample()
  l2 = dist.sample()

  # randomly select two exterior points to augment
  i = Math.floor(Math.random()*(graph.exteriors.length - 1))
  p1 = graph.exteriors[i]
  p2 = graph.exteriors[i+1]

  safeToAdd = (testpoint) ->
    # check point isn't already in graph
    for p in graph.points
      if distbetween(p, testpoint) < 20
        return false

    # check new point doesn't form a 4-sided shape
    for c in graph.adjacentpoints(p1) when (c in graph.adjacentpoints(p2))
      if intriangle(p1,p2,c,testpoint) then return false # is testpoint inside a triangle
      if intriangle(p1,p2,testpoint,c) then return false # is any other point inside the new triangle

    # check both new edges don't overlap with anything
    for [a,b] in graph.edges
      if intersects(a,b,testpoint,p1) then return false
      if intersects(a,b,testpoint,p2) then return false

    return true

  nps = newpoints(p1,p2,l1,l2) # can return an empty list if impossible
  if nps.length > 0
    [n1, n2] = nps

    if safeToAdd(n2)
      graph.extend(p1,p2,n2)
      console.log 'augmented'
    else if safeToAdd(n1)
      graph.extend(p1,p2,n1)
      console.log 'augmented'
    else
      augment(graph, dist)
  else
    augment(graph, dist)
