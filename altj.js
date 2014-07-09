// Generated by CoffeeScript 1.7.1
var App, DistributionComp, Graph, GrowComp, HistogramComp, NormalDistribution, RaphaelComp, SidebarComp, SpikynessComp, TitleComp, TriModal, augment, button, distbetween, div, edgelen, eq, h1, input, intersects, intriangle, label, newpoints, shortcut, _ref,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

NormalDistribution = (function() {
  NormalDistribution.make = function(len1, len2, len3) {
    var mean, variance;
    mean = (len1 + len2 + len3) / 3;
    variance = (Math.pow(len1 - mean, 2) + Math.pow(len2 - mean, 2) + Math.pow(len3 - mean, 2)) / 9;
    return new NormalDistribution(mean, variance);
  };

  function NormalDistribution(mean, variance) {
    this.mean = mean;
    this.variance = variance;
    this.stdev = Math.sqrt(this.variance);
  }

  NormalDistribution.prototype.sample = function() {
    var x;
    x = (Math.random() - 0.5) * 2 * Math.sqrt(3);
    return this.stdev * x + this.mean;
  };

  return NormalDistribution;

})();

TriModal = (function() {
  TriModal.make = function(len1, len2, len3) {
    var variance;
    variance = 5;
    return new TriModal(len1, variance, len2, variance, len3, variance);
  };

  function TriModal(m1, v1, m2, v2, m3, v3) {
    this.normal1 = new NormalDistribution(m1, v1);
    this.normal2 = new NormalDistribution(m2, v2);
    this.normal3 = new NormalDistribution(m3, v3);
  }

  TriModal.prototype.sample = function() {
    var x;
    x = Math.random();
    switch (false) {
      case !((0 <= x && x < 1 / 3)):
        return this.normal1.sample();
      case !((1 / 3 <= x && x < 2 / 3)):
        return this.normal2.sample();
      case !((2 / 3 <= x && x <= 1)):
        return this.normal3.sample();
    }
  };

  return TriModal;

})();

Graph = (function() {
  function Graph() {}

  Graph.prototype.points = [];

  Graph.prototype.exteriors = [];

  Graph.prototype.edges = [];

  Graph.prototype.intialise3points = function(p1, p2, p3) {
    this.points = [p1, p2, p3];
    this.exteriors = [p1, p2, p3];
    return this.edges = [[p1, p2], [p2, p3], [p3, p1]];
  };

  Graph.prototype.extend = function(origp1, origp2, newpoint) {
    var a, b, i, j;
    if (!(__indexOf.call(this.points, origp1) >= 0 && __indexOf.call(this.points, origp2) >= 0)) {
      console.error("extendGraph must extend an existing point");
    }
    this.points.push(newpoint);
    this.edges.push([origp1, newpoint]);
    this.edges.push([newpoint, origp2]);
    i = this.exteriors.indexOf(origp1);
    j = this.exteriors.indexOf(origp2);
    if (!(i - j === 1 || j - i === 1)) {
      console.error("exterior invariant broken");
    }
    a = Math.min(i, j);
    b = Math.max(i, j);
    this.exteriors = this.exteriors.slice(0, +a + 1 || 9e9).concat([newpoint], this.exteriors.slice(b));
  };

  Graph.prototype.shortcut = function(p1, p2, p3) {
    var j;
    j = this.exteriors.indexOf(p2);
    this.exteriors = this.exteriors.slice(0, +(j - 1) + 1 || 9e9).concat(this.exteriors.slice(j + 1));
    return this.edges.push([p1, p3]);
  };

  Graph.prototype.getPoints = function() {
    return this.points;
  };

  Graph.prototype.getEdges = function() {
    return this.edges;
  };

  Graph.prototype.hasEdge = function(_arg) {
    var p1, p2, u, v, _i, _len, _ref, _ref1;
    p1 = _arg[0], p2 = _arg[1];
    _ref = this.edges;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      _ref1 = _ref[_i], u = _ref1[0], v = _ref1[1];
      if (eq(u, p1) && eq(v, p2)) {
        return true;
      }
      if (eq(u, p2) && eq(v, p1)) {
        return true;
      }
    }
    return false;
  };

  Graph.prototype.adjacentpoints = function(p) {
    return this.edges.filter(function(_arg) {
      var u, v;
      u = _arg[0], v = _arg[1];
      return u === p || v === p;
    }).map(function(_arg) {
      var u, v;
      u = _arg[0], v = _arg[1];
      if (u === p) {
        return v;
      } else {
        return u;
      }
    });
  };

  Graph.prototype.clone = function() {
    var g;
    g = new Graph();
    g.points = this.points;
    g.exteriors = this.exteriors;
    g.edges = this.edges;
    return g;
  };

  return Graph;

})();

_ref = React.DOM, h1 = _ref.h1, div = _ref.div, button = _ref.button, input = _ref.input, label = _ref.label;

