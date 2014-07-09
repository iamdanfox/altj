
{h1,div,button,input,label,svg,path} = React.DOM # destructuring assignment

App = React.createClass({
  getInitialState: () ->
    randX = () -> document.body.clientWidth/2 + Math.random()*100 - 50
    randY = () -> document.body.clientHeight/3 + Math.random()*100 - 50

    g = new Graph()
    g.intialise3points([randX(),randY()], [randX(),randY()], [randX(),randY()])

    return {
      graph: g
      normalDist: NormalDistribution.make(edgelen(g.edges[0]),
                                         edgelen(g.edges[1]),
                                         edgelen(g.edges[2]))
      triModalDist: TriModal.make(edgelen(g.edges[0]),
                                 edgelen(g.edges[1]),
                                 edgelen(g.edges[2]))
      augmentProportion: 0.8
      distribution: 'NORMAL'
    }

  setSpiky: () -> @setState(augmentProportion: 0.8)

  setRound: () -> @setState(augmentProportion: 0.6)

  grow: () ->
    # console.log 'grow()'
    dist = if @state.distribution is 'NORMAL' then @state.normalDist else @state.triModalDist

    if Math.random() > @state.augmentProportion # good values: 0.8 or 0.7
      success = shortcut(@state.graph)
      if not success
        augment(@state.graph, dist)
    else
      augment(@state.graph, dist)

    # hacky way of notifying react
    @setState(graph:@state.graph)
    return

  grow20: () ->
    # console.log 'grow20()'
    target = @state.graph.points.length + 20
    cont = () =>
      if @state.graph.points.length < target
        @grow()
        setTimeout cont, 5
    cont() # TODO store isGrowing in props

    # hacky way of notifying react
    @setState(graph:@state.graph)
    return

  restart: () ->
    {graph,normalDist,triModalDist}= @getInitialState()
    @setState(graph:graph,normalDist:normalDist,triModalDist:triModalDist)

  setNormal: () -> @setState(distribution: 'NORMAL')

  setTriModal: () ->  @setState(distribution: 'TRI_MODAL')

  render: () ->
    (div {}, [
      SVGComp( graph: @state.graph ),
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
      }),
      HistogramComp( graph: @state.graph, width:500, height: 200 )
    ])
})



SVGComp = React.createClass({
  render: () ->
    paths = for [[x1,y1],[x2,y2]] in @props.graph.getEdges()
      (path {stroke:'black', fill:'none', d:"M #{x1} #{y1} l #{x2-x1} #{y2-y1}"})
    return (svg {height:'100%', width:'100%'}, paths )
});



HistogramComp = React.createClass({
  paper2: null

  componentDidMount: () ->
    @paper2 = new Raphael(@refs.histogram.getDOMNode(),
      @props.width,
      @props.height)
    @drawBars()

  drawBars: () ->
    bucketsize = 5
    histogram = {}
    for edge in @props.graph.edges
      l = Math.floor(edgelen edge)
      b = l - (l % bucketsize)
      histogram[b] = if histogram[b]?  then histogram[b] + 1 else histogram[b] = 1

    # perform scaling
    maxY = 0
    for x, y of histogram
      maxY = Math.max maxY, y

    yScale = 3
    while maxY*yScale > @props.height
      yScale = yScale / 2

    for x, y of histogram
      h = y*yScale # bar height
      @paper2.rect(x*2.2,@props.height-h,bucketsize*2,h).attr('fill':'#555', stroke:'none')

  componentWillUnMount: () -> @paper2.remove()

  render: () ->
    if @isMounted()
      @paper2.clear()
      @drawBars() # TODO only render diff
    (div {id:'dist-graph', title:'Histogram of line lengths', ref:'histogram'})
})



SidebarComp = React.createClass({
  render: () ->
    return (div {className:'sidebar'}, [
      TitleComp(),
      GrowComp(@props),
      SpikynessComp(@props), # TODO: limit what goes down?
      DistributionComp(@props)
    ])
})



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
