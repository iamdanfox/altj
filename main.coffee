
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
paper = null
# paper2 = new Raphael(document.getElementById('dist-graph'),500,200)

{h1,a,div,button,input,label} = React.DOM # destructuring assignment

RaphaelComp = React.createClass({
  paper: null

  componentDidMount: () ->
    # initialise raphael
    elem = @refs.raphael.getDOMNode()
    w = document.body.clientWidth
    h = document.body.clientHeight
    @paper = new Raphael(elem,w,h);
    paper = @paper               # TODO delete
    # make ZPD
    @paper.ZPD({ zoom: true, pan: true, drag: false });

  componentWillUnMount: () ->
    @paper.remove()

  render: () ->
    # TODO: draw all the little triangles
    # for [[x1,y1],[x2,y2]] in graph.getEdges()
    #   # console.log "M #{x1} #{y1} l #{x2-x1} #{y2-y1}"
    #   paper.path("M #{x1} #{y1} l #{x2-x1} #{y2-y1}").attr('stroke','black')
    (div {id:'raphael', ref:'raphael'})
});

TitleComp = React.createClass({
  render: () ->
    (div {className:'section',id:'top'},
      (h1 {}, [
        (React.DOM.a {href:"http://github.com/iamdanfox/altj"}, "Alt-J"),
        " by ",
        (React.DOM.a {href:"http://twitter.com/iamdanfox"}, "iamdanfox")
      ])
    )
})

GrowComp = React.createClass({
  render: () ->
    (div {className:'section'}, [
      (button {title:'or Press Enter',onClick:@props.grow}, "Grow"),
      (button {onClick:@props.grow20}, "Grow 20"),
      (button {onClick:@props.restart}, "Restart")
    ])
})

# SPIKY: 0.8
# ROUND: 0.6

SpikynessComp = React.createClass({
  # props are immutable
  render: () ->
    (div {className:'section'}, [
      (input {onClick:@props.onSetSpiky, name:'spikyness', type:'radio', checked:@props.augmentProportion is 0.8}),
      (label {onClick:@props.onSetSpiky}, "Spiky"),
      (input {onClick:@props.onSetRound, name:'spikyness', type:'radio', checked:@props.augmentProportion is 0.6}),
      (label {onClick:@props.onSetRound}, "Round"),
    ])
})

DistributionComp = React.createClass({
  render: () ->
    (div {className:'section'}, [
      (input {onClick:@props.setNormal, name:'distribution', type:'radio', checked:@props.distribution is 'NORMAL'}),
      (label {onClick:@props.setNormal, title:'Use a plain normal distribution based on the 3 initial sides'}, "Random"),
      (input {onClick:@props.setTriModal, name:'distribution', type:'radio', checked:@props.distribution is 'TRI_MODAL'}),
      (label {onClick:@props.setTriModal, title:'Use a trimodal mixture of normal distributions based on the 3 initial sides'}, "Regular"),
    ])
})

SidebarComp = React.createClass({
  render: () ->
    return (div {className:'sidebar'}, [
      TitleComp(),
      GrowComp(@props),
      SpikynessComp(@props), # TODO: limit what goes down?
      DistributionComp(@props),
      # HistogramComp()
    ])
})

App = React.createClass({
  getInitialState: () -> # state is mutable up here
    augmentProportion: 0.8
    distribution: 'NORMAL'

  setSpiky: () ->
    @setState(augmentProportion: 0.8)

  setRound: () ->
    @setState(augmentProportion: 0.6)

  grow: () ->
    console.log 'grow()'
    if Math.random() > @state.augmentProportion # good values: 0.8 or 0.7
      success = shortcut()
      if not success
        augment()
    else
      augment()

  grow20: () ->
    console.log 'grow20()'
    singleGrow = @grow
    growN = (n) ->
      target = graph.points.length + n
      cont = () ->
        if graph.points.length < target then singleGrow()
        setTimeout cont, 5
      cont()

    growN(20)

  restart: () ->
    alert('unimplemented')

  setNormal: () ->
    console.log 'setNormal()'
    @setState(distribution: 'NORMAL')

  setTriModal: () ->
    console.log 'setTriModal()'
    @setState(distribution: 'TRI_MODAL')

  render: () ->
    return (div {}, [
      RaphaelComp(  ), # TODO pass in graph
      SidebarComp({
        onSetSpiky:@setSpiky,
        onSetRound:@setRound,
        grow: @grow,
        grow20: @grow20,
        restart: @restart,
        augmentProportion:@state.augmentProportion
        distribution:     @state.distribution
        setNormal: @setNormal
        setTriModal: @setTriModal
      })
    ])
})

window.onload = () ->

  React.renderComponent( App(), document.getElementsByTagName('body')[0])


  # drawgraph()
  # document.getElementsByTagName('body')[0].onkeypress=keypress
  return


drawgraph = () ->
  paper.clear()

  for [[x1,y1],[x2,y2]] in graph.getEdges()
    # console.log "M #{x1} #{y1} l #{x2-x1} #{y2-y1}"
    paper.path("M #{x1} #{y1} l #{x2-x1} #{y2-y1}").attr('stroke','black')

  # do histogram thing
  # bucketsize = 5
  # offset = -3*bucketsize
  # histogram = {}
  # for edge in graph.edges
  #   l = Math.floor(edgelen edge)
  #   b = l - (l % bucketsize)
  #   histogram[b] = if histogram[b]?  then histogram[b] + 1 else histogram[b] = 1
  #
  # for key, val of histogram
  #   h = val*3
  #   paper2.rect(offset+key*2.2,190-h,bucketsize*2,h).attr('fill':'#555', stroke:'none')

# keypress = (e) ->
#   if e.charCode is 13 #ie Enter
#     grow()

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