App = React.createClass({
  getInitialState: function() {
    var g, randX, randY;
    randX = function() {
      return document.body.clientWidth / 2 + Math.random() * 100 - 50;
    };
    randY = function() {
      return document.body.clientHeight / 3 + Math.random() * 100 - 50;
    };
    g = new Graph();
    g.intialise3points([randX(), randY()], [randX(), randY()], [randX(), randY()]);
    return {
      graph: g,
      normalDist: NormalDistribution.make(edgelen(g.edges[0]), edgelen(g.edges[1]), edgelen(g.edges[2])),
      triModalDist: TriModal.make(edgelen(g.edges[0]), edgelen(g.edges[1]), edgelen(g.edges[2])),
      augmentProportion: 0.8,
      distribution: 'NORMAL'
    };
  },
  setSpiky: function() {
    return this.setState({
      augmentProportion: 0.8
    });
  },
  setRound: function() {
    return this.setState({
      augmentProportion: 0.6
    });
  },
  grow: function() {
    var dist, success;
    dist = this.state.distribution === 'NORMAL' ? this.state.normalDist : this.state.triModalDist;
    if (Math.random() > this.state.augmentProportion) {
      success = shortcut(this.state.graph);
      if (!success) {
        augment(this.state.graph, dist);
      }
    } else {
      augment(this.state.graph, dist);
    }
    this.setState({
      graph: this.state.graph
    });
  },
  grow20: function() {
    var cont, target;
    target = this.state.graph.points.length + 20;
    cont = (function(_this) {
      return function() {
        if (_this.state.graph.points.length < target) {
          _this.grow();
          return setTimeout(cont, 5);
        }
      };
    })(this);
    cont();
    this.setState({
      graph: this.state.graph
    });
  },
  restart: function() {
    var graph, normalDist, triModalDist, _ref1;
    _ref1 = this.getInitialState(), graph = _ref1.graph, normalDist = _ref1.normalDist, triModalDist = _ref1.triModalDist;
    return this.setState({
      graph: graph,
      normalDist: normalDist,
      triModalDist: triModalDist
    });
  },
  setNormal: function() {
    return this.setState({
      distribution: 'NORMAL'
    });
  },
  setTriModal: function() {
    return this.setState({
      distribution: 'TRI_MODAL'
    });
  },
  render: function() {
    return div({}, [
      RaphaelComp({
        graph: this.state.graph
      }), SidebarComp({
        onSetSpiky: this.setSpiky,
        onSetRound: this.setRound,
        grow: this.grow,
        grow20: this.grow20,
        restart: this.restart,
        augmentProportion: this.state.augmentProportion,
        distribution: this.state.distribution,
        setNormal: this.setNormal,
        setTriModal: this.setTriModal
      }), HistogramComp({
        graph: this.state.graph
      })
    ]);
  }
});

RaphaelComp = React.createClass({
  paper: null,
  componentDidMount: function() {
    var elem;
    elem = this.refs.raphael.getDOMNode();
    this.paper = new Raphael(elem, document.body.clientWidth, document.body.clientHeight);
    this.paper.ZPD({
      zoom: true,
      pan: true,
      drag: false
    });
    return this.drawTriangles();
  },
  drawTriangles: function() {
    var x1, x2, y1, y2, _i, _len, _ref1, _ref2, _ref3, _ref4, _results;
    _ref1 = this.props.graph.getEdges();
    _results = [];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      _ref2 = _ref1[_i], (_ref3 = _ref2[0], x1 = _ref3[0], y1 = _ref3[1]), (_ref4 = _ref2[1], x2 = _ref4[0], y2 = _ref4[1]);
      _results.push(this.paper.path("M " + x1 + " " + y1 + " l " + (x2 - x1) + " " + (y2 - y1)).attr('stroke', 'black'));
    }
    return _results;
  },
  componentWillUnMount: function() {
    return this.paper.remove();
  },
  render: function() {
    if (this.isMounted()) {
      this.paper.clear();
      this.drawTriangles();
    }
    return div({
      id: 'raphael',
      ref: 'raphael'
    });
  }
});

HistogramComp = React.createClass({
  paper2: null,
  componentDidMount: function() {
    this.paper2 = new Raphael(this.refs.histogram.getDOMNode(), 500, 200);
    return this.drawBars();
  },
  drawBars: function() {
    var b, bucketsize, edge, h, histogram, key, l, offset, val, _i, _len, _ref1, _results;
    bucketsize = 5;
    offset = -3 * bucketsize;
    histogram = {};
    _ref1 = this.props.graph.edges;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      edge = _ref1[_i];
      l = Math.floor(edgelen(edge));
      b = l - (l % bucketsize);
      histogram[b] = histogram[b] != null ? histogram[b] + 1 : histogram[b] = 1;
    }
    _results = [];
    for (key in histogram) {
      val = histogram[key];
      h = val * 3;
      _results.push(this.paper2.rect(offset + key * 2.2, 190 - h, bucketsize * 2, h).attr({
        'fill': '#555',
        stroke: 'none'
      }));
    }
    return _results;
  },
  componentWillUnMount: function() {
    return this.paper2.remove();
  },
  render: function() {
    if (this.isMounted()) {
      this.paper2.clear();
      this.drawBars();
    }
    return div({
      id: 'dist-graph',
      title: 'Histogram of line lengths',
      ref: 'histogram'
    });
  }
});

