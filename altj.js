// Generated by CoffeeScript 1.7.1
var Graph, NormalDistribution, augment, dist, distbetween, drawgraph, edgelen, eq, graph, grow, growN, h, intersects, intriangle, newpoints, paper, paper2, shortcut, w,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

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

  return Graph;

})();

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
  var leftmost, lower, rightmost, upper, _ref, _ref1;
  leftmost = Math.min(p1[0], p2[0], p3[0]);
  rightmost = Math.max(p1[0], p2[0], p3[0]);
  lower = Math.min(p1[1], p2[1], p3[1]);
  upper = Math.max(p1[1], p2[1], p3[1]);
  return (leftmost <= (_ref = testp[0]) && _ref <= rightmost) && (lower <= (_ref1 = testp[1]) && _ref1 <= upper);
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

w = document.body.clientWidth;

h = document.body.clientHeight;

graph = new Graph([w / 2 + 0, h / 3 + 0], [w / 2 + 40, h / 3 + 10], [w / 2 + 30, h / 3 + 90]);

dist = new NormalDistribution(edgelen(graph.edges[0]), edgelen(graph.edges[1]), edgelen(graph.edges[2]));

paper = new Raphael(document.getElementById('raphael'), w, h);

paper2 = new Raphael(document.getElementById('dist-graph'), 500, 200);

window.onload = function() {
  paper.ZPD({
    zoom: true,
    pan: true,
    drag: false
  });
  return drawgraph();
};

drawgraph = function() {
  var b, bucketsize, edge, histogram, key, l, offset, val, x1, x2, y1, y2, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3, _ref4, _results;
  paper.clear();
  _ref = graph.getEdges();
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    _ref1 = _ref[_i], (_ref2 = _ref1[0], x1 = _ref2[0], y1 = _ref2[1]), (_ref3 = _ref1[1], x2 = _ref3[0], y2 = _ref3[1]);
    paper.path("M " + x1 + " " + y1 + " l " + (x2 - x1) + " " + (y2 - y1)).attr('stroke', 'black');
  }
  paper2.clear();
  bucketsize = 5;
  histogram = {};
  _ref4 = graph.edges;
  for (_j = 0, _len1 = _ref4.length; _j < _len1; _j++) {
    edge = _ref4[_j];
    l = Math.floor(edgelen(edge));
    b = l - (l % bucketsize);
    histogram[b] = histogram[b] != null ? histogram[b] + 1 : histogram[b] = 1;
  }
  console.debug(histogram);
  offset = -3 * bucketsize;
  _results = [];
  for (key in histogram) {
    val = histogram[key];
    h = val * 3;
    _results.push(paper2.rect(offset + key * 2.2, 190 - h, bucketsize * 2, h).attr({
      'fill': 'black',
      stroke: 'none'
    }));
  }
  return _results;
};

grow = function() {
  var success;
  if (Math.random() > 0.5) {
    success = shortcut();
    if (!success) {
      return augment();
    }
  } else {
    return augment();
  }
};

growN = function(n) {
  var cont, target;
  target = graph.points.length + n;
  cont = function() {
    if (graph.points.length < target) {
      grow();
    }
    return setTimeout(cont, 5);
  };
  return cont();
};

shortcut = function() {
  var a, b, bestshortcut, d, i, p1, p2, p3, u, v, _i, _j, _k, _len, _len1, _ref, _ref1, _ref2, _ref3, _ref4, _ref5;
  console.log('shortcut');
  bestshortcut = Infinity;
  for (i = _i = 0, _ref = graph.exteriors.length - 2; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
    d = distbetween(graph.exteriors[i], graph.exteriors[i + 2]);
    if (d < bestshortcut) {
      bestshortcut = d;
      _ref1 = graph.exteriors.slice(i, +(i + 2) + 1 || 9e9), p1 = _ref1[0], p2 = _ref1[1], p3 = _ref1[2];
    }
  }
  _ref2 = graph.edges;
  for (_j = 0, _len = _ref2.length; _j < _len; _j++) {
    _ref3 = _ref2[_j], u = _ref3[0], v = _ref3[1];
    if (eq(u, p1) && eq(v, p3)) {
      return false;
    }
    if (eq(u, p3) && eq(v, p1)) {
      return false;
    }
  }
  _ref4 = graph.edges;
  for (_k = 0, _len1 = _ref4.length; _k < _len1; _k++) {
    _ref5 = _ref4[_k], a = _ref5[0], b = _ref5[1];
    if (intersects(a, b, p1, p3)) {
      return false;
    }
  }
  graph.shortcut(p1, p2, p3);
  drawgraph();
  console.log('shortcut success!');
  return true;
};

augment = function() {
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
      var a, b, c, p, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _ref3;
      _ref = graph.points;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        if (distbetween(p, testpoint) < 20) {
          console.log('too close');
          return false;
        }
      }
      _ref1 = graph.adjacentpoints(p1);
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        c = _ref1[_j];
        if ((__indexOf.call(graph.adjacentpoints(p2), c) >= 0)) {
          if (intriangle(p1, p2, c, testpoint)) {
            return false;
          }
        }
      }
      _ref2 = graph.edges;
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        _ref3 = _ref2[_k], a = _ref3[0], b = _ref3[1];
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
    } else {
      return augment();
    }
  } else {
    console.log('failed');
    return augment();
  }
};
