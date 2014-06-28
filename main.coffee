
# initial triangle:
w = document.body.clientWidth
h = document.body.clientHeight

graph = new Graph([w/2+0,h/3+0],
                  [w/2+40,h/3+10],
                  [w/2+30,h/3+90])

dist = new NormalDistribution(edgelen(graph.edges[0]),
                              edgelen(graph.edges[1]),
                              edgelen(graph.edges[2]))


paper = new Raphael(document.getElementById('raphael'),w,h);
paper2 = new Raphael(document.getElementById('dist-graph'),500,200)

window.onload = () ->
  paper.ZPD({ zoom: true, pan: true, drag: false });
  drawgraph()

drawgraph = () ->
  paper.clear()

  for [[x1,y1],[x2,y2]] in graph.getEdges()
    # console.log "M #{x1} #{y1} l #{x2-x1} #{y2-y1}"
    paper.path("M #{x1} #{y1} l #{x2-x1} #{y2-y1}").attr('stroke','black')


  # do histogram thing
  paper2.clear()
  # paper2.text(  0,190,Math.round(dist.mean-3*dist.stdev))
  # paper2.text(100,190,Math.round(dist.mean-1*dist.stdev))
  # paper2.text(150,190,Math.round(dist.mean))
  # paper2.path("M 150 0 l 0 200").attr('stroke','white')
  # paper2.text(200,190,Math.round(dist.mean+2*dist.stdev))
  # paper2.text(300,190,Math.round(dist.mean+3*dist.stdev))

  bucketsize = 5
  histogram = {}
  for edge in graph.edges
    l = Math.floor(edgelen edge)
    b = l - (l % bucketsize)
    histogram[b] = if histogram[b]?  then histogram[b] + 1 else histogram[b] = 1

  # for bucket in histogram
  offset = -3*bucketsize
  for key, val of histogram
    h = val*3
    paper2.rect(offset+key*2.2,190-h,bucketsize*2,h).attr('fill':'black', stroke:'none')

  # overlay normal
  # paper2.path("M 150 10 S 180 10 190 100 210 190 300 190").attr('stroke','white')
  # paper2.path("M 150 10 S 120 10 110 100 90 190 0 190").attr('stroke','white')


  #Red dot for each exterior node
  # for [x,y] in graph.exteriors
  #   circle = paper.circle(x, y, 4);
  #   circle.attr({fill: "#f00", 'stroke-width':0});



AUGMENT_PROPORTION = 0.75

grow = () ->
  if Math.random() > AUGMENT_PROPORTION # good values: 0.8 or 0.7
    success = shortcut()
    if not success
      augment()
  else
    augment()

growN = (n) ->
  target = graph.points.length + n

  cont = () ->
    if graph.points.length < target then grow()
    setTimeout cont, 5

  cont()


shortcut = () ->
  # console.log 'shortcut'
  if graph.edges.length < 6 then return false

  # select two random points (with one inbetween) to shortcut
  # i = Math.floor(Math.random()*(graph.exteriors.length - 2))
  # [p1,p2,p3] = graph.exteriors[i..i+2]

  # choose shortest possible shortcut
  bestshortcut = Infinity
  for i in [0...graph.exteriors.length-2]
    [t1,t2,t3] = graph.exteriors[i..i+2]
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
    drawgraph()
    console.log 'shortcut success!'
    return true
  else
    console.log 'convex'
    return false

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
      console.log 'augmented'
      drawgraph()
    else if safeToAdd(n1)
      graph.extend(p1,p2,n1)
      console.log 'augmented'
      drawgraph()
    else
      augment()
  else
    augment()
