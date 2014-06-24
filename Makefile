all: graph.coffee normalDistribution.coffee utilities.coffee main.coffee
	coffee -cbj altj graph.coffee normalDistribution.coffee utilities.coffee main.coffee
