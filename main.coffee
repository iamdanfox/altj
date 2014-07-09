
# initial triangle:
w = document.body.clientWidth
h = document.body.clientHeight

randX = () -> w/2 + Math.random()*100 - 50
randY = () -> h/3 + Math.random()*100 - 50

graph = new Graph([randX(),randY()],
                  [randX(),randY()],
                  [randX(),randY()])

# returns a NormalDistribution
normalDist = NormalDistribution.make(edgelen(graph.edges[0]),
                               edgelen(graph.edges[1]),
                               edgelen(graph.edges[2]))

triModalDist = TriModal.make(edgelen(graph.edges[0]),
                               edgelen(graph.edges[1]),
                               edgelen(graph.edges[2]))

dist = normalDist

# paper2 = new Raphael(document.getElementById('dist-graph'),500,200)

{h1,a,div} = React.DOM # destructuring assignment

RaphaelComponent = React.createClass({
  render: () ->
    d = (div {id:'raphael'})
    # TODO initialise as Raphael
    # paper = new Raphael(document.getElementById('raphael'),w,h);
    # TODO: make ZPD
    # paper.ZPD({ zoom: true, pan: true, drag: false });
    return d
});

TitleComp = React.createClass({
  render: () ->
    (div {className:'section',id:'top'},
      (h1 {}, [
        (a {href:"http://github.com/iamdanfox/altj"}, "Alt-J"), " by ", (a {href:"http://twitter.com/iamdanfox"}, "iamdanfox")
      ])
    )
})


SidebarComp = React.createClass({
  render: () ->
    return (div {className:'sidebar'}, [
      TitleComp(),
      # GrowComp(),
      # SpikynessComp(),
      # DistributionComp()
    ])
})


window.onload = () ->

  console.debug RaphaelComponent
  React.renderComponent( SidebarComp(), document.getElementsByTagName('body')[0])

  # only insert buttons when everything else has already been set up
  # document.getElementsByClassName('sidebar')[0].innerHTML += """
  # <div class="section">
  #   <button title="or press Enter" onclick="grow()">Grow</button>
  #   <button onclick="growN(20)">Grow 20</button>
  #   <button onclick="window.location=window.location">Restart</button>
  # </div>
  #
  # <div class="section">
  #   <input type="radio" name="spikyness" id="spiky" checked onclick="setSpiky()" />
  #     <label for="spiky">Spiky</label>
  #   <input type="radio" name="spikyness" id="round" onclick="setRound()" />
  #     <label for="round">Round</label>
  # </div>
  #
  # <div class="section">
  #   <input type="radio" name="distribution" id="moreRandom" checked onclick="setMoreRandom()" />
  #     <label for="moreRandom" title="Use a plain normal distribution based on the 3 initial sides">Random</label>
  #   <input type="radio" name="distribution" id="moreRegular" onclick="setMoreRegular()" />
  #     <label for="moreRegular" title="Use a trimodal mixture of normal distributions based on the 3 initial sides">Regular</label>
  # </div>
  # """
  #
  # paper.ZPD({ zoom: true, pan: true, drag: false });
  # drawgraph()
  # document.getElementsByTagName('body')[0].onkeypress=keypress
  return


drawgraph = () ->
  paper.clear()

  for [[x1,y1],[x2,y2]] in graph.getEdges()
    # console.log "M #{x1} #{y1} l #{x2-x1} #{y2-y1}"
    paper.path("M #{x1} #{y1} l #{x2-x1} #{y2-y1}").attr('stroke','black')

  # do histogram thing
  bucketsize = 5
  offset = -3*bucketsize
  histogram = {}
  for edge in graph.edges
    l = Math.floor(edgelen edge)
    b = l - (l % bucketsize)
    histogram[b] = if histogram[b]?  then histogram[b] + 1 else histogram[b] = 1

  for key, val of histogram
    h = val*3
    paper2.rect(offset+key*2.2,190-h,bucketsize*2,h).attr('fill':'#555', stroke:'none')


AUGMENT_PROPORTION = 0.8

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

setSpiky = () ->
  console.log 'setSpiky'
  AUGMENT_PROPORTION = 0.8

setRound = () ->
  console.log 'setRound'
  AUGMENT_PROPORTION = 0.6

setMoreRandom = () ->
  dist = normalDist

setMoreRegular = () ->
  dist = triModalDist

keypress = (e) ->
  if e.charCode is 13 #ie Enter
    grow()

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
