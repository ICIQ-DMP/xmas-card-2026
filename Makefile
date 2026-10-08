# Render the card into renders/ with headless Chrome.
#   make            all renders
#   make card       2236x3176 card PNG (the card at 4x)
#   make 1080p      1920x1080 wallpaper PNG
#   make 4k         3840x2160 wallpaper PNG
#   make pdf        A5 print PDF (needs Ghostscript)
#   make release TAG=v1.0.0   publish the renders as a GitHub release
#   make clean
#
# Wallpapers scale the card to the full height and fill the sides with the
# card background, letting the brand arc run on past the card's edges.

.SILENT:
SHELL       := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
.NOTPARALLEL:

CHROME  ?= $(shell command -v google-chrome || command -v google-chrome-stable || command -v chromium || command -v chromium-browser)
PORT    ?= 8765
TAG     ?=
URL     := http://127.0.0.1:$(PORT)
SOURCES := Catalysed.dc.html support.js $(wildcard img/*)
CHROME_RUN := "$(CHROME)" --headless=new --disable-gpu --hide-scrollbars --virtual-time-budget=8000

# The card's root element; the wallpaper pages rewrite it, so fail loudly if it changes.
ROOT_STYLE := position: relative; width: 559px; height: 794px; overflow: hidden;

CARD    := renders/xmas-card-2027.png
WP1080  := renders/xmas-card-2027-wallpaper-1920x1080.png
WP4K    := renders/xmas-card-2027-wallpaper-3840x2160.png
PDF     := renders/xmas-card-2027-print-A5.pdf
RENDERS := $(CARD) $(WP1080) $(WP4K) $(PDF)

# Serve the folder for the rest of the recipe, so the card's relative asset paths resolve.
define serve
mkdir -p renders
python3 -m http.server $(PORT) --bind 127.0.0.1 >/dev/null 2>&1 &
server=$$!
trap 'kill $$server; rm -f .render-*.html' EXIT
sleep 1
endef

.PHONY: all card 1080p 4k pdf release clean

all: $(RENDERS)

card: $(CARD)
1080p: $(WP1080)
4k: $(WP4K)
pdf: $(PDF)

$(CARD): $(SOURCES)
	$(serve)
	$(CHROME_RUN) --window-size=559,794 --force-device-scale-factor=4 --screenshot=$@ $(URL)/Catalysed.dc.html >/dev/null 2>&1
	echo "card   2236x3176  $@"

renders/xmas-card-2027-wallpaper-%.png: $(SOURCES)
	$(serve)
	w=$(word 1,$(subst x, ,$*)); h=$(word 2,$(subst x, ,$*))
	zoom=$$(awk "BEGIN { printf \"%.6f\", $$h / 794 }")
	sed -e "s|$(ROOT_STYLE)|position: relative; width: 559px; height: 794px; overflow: visible; zoom: $$zoom;|" \
	    -e "s|body{margin:0}|html,body{margin:0;width:$${w}px;height:$${h}px;overflow:hidden;background:#024f67}body{display:flex;justify-content:center;align-items:flex-start}|" \
	    Catalysed.dc.html > .render-$*.html
	grep -q "zoom: $$zoom" .render-$*.html || { echo "card root style changed; update ROOT_STYLE in the Makefile"; exit 1; }
	$(CHROME_RUN) --window-size=$$w,$$h --force-device-scale-factor=1 --screenshot=$@ $(URL)/.render-$*.html >/dev/null 2>&1
	echo "wallpaper $*  $@"

# A5 is the card's exact size (559x794 CSS px = 148x210 mm). Chrome keeps text
# and shapes vector and rasterises the glow effects at 300 ppi; Ghostscript
# then converts the text to outlines and writes plain RGB (same colour values).
$(PDF): $(SOURCES)
	$(serve)
	sed -e "s|body{margin:0}|@page{size:148mm 210mm;margin:0}html,body{margin:0;background:#024f67;-webkit-print-color-adjust:exact;print-color-adjust:exact}|" \
	    Catalysed.dc.html > .render-pdf.html
	tmp=$$(mktemp -d)
	trap 'kill $$server; rm -rf .render-*.html "$$tmp"' EXIT
	$(CHROME_RUN) --no-pdf-header-footer --print-to-pdf="$$tmp/chrome.pdf" $(URL)/.render-pdf.html >/dev/null 2>&1
	TMPDIR="$$tmp" gs -q -o $@ -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -dCompatibilityLevel=1.6 \
	    -sColorConversionStrategy=RGB -dNoOutputFonts -dAutoRotatePages=/None \
	    -dDownsampleColorImages=false -dDownsampleGrayImages=false -dDownsampleMonoImages=false \
	    -dAutoFilterColorImages=false -dColorImageFilter=/FlateEncode "$$tmp/chrome.pdf"
	echo "pdf    A5         $@"

release: $(RENDERS)
	test -n "$(TAG)" || { echo "usage: make release TAG=v1.0.0"; exit 1; }
	gh release create "$(TAG)" $(RENDERS) --title "$(TAG)" --generate-notes

clean:
	rm -rf renders
