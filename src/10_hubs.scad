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
//  115H, measured on the machine:
//    shaft standing proud of its seat ............ 20.0 mm
//    shaft still showing with the stock wheel on . 12.0 mm
//    so the stock hub plate is about 8 mm thick
//    pocket on the inner face of the stock wheel . 54.20 bore, 2.50 wall
//    drive disc on the mower ..................... 47.60
//    black surround around it .................... 60.42
//    stock wheel, overall diameter ............... 240
//  The donor STL this project started from was 262.4 over the lugs, 22 mm
//  too big, which is why its tread scrubbed the bodywork.
//  The drive disc carries raised radial ribs and the floor of that pocket
//  carries matching radial marks, so the 115H drives through FACE TEETH
//  and not through the bore. The bore only centres the wheel.
//
//  Suggested wheel settings per mower, from the donor models:
//    husqvarna_115h  wheel_diameter 240    rim_diameter 218  width 32
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
    hub_type == "husqvarna_115h" ? wheel_width - hub_plate_thickness
  : hub_type == "husqvarna_nera" ? 14
  : custom_hub_inset;

// The pocket floor IS the face the wheel seats on, so the plate hangs a
// pocket depth below the inner face and the plate thickness sets the rest.
// Check on the 115H: 8 mm plate, 20 mm shaft, leaves 12 mm showing. Matches.
function hub_plate_bot() =
    hub_type == "hex_drive" ? wheel_width :
    hub_type == "husqvarna_115h" ? wheel_width
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

// ---- mower side clearance --------------------------------------------
// Radius of the pad that actually touches the drive disc.
function seat_r()   = drive_disc_diameter / 2 - seat_margin;
// Radius out to which the inner face is cut back, to clear the shroud.
function relief_r() = shroud_od / 2 + shroud_margin;

// Cut back everything on the inner face between the seating pad and the
// far side of the shroud. Carved from the top in print orientation, so the
// floor faces up and it costs nothing to print.
// Kept for reference. The relief now lives inside hub_outline(), so this is
// no longer subtracted from anything.
module shroud_relief_unused() {
    assert(relief_r() < rim_bore_r() - 2,
        str("The shroud relief reaches r=", relief_r(),
            ", which is into the rim. Check shroud_od."));
    echo(str("inner face: seating pad up to Ø", 2 * seat_r(),
             " on a disc of Ø", drive_disc_diameter,
             " | cut back ", shroud_clearance, " mm from Ø", 2 * seat_r(),
             " out to Ø", 2 * relief_r(),
             " | stationary shroud is Ø", shroud_od));
    if (shroud_clearance > 0)
        translate([0, 0, wheel_width - shroud_clearance])
            rotate_extrude()
                polygon([
                    [seat_r(),   0],
                    [relief_r(), 0],
                    [relief_r(), shroud_clearance + 1],
                    [seat_r(),   shroud_clearance + 1]
                ]);
}

// ---- register ring ---------------------------------------------------
// Bore of the surround, which is the hole the ring has to pass through.
function groove_bore()  = drive_lip_od - 2 * drive_lip_wall;
// Radial width of the groove the ring drops into.
function groove_width() = (groove_bore() - drive_disc_diameter) / 2;

function hub_register_od() =
      register_mode == "none"      ? 0
    : register_mode == "manual"    ? register_od
    :                                groove_bore() - register_clearance;

function hub_register_id() = hub_register_od() > 0
    ? hub_register_od() - 2 * register_wall : 0;

// Clearance left over the drive disc once the ring is placed, per side.
function register_disc_gap() = hub_register_od() > 0
    ? (hub_register_id() - drive_disc_diameter) / 2 : 0;

// ---- solid body of the hub -------------------------------------------
// The ring between recess_r and hub_r is filled all the way down to the
// build plate. That removes the only awkward overhang of the original
// design and gives the hub a wide first layer.
// Radial outline of the hub, as an explicit point list so it can be both
// revolved and shelled. ro is where it stops radially, zf is its floor:
// the wheel passes hub_outer_r() and 0, the shell test passes its own.
function hub_outline(ro, zf) =
    hub_style() == "solid"
    ? [[hub_bore_r(), zf], [ro, zf], [ro, wheel_width], [hub_bore_r(), wheel_width]]
    : concat(
        [[hub_bore_r(),   max(hub_inset(), zf)],
         [hub_recess_r(), max(hub_inset(), zf)],
         [hub_recess_r(), zf],
         [ro,             zf],
         [ro,             hub_boss_top()]],
        (shroud_clearance > 0 && relief_r() < ro)
          ? [[relief_r(), hub_boss_top()],
             [relief_r(), wheel_width - shroud_clearance],
             [seat_r(),   wheel_width - shroud_clearance],
             [seat_r(),   wheel_width]]
          : [],
        [[hub_bore_r(), hub_plate_bot()]]
      );

module hub_body() {
    rotate_extrude() polygon(hub_outline(hub_outer_r(), 0));
}

// Annular wall on the inner face. Vertical, so it costs nothing to print.
module hub_register() {
    if (hub_register_od() > 0) {
        assert(register_disc_gap() > 0.05,
            str("The register ring does not clear the drive disc. Its bore is ",
                hub_register_id(), " against a disc of ", drive_disc_diameter,
                ". Thin register_wall, or check drive_lip_wall."));
        echo(str("register ring: ", hub_register_id(), " bore, ",
                 hub_register_od(), " outside, groove is ", groove_width(),
                 " wide, ", register_disc_gap(), " left over the disc"));
        rotate_extrude()
            polygon([
                [hub_register_id() / 2, hub_plate_bot() - weld],
                [hub_register_od() / 2, hub_plate_bot() - weld],
                [hub_register_od() / 2, wheel_width],
                [hub_register_id() / 2, wheel_width]
            ]);
    }
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
