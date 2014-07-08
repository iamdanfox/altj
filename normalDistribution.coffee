class NormalDistribution
  # mean     :
  # variance :
  # stdev    :

  # construct a normal distribution given three weights as representative sample
  # uses Central Limit Theorem
  @make: (len1, len2, len3) ->  # TODO rewrite to take list
    # If X1,...,Xn is a sample from a distribution with mean, m, and variance,
    # v2, then for large n, the sample mean has approximately a normal
    # distribution with mean m and variance v2/n.
    mean = (len1+len2+len3) / 3
    variance = ((len1-mean)**2 + (len2-mean)**2 + (len3-mean)**2) / 9
    new NormalDistribution(mean, variance)

  constructor: (@mean, @variance) ->
    @stdev = Math.sqrt(@variance)

  sample: () ->
    # Math.random has mean 0.5 and variance 1/12.
    x = (Math.random() - 0.5)*2*Math.sqrt(3)
    # we need a variable x that has mean 0 and variance 1.
    return @stdev*x + @mean

# Assumes equal mixing.
# TODO: try using an uneven mixing
class TriModal
  # m1, v1, m2, v2, m3, v3

  @make: (len1, len2, len3) ->
    variance = 5
    return new TriModal(len1,variance,len2,variance,len3,variance)

  constructor: (m1, v1, m2, v2, m3, v3) ->
    @normal1 = new NormalDistribution(m1,v1)
    @normal2 = new NormalDistribution(m2,v2)
    @normal3 = new NormalDistribution(m3,v3)

  sample: () ->
    x = Math.random()
    switch
      when 0   <= x < 1/3 then @normal1.sample()
      when 1/3 <= x < 2/3 then @normal2.sample()
      when 2/3 <= x <= 1  then @normal3.sample()
