# Parametric Robot Mower Wheel

Replacement drive wheels for robotic lawn mowers, generated from a handful of
measurements. Designed to print **without a single line of support material**.

Originally built for a Husqvarna Automower 115H, but the hub, the tread and the
wheel dimensions are all independent, so adding a mower means adding five
numbers rather than remodelling anything.

---

## How it prints with no support

The wheel prints face down. The outer face is a solid skin sitting flat on the
plate, and every other surface is either vertical or an upward-facing slope.
Three details make that work:

**The interior is a skin plus spokes, not a solid disc.** The original model
this was derived from had a solid cone inside, 948 cm3 of it, with a 78 degree
overhang on the underside. Here the same load path is a 2.4 mm face skin and 12
radial plates whose top edge climbs from the hub to the rim. Material drops by
roughly half and the underside disappears entirely.

**Chevron lugs are twisted extrusions, not swept solids.** Each layer of a
chevron is the layer below shifted sideways, which is just a leaning wall. The
`chevron_sweep` parameter controls the lean. At the default 5.5 degrees the arms
sit at about 37 degrees from the wheel axis. Past 7 degrees you cross 45 and the
slicer starts asking for support.

**Lug chamfers are cut by a revolved envelope.** `lug_chamfer` puts a 45 degree
chamfer where the tread meets the inner and outer sides of the wheel. A square
corner there is the first thing to wear round in service, and it chips. Rather
than reshaping every lug, the lug group is intersected with a disc that carries
the chamfer at each end: one cheap operation, every lug, every tread type, and
the rim below the tread is untouched because the envelope only bites past
`tip_r - chamfer`. The lower chamfer faces down at 45 degrees, the standard
self-supporting limit, and it is about a millimetre tall.

**Every roof in the bayonet joint is a 55 degree cone.** Both the groove roof
and the groove floor fall away from the seam. The roof has to, or the ring needs
support; the floor has to, or the underside of each tab is a bare ledge. The
side effect is that the tab seats on a cone, which centres the two halves and
takes up print tolerance.

The only overhang left in the whole model is the ceiling of the hub recess, an
annulus around the axle bore that bridges over a shallow pocket. It closes on
its own.

## Which way round does it go

**The solid face goes outward. The spokes face the mower.** Get this backwards
and nothing fits.

The reason is the drive boss. On the 115H it stands 20 mm proud of its seat, and
with the stock wheel on, 12 mm is still showing. So the boss passes right
through the hub plate and needs somewhere to go on the far side: that is the
recess in the middle of the outer face, where the washer and the screw also sit.
The mower side needs the opposite, an open pocket whose floor seats on the drive
disc.

This also means the two wheels are mirror images rather than one part flipped
over, which is what `side` is for.

### How the 115H hub numbers were derived

| Measured | |
|---|---|
| shaft proud of its seat | 20.0 |
| shaft still showing with the stock wheel on | 12.0 |
| pocket on the inner face | 54.20 bore, 2.50 wall |
| drive disc on the mower | 47.60 |
| black surround | 60.42 |
| screw boss | 16.0 |

20 minus 12 gives a **hub plate 8 mm thick**, and the pocket floor is the face
the wheel seats on. That fixes the plate across the width once you know
`pocket_depth`. ### The inner face: what turns and what does not

The drive disc turns with the wheel. The shroud around it does not, and it sits
lower than the disc. **Anything on the wheel that reaches the shroud is a brake
pad**, and the mower stalls. This is the single easiest way to produce a wheel
that looks right and does not work.

So the inner face is deliberately mean about where it makes contact. A seating
pad runs from the bore out to `drive_disc_diameter/2 - seat_margin`, and that is
the only place the wheel touches anything. From there out to
`shroud_od/2 + shroud_margin` the face is cut back by `shroud_clearance`, a
straight air gap between a part that turns and a part that does not. On the 115H
the generator echoes:

```
inner face: seating pad up to Ø44.6 on a disc of Ø47.6
| cut back 3 mm from Ø44.6 out to Ø64.42
| stationary shroud is Ø60.42
```

The relief is carved from the top in print orientation, so its floor faces up
and it costs nothing to print.

An earlier version of this generator put a centring ring on the inner face,
reading the gap around the shroud as a groove meant to be engaged. It is not.
`register_mode` still exists for a machine that genuinely has one, but it
defaults to `none`, and it should stay there unless you have confirmed on the
actual mower that the wheel is meant to engage something.

### Where the hub plate sits

The plate is `hub_plate_thickness` thick and its back face IS the seating face,
so it needs no separately measured pocket depth. On the 115H: 8 mm of plate, a
20 mm shaft, and 12 mm still showing once the wheel is on. 20 minus 8 is 12, so
the arithmetic closes on measurements alone.

## When the wheel does not clear the bodywork

`max_overall_diameter` is a hard ceiling on the diameter over the lugs. Measure
the wheel arch, subtract the clearance you want, and put the result in. 0
disables the limit.