SidebarComp = React.createClass({
  render: function() {
    return div({
      className: 'sidebar'
    }, [TitleComp(), GrowComp(this.props), SpikynessComp(this.props), DistributionComp(this.props)]);
  }
});

TitleComp = React.createClass({
  render: function() {
    return div({
      className: 'section',
      id: 'top'
    }, h1({}, [
      React.DOM.a({
        href: "http://github.com/iamdanfox/altj"
      }, "Alt-J"), " by ", React.DOM.a({
        href: "http://twitter.com/iamdanfox"
      }, "iamdanfox")
    ]));
  }
});

GrowComp = React.createClass({
  render: function() {
    return div({
      className: 'section'
    }, [
      button({
        title: 'or Press Enter',
        onClick: this.props.grow
      }, "Grow"), button({
        onClick: this.props.grow20
      }, "Grow 20"), button({
        onClick: this.props.restart
      }, "Restart")
    ]);
  }
});

SpikynessComp = React.createClass({
  render: function() {
    return div({
      className: 'section'
    }, [
      input({
        onClick: this.props.onSetSpiky,
        name: 'spikyness',
        type: 'radio',
        checked: this.props.augmentProportion === 0.8
      }), label({
        onClick: this.props.onSetSpiky
      }, "Spiky"), input({
        onClick: this.props.onSetRound,
        name: 'spikyness',
        type: 'radio',
        checked: this.props.augmentProportion === 0.6
      }), label({
        onClick: this.props.onSetRound
      }, "Round")
    ]);
  }
});

DistributionComp = React.createClass({
  render: function() {
    return div({
      className: 'section'
    }, [
      input({
        onClick: this.props.setNormal,
        name: 'distribution',
        type: 'radio',
        checked: this.props.distribution === 'NORMAL'
      }), label({
        onClick: this.props.setNormal,
        title: 'Use a plain normal distribution based on the 3 initial sides'
      }, "Random"), input({
        onClick: this.props.setTriModal,
        name: 'distribution',
        type: 'radio',
        checked: this.props.distribution === 'TRI_MODAL'
      }), label({
        onClick: this.props.setTriModal,
        title: 'Use a trimodal mixture of normal distributions based on the 3 initial sides'
      }, "Regular")
    ]);
  }
});

intersects = function(_arg, _arg1, _arg2, _arg3) {
  var a, b, c, d, det, gamma, lambda, p, q, r, s;
  a = _arg[0], b = _arg[1];
  c = _arg1[0], d = _arg1[1];
  p = _arg2[0], q = _arg2[1];
  r = _arg3[0], s = _arg3[1];
  det = (c - a) * (s - q) - (r - p) * (d - b);
  if (det === 0) {
    return false;
  } else {
    lambda = ((s - q) * (r - a) + (p - r) * (s - b)) / det;
    gamma = ((b - d) * (r - a) + (c - a) * (s - b)) / det;
    return (0 < lambda && lambda < 1) && (0 < gamma && gamma < 1);
  }
};

edgelen = function(_arg) {
  var x1, x2, y1, y2, _ref1, _ref2;
  (_ref1 = _arg[0], x1 = _ref1[0], y1 = _ref1[1]), (_ref2 = _arg[1], x2 = _ref2[0], y2 = _ref2[1]);
  return Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
};

distbetween = function(p1, p2) {
  return edgelen([p1, p2]);
};

eq = function(_arg, _arg1) {
  var a1, a2, b1, b2;
  a1 = _arg[0], a2 = _arg[1];
  b1 = _arg1[0], b2 = _arg1[1];
  return a1 === b1 && a2 === b2;
};

intriangle = function(p1, p2, p3, testp) {
  var leftmost, lower, rightmost, upper, _ref1, _ref2;
  leftmost = Math.min(p1[0], p2[0], p3[0]);
  rightmost = Math.max(p1[0], p2[0], p3[0]);
  lower = Math.min(p1[1], p2[1], p3[1]);
  upper = Math.max(p1[1], p2[1], p3[1]);
  return (leftmost <= (_ref1 = testp[0]) && _ref1 <= rightmost) && (lower <= (_ref2 = testp[1]) && _ref2 <= upper);
};

