

all: dist dist/cli-wrapper.js
	@elm make src/App.elm --output dist/app.js
	@node dist/cli-wrapper.js


dist/cli-wrapper.js: src/cli-wrapper.js
	cp $< $@

dist:
	mkdir dist
