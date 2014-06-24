// Generated by CoffeeScript 1.7.1

/*

1. Get seed triangle from user
2. Find a MLE distribution on edge lengths.
3. Choose two length by sampling from distribution
4. From exterior points of graph: Randomly choose a pair of adjacent points.
5. Compute extra point
6. Add new point to data structure (Don't add if edges cross existing ones)

Repeat



 * Data structures

set of points :: (x,y) coordinates
set of edges [point,point]
list of exterior points [point,point,point ... point]
 */
var Graph, NormalDistribution, dist, drawgraph, edgelen, graph, grow, intersects, newpoints, paper,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

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
  var x1, x2, y1, y2, _ref, _ref1;
  (_ref = _arg[0], x1 = _ref[0], y1 = _ref[1]), (_ref1 = _arg[1], x2 = _ref1[0], y2 = _ref1[1]);
  return Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
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

NormalDistribution = (function() {
  function NormalDistribution(len1, len2, len3) {
    this.mean = (len1 + len2 + len3) / 3;
    this.variance = (Math.pow(len1 - this.mean, 2) + Math.pow(len2 - this.mean, 2) + Math.pow(len3 - this.mean, 2)) / 9;
    this.stdev = Math.sqrt(this.variance);
  }

  NormalDistribution.prototype.sample = function() {
    var x;
    x = (Math.random() - 0.5) * 2 * Math.sqrt(3);
    return this.stdev * x + this.mean;
  };

  return NormalDistribution;

})();

Graph = (function() {
  Graph.prototype.points = [];

  Graph.prototype.exteriors = [];

  Graph.prototype.edges = [];

  function Graph(p1, p2, p3) {
    this.points = [p1, p2, p3];
    this.exteriors = [p1, p2, p3];
    this.edges = [[p1, p2], [p2, p3], [p3, p1]];
  }

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

  Graph.prototype.getPoints = function() {
    return this.points;
  };

  Graph.prototype.getEdges = function() {
    return this.edges;
  };

  return Graph;

})();

graph = new Graph([110, 110], [150, 110], [130, 190]);

dist = new NormalDistribution(edgelen(graph.edges[0]), edgelen(graph.edges[1]), edgelen(graph.edges[2]));

paper = new Raphael(document.getElementsByTagName('div')[0], 600, 400);

window.onload = function() {
  return drawgraph();
};

drawgraph = function() {
  var circle, x, x1, x2, y, y1, y2, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _results;
  paper.clear();
  _ref = graph.getEdges();
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    _ref1 = _ref[_i], (_ref2 = _ref1[0], x1 = _ref2[0], y1 = _ref2[1]), (_ref3 = _ref1[1], x2 = _ref3[0], y2 = _ref3[1]);
    paper.path("M " + x1 + " " + y1 + " l " + (x2 - x1) + " " + (y2 - y1));
  }
  _ref4 = graph.exteriors;
  _results = [];
  for (_j = 0, _len1 = _ref4.length; _j < _len1; _j++) {
    _ref5 = _ref4[_j], x = _ref5[0], y = _ref5[1];
    circle = paper.circle(x, y, 4);
    _results.push(circle.attr({
      fill: "#f00",
      'stroke-width': 0
    }));
  }
  return _results;
};

grow = function() {
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
      var a, b, _i, _len, _ref, _ref1;
      _ref = graph.edges;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref1 = _ref[_i], a = _ref1[0], b = _ref1[1];
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
      return drawgraph();
    } else if (safeToAdd(n1)) {
      graph.extend(p1, p2, n1);
      return drawgraph();
    }
  } else {
    return console.log('impossible');
  }
};
