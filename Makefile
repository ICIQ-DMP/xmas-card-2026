# Render the card and wallpapers into renders/ (see render.py).
#   make            all renders
#   make card       2236x3176 card
#   make 1080p      1920x1080 wallpaper
#   make 4k         3840x2160 wallpaper
#   make release TAG=v1.0.0   publish the renders as a GitHub release
#   make clean

PYTHON  ?= python3
TAG     ?=
SOURCES := Catalysed.dc.html render.py support.js $(wildcard img/*)

CARD    := renders/xmas-card-2027.png
WP1080  := renders/xmas-card-2027-wallpaper-1920x1080.png
WP4K    := renders/xmas-card-2027-wallpaper-3840x2160.png
RENDERS := $(CARD) $(WP1080) $(WP4K)

.PHONY: all card 1080p 4k release clean

all: $(RENDERS)

card: $(CARD)
1080p: $(WP1080)
4k: $(WP4K)

$(CARD): $(SOURCES)
	$(PYTHON) render.py card

$(WP1080): $(SOURCES)
	$(PYTHON) render.py 1080p

$(WP4K): $(SOURCES)
	$(PYTHON) render.py 4k

release: $(RENDERS)
	@test -n "$(TAG)" || { echo "usage: make release TAG=v1.0.0"; exit 1; }
	gh release create "$(TAG)" $(RENDERS) --title "$(TAG)" --generate-notes

clean:
	rm -rf renders
