

all: dist dist/app.js dist/cli-wrapper.js
	@node dist/cli-wrapper.js


dist/app.js: example/MyApp.elm
	elm make $< --output $@

dist/cli-wrapper.js: src/cli-wrapper.js
	cp $< $@

dist:
	mkdir dist
