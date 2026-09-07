// =====================================================================
//  HUB LIBRARY
//  Every hub is described by five numbers, all measured from the OUTER
//  face of the wheel (the face that sits on the build plate):
//    bore_r      radius of the axle hole
//    hub_r       outer radius of the disc that carries the axle
//    inset       depth of the recess in front of the hub plate
//    plate_bot   distance from the outer face to the back of the plate
//    recess_r    inner radius of the ring bounding that recess
//    boss_top    how far the recess_r..hub_r ring carries on in z
//  Adding a mower = adding one line to each function below.
//
//  Suggested wheel settings per mower, from the donor models:
//    husqvarna_115h  wheel_diameter 262.4  rim_diameter 240  width 32
//    husqvarna_nera  wheel_diameter 251    rim_diameter 234  width 30
//
//  NOTE ON TORQUE. Both wheels measured so far, the 115H and the NERA,
//  have a plain round bore and no drive dog, spline or flat anywhere.
//  They are driven by friction, clamped against the mower hub by the
//  centre screw. That makes the bore fit the thing to get right: too
//  loose and the wheel wobbles and eats the screw head.
// =====================================================================

function hub_is_named() = hub_type == "husqvarna_115h"
                       || hub_type == "husqvarna_nera";

// "recessed" = a plate set back behind a recess, the shape of both named
// mowers so far. "solid" = a full depth boss, which is what a hex socket
// needs because the socket has to be cut out of something.
function hub_style() = hub_type == "hex_drive" ? "solid" : "recessed";

// 115H: shaft measured at 15.9 mm, so a 16.0 nominal bore.
// NERA: 17.0 as drawn on the Thingiverse original.
function hub_bore_r() =
    hub_type == "husqvarna_115h" ? 8.0
  : hub_type == "husqvarna_nera" ? 8.5
  : hub_type == "hex_drive"      ? max(hex_screw_diameter, 3) / 2
  : custom_bore_diameter / 2;

function hub_outer_r() =
    hub_type == "husqvarna_115h" ? 36
  : hub_type == "husqvarna_nera" ? 40
  : custom_hub_radius;

// NERA note: the donor STL is modelled with its OUTER face at z=30, the
// end the cap snaps into. Everything below is measured from that face,
// so the pocket is 14 deep and the plate sits between 14 and 22.
function hub_inset() =
    hub_type == "hex_drive" ? 0 :
    hub_type == "husqvarna_115h" ? 7.5
  : hub_type == "husqvarna_nera" ? 14
  : custom_hub_inset;

function hub_plate_bot() =
    hub_type == "hex_drive" ? wheel_width :
    hub_type == "husqvarna_115h" ? 16.5
  : hub_type == "husqvarna_nera" ? 22
  : custom_hub_inset + custom_hub_plate;

function hub_recess_r() =
    hub_type == "hex_drive" ? hub_bore_r() :
    hub_type == "husqvarna_115h" ? 24.675
  : hub_type == "husqvarna_nera" ? 24.5
  : custom_recess_radius;

// The 115H hub plate is the whole hub. The NERA has a boss that carries
// on to the far face, so the ring around the recess has to go with it.
function hub_boss_top() =
    hub_type == "hex_drive"      ? wheel_width
  : hub_type == "husqvarna_nera" ? wheel_width
  : max(hub_plate_bot(), custom_boss_top);

// ---- solid body of the hub -------------------------------------------
// The ring between recess_r and hub_r is filled all the way down to the
// build plate. That removes the only awkward overhang of the original
// design and gives the hub a wide first layer.
module hub_body() {
    if (hub_style() == "solid")
        rotate_extrude()
            polygon([[hub_bore_r(), 0], [hub_outer_r(), 0],
                     [hub_outer_r(), wheel_width], [hub_bore_r(), wheel_width]]);
    else
    rotate_extrude()
        polygon([
            [hub_bore_r(),  hub_inset()],
            [hub_recess_r(), hub_inset()],
            [hub_recess_r(), 0],
            [hub_outer_r(),  0],
            [hub_outer_r(),  hub_boss_top()],
            [hub_recess_r(), hub_boss_top()],
            [hub_recess_r(), hub_plate_bot()],
            [hub_bore_r(),   hub_plate_bot()]
        ]);
}

// ---- the hole through it ---------------------------------------------
module hub_bore() {
    c = bore_clearance;
    translate([0, 0, -1])
        if (hub_type == "hex_bore") {
            // hexagon given across flats
            r = (custom_bore_size / 2 + c) / cos(30);
            cylinder(r = r, h = wheel_width + 2, $fn = 6);
        } else if (hub_type == "splined") {
            rmin = custom_bore_diameter / 2 + c;
            rmax = custom_bore_size / 2 + c;
            w    = 2 * PI * rmin / custom_spline_count * 0.5;
            cylinder(r = rmin, h = wheel_width + 2);
            for (i = [0 : custom_spline_count - 1])
                rotate([0, 0, i * 360 / custom_spline_count])
                    translate([0, -w / 2, 0])
                        cube([rmax, w, wheel_width + 2]);
        } else if (hub_type == "hex_drive") {
            // centre screw, right through
            if (hex_screw_diameter > 0)
                cylinder(r = hex_screw_diameter / 2 + c, h = wheel_width + 2);
            // hex socket, open on the inner face only
            translate([0, 0, wheel_width - hex_depth + 1])
                cylinder(r = (hex_across_flats / 2 + c) / cos(30),
                         h = hex_depth + 2, $fn = 6);
            // bolt circle, right through
            for (i = [0 : bolt_count - 1])
                rotate([0, 0, i * 360 / bolt_count])
                    translate([bolt_circle_diameter / 2, 0, 0])
                        cylinder(r = bolt_diameter / 2 + c, h = wheel_width + 2);
        } else {
            cylinder(r = hub_bore_r() + c, h = wheel_width + 2);
        }
}
