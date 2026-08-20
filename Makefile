SRC := cv.org
DIST := dist

.PHONY: all html pdf clean deploy serve

all: html pdf

html: $(DIST)/index.html

pdf: $(DIST)/cv.pdf

$(DIST)/index.html: $(SRC) templates/style.css
	mkdir -p $(DIST)
	pandoc $(SRC) \
		--standalone \
		--css=style.css \
		-o $(DIST)/index.html
	cp templates/style.css $(DIST)/style.css

$(DIST)/cv.pdf: $(SRC)
	mkdir -p $(DIST)
	pandoc $(SRC) \
		--pdf-engine=xelatex \
		-V geometry:margin=1in \
		-V fontsize=10pt \
		-V mainfont="JetBrainsMono Nerd Font Mono" \
		-V colorlinks=true \
		-V linkcolor=ink \
		-V urlcolor=ink \
		-H templates/preamble.tex \
		-o $(DIST)/cv.pdf

clean:
	rm -rf $(DIST)

serve: html
	cd $(DIST) && python3 -m http.server 8000

deploy: all
	./deploy.sh
