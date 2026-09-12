// =====================================================================
//  BAYONET JOINT (only used when build_style = "two_piece")
//
//  The hub disc drops into the tread ring from the back, through four
//  entry notches, and is turned half a notch pitch. The tabs then sit in
//  a continuous annular groove and the part is trapped in both axial
//  directions: the groove floor stops it going in, the groove roof stops
//  it coming out. A separate printed key fills one notch afterwards so
//  the assembly cannot turn back.
//
//  Every roof of that groove is a 55 degree cone, so the ring still
//  prints with no support.
// =====================================================================

/* [Two piece joint] */
// Where the wheel is cut, as a fraction of the wheel radius
split_fraction = 0.75;          // [0.4:0.01:0.9]
bayonet_tabs = 4;               // [2:1:8]
// Angular width of one tab, in degrees
bayonet_tab_span = 25;          // [8:1:60]
// How far a tab sticks out past the seam (mm)
bayonet_depth = 3;              // [1.5:0.1:8]
// Height of the groove at the seam (mm)
bayonet_height = 8;             // [3:0.5:20]
// Distance from the back face of the wheel to the top of the groove (mm)
bayonet_inset = 4;              // [1:0.5:15]

/* [Hidden] */
ramp_angle = 55;                // roof slope, must stay above 45

function joint_r()   = max(hub_outer_r() + 8,
                       min(rim_bore_r() - 8, split_fraction * tip_r()));
function bay_z_hi()  = wheel_width - bayonet_inset;
function bay_z_lo()  = bay_z_hi() - bayonet_height;
function bay_drop()  = bayonet_depth * tan(ramp_angle);
function bay_twist() = 360 / bayonet_tabs / 2;
// angular clearance equivalent to fit_clearance at the seam
function ang_cl()    = fit_clearance / joint_r() * 180 / PI;

// 2D section of the groove, x = radius, y = height. shrink > 0 gives the
// male version, so both halves come from a single shape.
//
// Both the roof AND the floor are 55 degree cones falling away from the
// seam. The roof has to be, or the ring needs support. The floor has to
// be, or the underside of every tab is a bare ledge. The bonus is that
// the tab then seats on a cone, which centres the two halves.
module bay_section(shrink) {
    jr = joint_r(); d = bayonet_depth; k = (d + 2) * tan(ramp_angle);
    offset(delta = -shrink)
        polygon([
            [jr + d,  bay_z_lo()],
            [jr + d,  bay_z_hi() - bay_drop()],
            [jr - 2,  bay_z_hi() - bay_drop() + k],
            [jr - 2,  bay_z_lo() + k]
        ]);
}

// The vertical channel a tab travels down, same conical floor.
module notch_section(shrink) {
    jr = joint_r(); d = bayonet_depth; k = (d + 2) * tan(ramp_angle);
    offset(delta = -shrink)
        polygon([
            [jr + d,  bay_z_lo()],
            [jr + d,  wheel_width + 1],
            [jr - 2,  wheel_width + 1],
            [jr - 2,  bay_z_lo() + k]
        ]);
}

module bay_groove() { rotate_extrude() bay_section(0); }

module bay_tabs() {
    span = bayonet_tab_span - 2 * ang_cl();
    for (i = [0 : bayonet_tabs - 1])
        rotate([0, 0, i * 360 / bayonet_tabs + bay_twist() - span / 2])
            rotate_extrude(angle = span) bay_section(fit_clearance);
}

// Vertical channels that let the tabs in, cut from the back face down to
// the groove floor.
module bay_notches() {
    span = bayonet_tab_span + 2 * ang_cl();
    for (i = [0 : bayonet_tabs - 1])
        rotate([0, 0, i * 360 / bayonet_tabs - span / 2])
            rotate_extrude(angle = span) notch_section(0);
}

// Cylindrical wall on the hub half. Without it the tabs would only be
// attached where a spoke happens to pass underneath.
module hub_collar() {
    jr = joint_r() - fit_clearance;
    rotate_extrude()
        polygon([
            [jr - 3.5, 0],
            [jr,       0],
            [jr,       bay_z_hi() + 2],
            [jr - 3.5, bay_z_hi() + 2]
        ]);
}

// ---- the two halves --------------------------------------------------

module hub_part() {
    jr = joint_r();
    fit_guard();
    difference() {
        intersection() {
        union() {
            intersection() {
                wheel_inner();
                cylinder(r = jr - fit_clearance, h = wheel_width);
            }
            hub_collar();
            bay_tabs();
        }
        build_plate_box();
        }
        shroud_relief();
        hub_bore();
    }
}

module ring_part() {
    jr = joint_r();
    fit_guard();
    difference() {
        intersection() {
            union() {
                // only the skin and the spokes need cutting; the rim and
                // the tread are entirely outside the seam already
                difference() {
                    union() { face_skin(); spokes(); }
                    translate([0, 0, -1])
                        cylinder(r = jr, h = wheel_width + 2);
                }
                rim();
                tread();
                // collar that carries the groove
                rotate_extrude()
                    polygon([
                        [jr,                     0],
                        [jr + bayonet_depth + 3, 0],
                        [jr + bayonet_depth + 3, bay_z_hi() + 2],
                        [jr,                     bay_z_hi() + 2]
                    ]);
            }
            build_plate_box();
        }
        bay_groove();
        bay_notches();
    }
}

// ---- the printed locking key ----------------------------------------
// Generated head-down so it prints flat on the plate with no overhang.
module lock_key() {
    jr = joint_r(); d = bayonet_depth;
    span = bayonet_tab_span - 2 * ang_cl();
    head = 2.4;
    rotate([180, 0, 0]) translate([0, 0, -wheel_width - head])
        rotate([0, 0, -span / 2]) {
            // stem, fills the notch
            intersection() {
                rotate_extrude(angle = span) notch_section(fit_clearance);
                cylinder(r = jr + d + 20, h = wheel_width);
            }
            // head, bridges the seam and gives something to pull on
            rotate([0, 0, -span * 0.3]) rotate_extrude(angle = span * 1.6)
                polygon([
                    [jr - 6,     wheel_width],
                    [jr + d + 3, wheel_width],
                    [jr + d + 3, wheel_width + head],
                    [jr - 6,     wheel_width + head]
                ]);
        }
}
