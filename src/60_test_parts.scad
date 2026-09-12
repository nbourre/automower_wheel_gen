// =====================================================================
//  FIT TEST PARTS
//  Set build_style = "fit_test" and you get two small parts instead of a
//  wheel. Print those first. Between them they answer the two questions
//  that decide whether an eight hour print is wasted:
//    1. which bore clearance actually fits YOUR printer and YOUR shaft
//    2. does the hub seat properly on the mower, at the right depth
//
//  Both are built from the same modules as the wheel and print in the
//  same orientation, so the holes come out the same as they will on the
//  real part. That matters: a bore printed lying down is not the same
//  bore as one printed standing up.
// =====================================================================

/* [Fit test] */
// Which test part to output. One at a time keeps each print short: check
// the bore first, then the hub interface, then the overall diameter.
fit_test_part = "all";          // [all:All three, gauge:Bore gauge only, coupon:Hub coupon only, skeleton:Skeleton only]
// Clearances to try, added to the bore RADIUS, smallest first.
gauge_steps = [0, 0.10, 0.15, 0.20, 0.30];
// Text height on the gauge (mm). 0 removes the labels.
gauge_text = 5;                 // [0:0.5:12]
gauge_text_depth = 0.6;         // [0.2:0.1:2]
// How much of the wheel around the hub to keep on the coupon (mm)
coupon_margin = 20;             // [5:1:60]
// Skeleton: number of arms reaching out to full diameter
skeleton_arms = 3;              // [2:1:8]
// Angular width of the rim segment carried at the end of each arm (deg)
skeleton_arc = 24;              // [8:1:70]
// Where the first arm points. 45 keeps the arms away from the four flats,
// so every arm carries the full overall diameter.
skeleton_phase = 45;            // [0:1:180]
// Width of the flat strip under each arm, which is what holds it to the
// plate and stops the arm being a bare 3 mm wall
skeleton_arm_width = 14;        // [6:1:40]

/* [Hidden] */
gauge_font = "Liberation Sans"; // font

function gauge_thickness() = max(4, hub_plate_bot() - hub_inset());
function g_r()      = hub_bore_r() + max(gauge_steps);   // largest hole radius
function gauge_pitch()  = 2 * g_r() + 10;
function gauge_length() = len(gauge_steps) * gauge_pitch();
function g_top()    = g_r() + 4 + gauge_text;            // room for the header
function g_bot()    = -(g_r() + 4 + gauge_text);         // room for the labels
function gauge_width()  = g_top() - g_bot();

// ---- part 1: bore gauge ---------------------------------------------
// A flat bar with one hole per clearance, the same thickness as the real
// hub plate so the holes are as deep as they will be on the wheel. Slide
// it onto the mower shaft, keep the tightest hole that goes on without
// forcing, and put that number into bore_clearance.
module bore_gauge() {
    t = gauge_thickness();
    n = len(gauge_steps);
    difference() {
        translate([0, (g_top() + g_bot()) / 2, 0])
            linear_extrude(height = t)
                offset(r = 4) offset(delta = -4)
                    square([gauge_length(), gauge_width()], center = true);

        for (i = [0 : n - 1]) {
            x = (i - (n - 1) / 2) * gauge_pitch();
            translate([x, 0, -1])
                cylinder(r = hub_bore_r() + gauge_steps[i], h = t + 2);
            if (gauge_text > 0)
                translate([x, -(g_r() + 2 + gauge_text / 2), t - gauge_text_depth])
                    linear_extrude(height = gauge_text_depth + 1)
                        text(str(gauge_steps[i]), size = gauge_text, font = gauge_font,
                             halign = "center", valign = "center");
        }
        if (gauge_text > 0)
            translate([0, g_r() + 2 + gauge_text / 2, t - gauge_text_depth])
                linear_extrude(height = gauge_text_depth + 1)
                    text(str(hub_type, "  bore ", 2 * hub_bore_r()),
                         size = gauge_text * 0.75, font = gauge_font,
                         halign = "center", valign = "center");
    }
}

// ---- part 2: hub coupon ---------------------------------------------
// The real hub, with the wheel around it cut down to a disc. Same modules
// as the wheel, so if this seats on the mower the wheel will too.
module hub_coupon() {
    union() {
        difference() {
            intersection() {
                union() { hub_body(); face_skin(); spokes(); }
                cylinder(r = hub_outer_r() + coupon_margin, h = wheel_width);
            }
            shroud_relief();
            hub_bore();
        }
        // Stamp the clearance used, so a coupon found in a drawer in six
        // months still means something. Raised rather than engraved: an
        // engraving here would cut a notch through the spokes it crosses
        // and put a small overhang back into a part that has none.
        if (gauge_text > 0)
            translate([0, -(hub_outer_r() + coupon_margin * 0.55), skin_thickness - 0.3])
                linear_extrude(height = gauge_text_depth + 0.3)
                    text(str(bore_clearance), size = gauge_text * 0.8,
                         font = gauge_font, halign = "center", valign = "center");
    }
}


// ---- part 3: skeleton -----------------------------------------------
// The whole wheel reduced to what you actually need to test: the real hub,
// a few arms out to the real overall diameter, and a real piece of tread
// at the end of each one. Bolt it on, turn it by hand, and you find out in
// twenty minutes whether the hub seats and whether the lugs clear the
// bodywork. Every dimension comes from the same modules as the wheel, so
// nothing here is a lookalike.
module skeleton_arm() {
    spoke();
    // flat strip on the plate side, turns the arm into a T beam
    translate([0, 0, skin_thickness / 2])
        translate([(hub_outer_r() - weld + rim_bore_r() + weld) / 2, 0, 0])
            cube([rim_bore_r() + weld - hub_outer_r() + weld,
                  skeleton_arm_width, skin_thickness], center = true);
}

module skeleton_wedge(a) {
    rotate([0, 0, -a / 2])
        rotate_extrude(angle = a)
            square([tip_r() + 2, wheel_width]);
}

module skeleton() {
    step = 360 / skeleton_arms;
    difference() {
        intersection() {
            union() {
                hub_body();
                for (i = [0 : skeleton_arms - 1])
                    rotate([0, 0, skeleton_phase + i * step]) skeleton_arm();
                // one intersection for the whole tread, not one per arm
                intersection() {
                    union() { rim(); tread(); }
                    union() {
                        for (i = [0 : skeleton_arms - 1])
                            rotate([0, 0, skeleton_phase + i * step])
                                skeleton_wedge(skeleton_arc);
                    }
                }
            }
            build_plate_box();
        }
        shroud_relief();
        hub_bore();
    }
}
