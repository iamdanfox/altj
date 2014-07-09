all: graph.coffee distributions.coffee utilities.coffee ui.coffee
	coffee -cbj altj graph.coffee distributions.coffee utilities.coffee ui.coffee

watch:
	coffee -cwbj altj graph.coffee distributions.coffee utilities.coffee ui.coffee
