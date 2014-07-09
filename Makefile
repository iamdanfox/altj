all: src/*.coffee
	coffee -cbj altj src/*.coffee

watch:
	coffee -cwbj altj src/*.coffee
