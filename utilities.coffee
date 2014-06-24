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