newpoints = function(p1, p2, l1, l2) {
  var discx, discy, lambda, p, q, r, s, w, w2z2, x1, x2, y1, y2, z;
  r = p1[0], s = p1[1];
  p = p2[0], q = p2[1];
  w = p - r;
  z = q - s;
  w2z2 = Math.pow(w, 2) + Math.pow(z, 2);
  lambda = w2z2 + Math.pow(l1, 2) - Math.pow(l2, 2);
  discx = Math.pow(w, 2) * Math.pow(lambda, 2) - 4 * w2z2 * (0.25 * Math.pow(lambda, 2) - Math.pow(z, 2) * Math.pow(l1, 2));
  discy = Math.pow(z, 2) * Math.pow(lambda, 2) - 4 * w2z2 * (0.25 * Math.pow(lambda, 2) - Math.pow(w, 2) * Math.pow(l1, 2));
  if (discx < 0 || discy < 0) {
    return [];
  } else {
    x1 = (w * lambda + Math.sqrt(discx)) / (2 * w2z2);
    x2 = (w * lambda - Math.sqrt(discx)) / (2 * w2z2);
    y1 = (z * lambda + Math.sqrt(discy)) / (2 * w2z2);
    y2 = (z * lambda - Math.sqrt(discy)) / (2 * w2z2);
    if (Math.round(l1) !== Math.round(edgelen([p1, [x1 + r, y1 + s]]))) {
      return [[x1 + r, y2 + s], [x2 + r, y1 + s]];
    } else {
      return [[x1 + r, y1 + s], [x2 + r, y2 + s]];
    }
  }
};

shortcut = function(graph) {
  var bestshortcut, d, i, nointersections, p1, p2, p3, t1, t2, t3, _i, _ref1, _ref2, _ref3;
  if (graph.edges.length < 6) {
    return false;
  }
  bestshortcut = Infinity;
  for (i = _i = 0, _ref1 = graph.exteriors.length - 2; 0 <= _ref1 ? _i < _ref1 : _i > _ref1; i = 0 <= _ref1 ? ++_i : --_i) {
    _ref2 = graph.exteriors.slice(i, +(i + 2) + 1 || 9e9), t1 = _ref2[0], t2 = _ref2[1], t3 = _ref2[2];
    d = distbetween(t1, t3);
    nointersections = function() {
      var a, b, _j, _len, _ref3, _ref4;
      _ref3 = graph.edges;
      for (_j = 0, _len = _ref3.length; _j < _len; _j++) {
        _ref4 = _ref3[_j], a = _ref4[0], b = _ref4[1];
        if (intersects(a, b, t1, t3)) {
          return false;
        }
      }
      return true;
    };
    if (d < bestshortcut && !graph.hasEdge([t1, t3]) && nointersections()) {
      bestshortcut = d;
      _ref3 = [t1, t2, t3], p1 = _ref3[0], p2 = _ref3[1], p3 = _ref3[2];
    }
  }
  if (bestshortcut < Infinity) {
    graph.shortcut(p1, p2, p3);
    console.log('shortcut success!');
    return true;
  } else {
    console.log('convex');
    return false;
  }
};

augment = function(graph, dist) {
  var i, l1, l2, n1, n2, nps, p1, p2, safeToAdd;
  l1 = dist.sample();
  l2 = dist.sample();
  i = Math.floor(Math.random() * (graph.exteriors.length - 1));
  p1 = graph.exteriors[i];
  p2 = graph.exteriors[i + 1];
  nps = newpoints(p1, p2, l1, l2);
  if (nps.length > 0) {
    n1 = nps[0], n2 = nps[1];
    safeToAdd = function(testpoint) {
      var a, b, c, p, _i, _j, _k, _len, _len1, _len2, _ref1, _ref2, _ref3, _ref4;
      _ref1 = graph.points;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        p = _ref1[_i];
        if (distbetween(p, testpoint) < 20) {
          return false;
        }
      }
      _ref2 = graph.adjacentpoints(p1);
      for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
        c = _ref2[_j];
        if ((__indexOf.call(graph.adjacentpoints(p2), c) >= 0)) {
          if (intriangle(p1, p2, c, testpoint)) {
            return false;
          }
        }
      }
      _ref3 = graph.edges;
      for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
        _ref4 = _ref3[_k], a = _ref4[0], b = _ref4[1];
        if (intersects(a, b, testpoint, p1)) {
          return false;
        }
        if (intersects(a, b, testpoint, p2)) {
          return false;
        }
      }
      return true;
    };
    if (safeToAdd(n2)) {
      graph.extend(p1, p2, n2);
      return console.log('augmented');
    } else if (safeToAdd(n1)) {
      graph.extend(p1, p2, n1);
      return console.log('augmented');
    } else {
      return augment(graph, dist);
    }
  } else {
    return augment(graph, dist);
  }
};
