# B · Un 2027 ben catalitzat — design reference

This is a design mockup created in a visual design tool, exported as a
standalone page. Treat it as a REFERENCE MOCKUP, not production code:
the markup and inline styles carry the design's precise values — colors,
font sizes, spacing, radii, shadows, layout — which an implementation
should replicate faithfully in its own components and styling system
rather than copy wholesale.

## Contents

- `Catalysed.dc.html` — the artboard (a Design Component: an `<x-dc>`
  template + a small logic class). The values to replicate live in its
  inline `style="…"` attributes and the `<helmet><style>` block.
- `support.js`, `vendor/react*.js` — the runtime that renders the
  component in a browser; not part of the design.

## Viewing

Serve the folder (e.g. `python3 -m http.server`) and open `Catalysed.dc.html`;
some browsers block the scripts over file://.

## The metaphor

The card treats the change of year as a chemical reaction and plots it as a
reaction energy profile.

- **2026 → 2027 is a reaction.** 2026 is the reactant and 2027 the product.
  2027 sits lower on the energy axis than 2026: the reaction is favourable,
  so the new year is a better, more stable place to be.
- **The mountain is the uncatalysed path.** Without a catalyst the reaction
  has to climb a tall barrier (the grey *E*ₐ, its activation energy), drawn
  as a snow-capped winter peak: a hard, lonely climb.
- **The ICIQ community is the catalyst.** The gold curve is the same
  reaction with a catalyst: the mountain becomes two small hills with a far
  lower barrier (the gold *E*ₐ). The label names the catalyst: *the ICIQ
  community*.
- **The two people and the heart.** A catalysed route often passes through
  an intermediate, the dip between the two humps. A person stands on each
  hump, reaching for the other, with a heart over the valley between them:
  the mountain that kept them apart is now low enough for them to meet.
- **"A catalyst doesn't change the destination: it makes the path easier."**
  This is literally true in chemistry: a catalyst lowers the barrier but
  leaves the start and end states, and the overall energy change, untouched.
  2026 and 2027 sit at the same heights on both curves; only the road
  between them changes.
- **The reaction scheme in the header** writes the year the way chemists
  write a reaction: the catalyst above the arrow (*cat. ICIQ community*), the
  conditions below it (*365 d*, a year of reaction time), and the yield after
  the product (*100 %*: all of 2026 is converted, nobody is left behind).
- **The night sky.** Small stars, the brightest drawn as the asterisk from the
  ICIQ pictogram set, and a few glowing orange points that echo the lit
  nodes of the 2025 card's molecular bauble.

The styling follows the ICIQ 2024 brand guidelines: the corporate blue
`#024f67` as the ground, the secondary orange `#f9a01b` as the accent (lime
and magenta are offered as alternatives), neutrals built from tints of the
blue, the sweeping arc of the corporate templates in the background, and
figures and heart drawn in the line style of the brand pictograms.

## Rendering

`python3 render.py` renders every format into `renders/` with headless
Chrome (fonts load from Google Fonts, so it needs network access):

| Format  | Size       | File                                      |
|---------|------------|-------------------------------------------|
| `card`  | 2236×3176  | `xmas-card-2027.png` (the card at 4×)     |
| `1080p` | 1920×1080  | `xmas-card-2027-wallpaper-1920x1080.png`  |
| `4k`    | 3840×2160  | `xmas-card-2027-wallpaper-3840x2160.png`  |

Pass format names to render only those, e.g. `python3 render.py card 4k`.
The wallpapers scale the card to the full height and fill the sides with
the brand blue.