It trims lugs, so it only helps for a few millimetres. If you are over by more
than the lug height, the wheel is simply the wrong size and both
`wheel_diameter` and `rim_diameter` need to come down together. That was the
case here: the donor STL was 262.4 over the lugs against a stock wheel of 240,
and its tread scrubbed the bodywork. The defaults are now 240 and 218, which
also means a 115H wheel needs no flats at all on a 256 plate.

Only the lugs get shorter. `rim_diameter` is untouched, so the mower does not
drop and the rolling diameter in grass barely moves, since in anything but bare
soil the rim carries most of the load. This is the right knob when the tread is
scrubbing the body, and it beats shrinking the whole wheel, which changes ride
height and therefore cutting height.

## Wheels bigger than the plate

A 262 mm wheel does not fit a 256 mm plate. The generator cuts four flats and
**phases the tread so a groove lands on each flat**, so only the lugs
immediately beside a flat lose any height. On the default Automower 115H
settings that is 4.7 percent of the tread area, 5.2 mm deep at worst, and the
rim itself is never touched.

Four flats can only trim the lugs. If your plate is smaller than the rim
diameter the model stops with a message telling you so, because no amount of
flattening will make it fit.

## One piece or two

`build_style` switches between a single printed wheel and a hub disc plus a
tread ring joined by a bayonet.

**The split is not a way to fit a big wheel on a small plate.** The ring is
still the full diameter. What it buys you is:

- a TPU tread ring on a rigid PETG or ASA hub
- replacing a worn tread without reprinting the hub
- two colours without an AMS

Assembly: drop the hub into the ring from the back, through the four notches,
turn it a quarter of a notch pitch, then push a printed key into any notch to
stop it turning back. No screws.

The joint costs about 145 cm3 of extra envelope for the two collars, so print
the two-piece version only if you want one of the three benefits above.

## Parameters

| Group | What to measure |
|---|---|
| Mower | Which hub interface. Named mowers carry their own numbers. |
| Wheel size | Overall diameter over the lugs, diameter at the base of the lugs, total width, arch limit. |
| Tread | Pattern, lug count, lug widths, chevron sweep, lug chamfer. |
| Structure | Spoke count and thickness, skin thickness, rim thickness. |
| Printing | Plate size, margin, one or two piece, left or right, fit clearance. |
| Generic hub | Bore shape and size when your mower is not in the list yet. |
| Two piece joint | Where to split, and the bayonet dimensions. |

`side` matters. The chevron treads are directional and the face skin has to stay
on the outside of both wheels, so you cannot flip one part over to make the
other one. Print one `right` and one `left`. It makes no difference for the
`spikes` and `blocks` treads.

## Print the fit test first

Set `build_style` to **Fit test parts only** and you get two small parts instead
of a wheel. They take minutes, and between them they answer the two questions
that decide whether an eight hour print is wasted.

**The bore gauge** is a flat bar with one hole per clearance, the same thickness
as the real hub plate so the holes are as deep as they will be on the wheel. It
is labelled with the mower and the nominal bore, and each hole is labelled with
its clearance. Slide it onto the mower shaft and keep the tightest hole that
goes on without forcing. That number goes into `bore_clearance`.

Default steps are 0, 0.10, 0.15, 0.20 and 0.30 mm on the radius. Edit
`gauge_steps` if your printer runs well off size. On the 115H the bar comes out
133 x 35 x 9 mm.

`fit_test_part` picks one part at a time so each print stays short: check the
bore first, then the hub interface, then the overall diameter. Left on `all`,
plate 1 is the gauge, plate 2 the skeleton, plate 3 the coupon.

**The skeleton** is the whole wheel reduced to what you actually need to test:
the real hub, three arms out to the real overall diameter, and a real piece of
tread at the end of each one. Bolt it on, turn it by hand, and in twenty minutes
you know whether the hub seats and whether the lugs clear the bodywork. Every
dimension comes from the same modules as the wheel, so nothing on it is a
lookalike. 124 cm3 of envelope against 449 for the wheel.

The arms sit 45 degrees off the four flats, so each one carries the full overall
diameter even with truncation on. `skeleton_arms`, `skeleton_arc` and
`skeleton_arm_width` are there if you want it lighter or stiffer.

**The hub coupon** is the real hub with the wheel around it cut down to a disc,
built from the same modules as the wheel and printed in the same orientation. It
checks what the gauge cannot: that the hub seats fully on the mower, at the
right depth, and that the screw and cap still clear. It carries the clearance it
was printed with raised on its inner face, so a coupon found in a drawer six
months later still means something. About 112 mm across for the 115H.

Orientation matters more than it looks. A hole printed lying down is not the
same hole as one printed standing up, so both test parts are generated in the
same orientation as the wheel. Do not let the slicer rotate them.

## Print settings

| | |
|---|---|
| Orientation | as generated, face down |
| Supports | none |
| Walls | 3, or 4 in PETG |
| Top / bottom | 5 / 5 |
| Infill | 15 percent gyroid, 25 if the ground is rough |
| Plate adhesion | none needed, the face skin is a very large first layer |
| Material | PETG or ASA. PLA works but degrades in sunlight. |

