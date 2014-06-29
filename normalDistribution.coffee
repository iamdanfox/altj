
# construct a normal distribution given three weights as representative sample
# uses Central Limit Theorem
makeNormalDist = (len1, len2, len3) ->  # TODO rewrite to take list
  # If X1,...,Xn is a sample from a distribution with mean, m, and variance,
  # v2, then for large n, the sample mean has approximately a normal
  # distribution with mean m and variance v2/n.
  mean = (len1+len2+len3) / 3
  variance = ((len1-mean)**2 + (len2-mean)**2 + (len3-mean)**2) / 9
  new NormalDistribution(mean, variance)


class NormalDistribution
  # mean     :
  # variance :
  # stdev    :

  constructor: (@mean, @variance) ->
    @stdev = Math.sqrt(@variance)

  sample: () ->
    # Math.random has mean 0.5 and variance 1/12.
    x = (Math.random() - 0.5)*2*Math.sqrt(3)
    # we need a variable x that has mean 0 and variance 1.
    return @stdev*x + @mean
