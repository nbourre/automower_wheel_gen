// =====================================================================
//  TREAD LIBRARY
//  Every lug is a vertical extrusion, or a vertical extrusion that is
//  twisted about the wheel axis. Twisting only shifts each layer
//  tangentially with respect to the one below, so a chevron is just a
//  leaning wall: self-supporting as long as the arms stay under 45 deg
//  from the wheel axis. tread_max_lean() reports the actual figure.
// =====================================================================

function tip_r()     = wheel_diameter / 2;
function rim_r()     = rim_diameter / 2;
function rim_bore_r()= rim_r() - rim_thickness;
function lug_height()= tip_r() - rim_r();

// angle of a chevron arm away from the wheel axis, in degrees
function tread_max_lean() =
    atan(tip_r() * chevron_sweep * PI / 180 / (wheel_width / 2));

// 2D section of one lug, x = radius, y = tangential
module lug_section(base, tip, r_ext) {
    xs = sqrt(r_ext * r_ext - tip * tip / 4);   // corners land on r_ext
    polygon([
        [rim_bore_r() - 1,  base / 2],
        [rim_r(),           base / 2],
        [xs,                tip / 2],
        [xs,               -tip / 2],
        [rim_r(),          -base / 2],
        [rim_bore_r() - 1, -base / 2]
    ]);
}

// V shaped lug, apex at mid width
module lug_chevron(base, tip, r_ext, sweep) {
    h = wheel_width / 2;
    rotate([0, 0, sweep])
        linear_extrude(height = h, twist = sweep, slices = 24)
            lug_section(base, tip, r_ext);
    translate([0, 0, h])
        linear_extrude(height = h, twist = -sweep, slices = 24)
            lug_section(base, tip, r_ext);
}

// straight block, no direction
module lug_block(base, tip, r_ext) {
    linear_extrude(height = wheel_width) lug_section(base, tip, r_ext);
}

// original style triangular spike
module lug_spike() {
    a = asin(lug_base_width / 2 / rim_r());
    x = rim_r() * cos(a);
    y = lug_base_width / 2;
    linear_extrude(height = wheel_width)
        polygon([
            [rim_bore_r() - 1,  y], [x,  y], [tip_r(), 0],
            [x, -y], [rim_bore_r() - 1, -y]
        ]);
}

// Phase that puts a groove, not a lug, on each of the four flats.
function tread_phase() = 180 / lug_count;

function chamfer() = min(lug_chamfer, wheel_width / 3, lug_height() * 0.6);

// A disc of radius r_ext with a 45 degree chamfer at each end. Intersecting
// a group of lugs with it takes the square corner off where the tread meets
// the sides of the wheel, on every lug at once and for every tread type.
// Only material out past r_ext - chamfer is touched, so the rim below is
// left alone. The lower chamfer faces down at 45 degrees, which is the
// standard self-supporting limit, and it is only a millimetre tall.
module tread_envelope(r_ext) {
    c = chamfer();
    rotate_extrude()
        polygon([
            [0,          0],
            [r_ext - c,  0],
            [r_ext,      c],
            [r_ext,      wheel_width - c],
            [r_ext - c,  wheel_width],
            [0,          wheel_width]
        ]);
}

module chamfered(r_ext) {
    if (chamfer() > 0.01) intersection() { children(); tread_envelope(r_ext); }
    else                  children();
}

module tread() {
    step = 360 / lug_count;
    chamfered(tip_r())
        for (i = [0 : lug_count - 1])
            rotate([0, 0, tread_phase() + i * step]) {
                if      (tread_type == "spikes") lug_spike();
                else if (tread_type == "blocks") lug_block(lug_base_width, lug_tip_width, tip_r());
                else lug_chevron(lug_base_width, lug_tip_width, tip_r(), chevron_sweep);
            }
    // Half height lugs in between. They stop below the truncation radius,
    // so the four flats never touch them.
    if (tread_type == "chevron_mixed") {
        r2 = min(rim_r() + lug_height() * 0.5, flat_radius() - 0.5);
        chamfered(r2)
            for (i = [0 : lug_count - 1])
                rotate([0, 0, tread_phase() + (i + 0.5) * step])
                    lug_chevron(lug_base_width * 0.67, lug_base_width * 0.4,
                                r2, chevron_sweep);
    }
}