## Supported mowers

| `hub_type` | Bore | Suggested wheel | Source of the numbers |
|---|---|---|---|
| `husqvarna_115h` | 16.3 | 240 / 218 / 32 | measured on the machine, see below |
| `husqvarna_nera` | 17.0 | 251 / 234 / 30 | measured off a donor STL for 310E, 320, 410XE, 430X, 450X NERA |
| `hex_drive` | hex 26.5 af | yours | two donor models, 26.4 and 26.85 across flats |
| `plain_bore`, `hex_bore`, `splined` | yours | yours | the Generic hub group |

Print the fit test parts before the wheel. See below.

Suggested wheel is overall diameter / rim diameter / width in mm.

### How these wheels are actually driven

There are two families, and they could not be more different.

**Plain bore, friction driven.** The 115H and the NERA both have a plain round
bore and no drive feature anywhere: no spline, no hex, no flat, no drive dog.
Sections taken at six heights through the NERA hub come back perfectly circular
at every radius. They are driven by friction, clamped against the mower hub by
the centre screw.

**Hex drive.** `hex_drive` cuts a blind hex socket that opens on the inner face
of the wheel, a through bore for the centre screw, and an optional bolt circle
that passes through the floor of the socket. This is a real positive drive, so
the bore fit stops being the thing that carries torque. Two donor models measure
26.4 and 26.85 mm across flats, hence the 26.5 default, but measure yours.
`hub_type = hex_drive` also switches the hub to a solid full depth boss, because
a socket has to be cut out of something.

For the plain bore family, friction is all there is.
That makes the bore fit the one dimension worth caring about. Too loose and the
wheel wobbles on the shaft, works the screw head, and eventually rounds out the
bore. `bore_clearance` defaults to 0.15 mm on the radius, which suits a printer
that is roughly on size. Measure a test print before committing eight hours.

If your mower does have a positive drive feature, use `splined` or `hex_bore`
and tell me, because that is worth a named entry.

## Adding a mower

Every hub is six numbers, all measured from the outer face of the wheel. Watch
the reference face: donor STLs are often modelled the other way up, and the
whole hub lands 8 mm out if you take the raw z values.

| | |
|---|---|
| `bore_r` | radius of the axle hole |
| `hub_r` | outer radius of the disc that carries the axle |
| `inset` | depth of the recess in front of the hub plate |
| `plate_bot` | distance from the outer face to the back of the plate |
| `recess_r` | inner radius of the ring bounding that recess |
| `boss_top` | how far the ring around that recess carries on in z |

Add one line to each function in `src/10_hubs.scad`, plus an entry in the
`hub_type` dropdown in `src/00_header.scad`.

**Measure the real wheel.** Torque on a drive wheel goes through splines or
drive dogs, not through a plain round bore, and a hub copied from someone else's
STL is a guess. If you contribute a mower, say how you measured it.

## Repo layout

```
src/00_header.scad    parameters and customizer annotations
src/10_hubs.scad      hub library
src/20_treads.scad    tread library
src/30_core.scad      skin, spokes, rim, build plate flats
src/40_joint.scad     bayonet joint and locking key
src/50_output.scad    MakerWorld plates and desktop render
build.py              flattens src/ into dist/
test/check.py         geometry audit of one rendered part
test/matrix.py        renders the configuration matrix and asserts invariants
```

`build.py` does two things that matter for MakerWorld, not just concatenation:

1. **Flattens the sources into one file.** The Parametric Model Maker does not
   resolve local include trees.
2. **Hoists every parameter block to the top.** The OpenSCAD customizer only
   surfaces parameters declared before the first `module` or `function`. The
   joint and fit-test parameters live next to the code they belong to, which
   reads better but would leave those two groups invisible in the MakerWorld UI.
   The build moves them up, tagged with the file they came from.

Never hand-edit `dist/`. Edit `src/` and rebuild:

```
python3 build.py
```

- **`dist/mower_wheel_pmm.scad` is the file you upload to MakerWorld.** It
  renders nothing at top level; MakerWorld calls `mw_plate_1()`,
  `mw_plate_2()`, `mw_plate_3()` and `mw_assembly_view()` itself. Uploading the
  desktop file instead would render a wheel at top level as well as the plates.
- `dist/mower_wheel.scad` for desktop OpenSCAD. Set `render_target` to
  `assembly`, `wheel`, `ring`, `hub`, `key`, `gauge` or `coupon`.

## Checks

`test/matrix.py` renders every tread and every hub type and asserts that each
result is watertight, is a single body, has no downward face steeper than 45
degrees outside the hub recess, and stays inside the plate.

The two-piece fit is checked by boolean intersection of the two rendered parts:
zero interference in the locked position, zero when turned into the notches so
it can be inserted, and non-zero when lifted 1.5 mm from locked, which is what
proves the bayonet actually retains.

## Licence

CC-BY 4.0.
