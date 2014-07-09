all: jsx

coffee: src/graph.coffee src/distributions.coffee src/utilities.coffee src/ui.coffee
	coffee --no-header -cbj jsx/altj-temp src/graph.coffee src/distributions.coffee src/utilities.coffee src/ui.coffee
	(echo "/** @jsx React.DOM */\n"; cat jsx/altj-temp.js) > jsx/altj.js
	rm jsx/altj-temp.js

jsx: coffee
	jsx jsx/ .
