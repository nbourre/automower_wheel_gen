// =====================================================================
//  PARAMETRIC ROBOT MOWER WHEEL
//  Replacement drive wheels for robotic lawn mowers, generated from a
//  handful of measurements. Prints without any support material.
//
//  Design rules baked into this generator:
//   * The wheel prints face-down: the outer face is a solid skin sitting
//     flat on the build plate, and every other surface is either vertical
//     or an upward-facing slope. Nothing needs support.
//   * The interior is a skin + radial spokes instead of a solid disc,
//     which cuts the material roughly in half.
//   * If the wheel is wider than the build plate, four flats are cut and
//     the tread is phased so a groove lands on each flat. Only the lugs
//     next to a flat lose any height.
//
//  Licence: CC-BY 4.0
// =====================================================================

/* [Mower] */
// Hub interface. Pick your mower, or a generic bore and enter the numbers below.
hub_type = "husqvarna_115h";    // [husqvarna_115h:Husqvarna Automower 105/115H, husqvarna_nera:Husqvarna NERA 310E/320/410XE/430X/450X, hex_drive:Hex drive socket + bolt circle, plain_bore:Generic round bore, hex_bore:Generic hex bore, splined:Generic splined bore]

/* [Wheel size] */
// Overall diameter measured over the tips of the lugs (mm)
wheel_diameter = 262.4;         // [80:0.1:400]
// Diameter at the base of the lugs, i.e. the rim itself (mm)
rim_diameter = 240;             // [60:0.1:380]
// Total width of the wheel (mm)
wheel_width = 32;               // [8:0.5:120]

/* [Tread] */
tread_type = "chevron_mixed";   // [chevron_mixed:Chevrons + intermediate chevrons, chevron:Chevrons only, spikes:Triangular spikes, blocks:Straight blocks]
// Number of main lugs. Keep it a multiple of 4 so a groove lands on each flat.
lug_count = 16;                 // [8:4:48]
// Width of a lug at its base (mm)
lug_base_width = 12;            // [3:0.5:30]
// Width of a lug at its tip (mm)
lug_tip_width = 7;              // [2:0.5:25]
// Half sweep angle of the V, in degrees. Above 7 the arms exceed 45 deg
// from the wheel axis and the slicer will start asking for support.
chevron_sweep = 5.5;            // [0:0.5:7]
// 45 degree chamfer on the inner and outer edges of every lug, where the
// tread meets the sides of the wheel. A square corner there is the first
// thing to round off in service, and it chips. 0 disables.
lug_chamfer = 1.2;              // [0:0.1:6]

/* [Structure] */
spoke_count = 12;               // [4:1:36]
spoke_thickness = 3.0;          // [1.5:0.1:8]
// Solid face skin on the build-plate side (mm)
skin_thickness = 2.4;           // [0.8:0.2:6]
// Radial thickness of the rim (mm)
rim_thickness = 8;              // [3:0.5:30]

/* [Printing] */
// Usable build plate, in mm. 256 for P1P/P1S/X1C, 220 for A1, 180 for A1 mini.
bed_size = 256;                 // [120:1:500]
// Safety margin kept away from the plate edge, per side (mm)
bed_margin = 2;                 // [0:0.5:20]
build_style = "one_piece";      // [one_piece:One piece, two_piece:Hub + tread ring (bayonet), fit_test:Fit test parts only (prints in minutes)]
// Which side of the mower. The tread is directional, so the two wheels
// are mirror images. Irrelevant for the "spikes" and "blocks" treads.
side = "right";                 // [right:Right, left:Left]
// Printed clearance on every mating surface of the bayonet (mm)
fit_clearance = 0.25;           // [0.05:0.05:0.6]
// Extra clearance on the axle bore, added to the radius. None of these
// wheels drive through the bore, they are clamped by the centre screw,
// so a snug bore is what stops the wheel wobbling on the shaft.
bore_clearance = 0.15;          // [0:0.05:1]

/* [Hex drive hub] */
// Used when hub_type is hex_drive. Both donor wheels measured so far come
// out at 26.4 and 26.85 across flats, so 26.5 is a sensible starting point,
// but MEASURE YOURS.
hex_across_flats = 26.5;        // [8:0.05:60]
// Depth of the socket, measured from the inner face of the wheel
hex_depth = 12;                 // [3:0.5:40]
// Through bore for the centre screw. 0 removes it.
hex_screw_diameter = 6;         // [0:0.1:20]
// Bolt circle. bolt_count 0 removes it.
bolt_count = 3;                 // [0:1:12]
bolt_circle_diameter = 19;      // [6:0.1:120]
bolt_diameter = 5.5;            // [1:0.1:16]

/* [Generic hub] */
// Used only when hub_type is not a named mower.
custom_bore_diameter = 16.8;    // [4:0.1:60]
// Across-flats for hex, tip diameter for splined
custom_bore_size = 16.8;        // [4:0.1:60]
custom_spline_count = 12;       // [4:1:40]
// Radius of the disc that carries the axle (mm)
custom_hub_radius = 36;         // [10:0.5:90]
// Depth of the outer face recess in front of the hub plate (mm)
custom_hub_inset = 7.5;         // [0:0.1:40]
// Thickness of the hub plate itself (mm)
custom_hub_plate = 9;           // [2:0.1:40]
// Inner radius of the clearance recess around the axle (mm)
custom_recess_radius = 24.675;  // [5:0.1:80]
// How far the ring around that recess carries on in z. Leave at 0 for a
// plain hub plate, raise it for a hub with a full width boss.
custom_boss_top = 0;            // [0:0.5:120]

/* [Hidden] */
$fn = 180;
eps = 0.01;
weld = 0.5;                     // union overlap, keeps CGAL happy
