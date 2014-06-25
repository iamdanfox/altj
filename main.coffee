
# initial triangle:
graph = new Graph([110,110],[140,110],[130,190])

dist = new NormalDistribution(edgelen(graph.edges[0]),
                              edgelen(graph.edges[1]),
                              edgelen(graph.edges[2]))


paper = new Raphael(document.getElementsByTagName('div')[0], 600, 400);

window.onload = () ->
  paper.ZPD({ zoom: true, pan: true, drag: true });
  drawgraph()

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
  if Math.random() > 0.5
    success = shortcut()
    if not success then augment()
  else
    augment()

growN = (n) ->
  if graph.points.length < n
    grow()
    setTimeout (->growN(n)),20


shortcut = () ->
  console.log 'shortcut'
  # select two points (with one inbetween) to shortcut
  i = Math.floor(Math.random()*(graph.exteriors.length - 2))
  p1 = graph.exteriors[i]
  p2 = graph.exteriors[i+1]
  p3 = graph.exteriors[i+2]

  # don't try to add an existing edge
  for [u,v] in graph.edges
    if eq(u,p1) and eq(v,p3) then return false
    if eq(u,p3) and eq(v,p1) then return false

  # check new edge doesn't overlap with anything
  for [a,b] in graph.edges
    if intersects(a,b,p1,p3) then return false

  # do the shortcut!
  graph.shortcut(p1,p2,p3)
  drawgraph()

  l = paper.path("M #{p1[0]} #{p1[1]} l #{p3[0]-p1[0]} #{p3[1]-p1[1]}")
  l.attr('stoke','red')

  console.log 'shortcut success!'
  return true

augment = () ->
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
      # check point isn't already in graph
      for p in graph.points
        if distbetween(p, testpoint) < 20
          console.log 'too close'
          return false

      # check new point doesn't form 4-sided shape
      for c in graph.adjacentpoints(p1) when (c in graph.adjacentpoints(p2))
        if intriangle(p1,p2,c,testpoint) then return false

      # check both new edges don't overlap with anything
      for [a,b] in graph.edges
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
    console.log 'failed'
    augment()
