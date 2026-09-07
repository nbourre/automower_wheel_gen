// =====================================================================
//  CORE STRUCTURE
//  Skin on the plate side, radial spokes, rim, and the four flats that
//  bring an oversized wheel back inside the build plate.
// =====================================================================

// Half width of the truncation square. Equal to the tip radius when the
// wheel already fits, in which case nothing is cut.
function flat_radius() = min((bed_size - 2 * bed_margin) / 2, tip_r());
function is_truncated() = flat_radius() < tip_r() - 0.001;

// Top of a spoke where it meets the hub, and where it meets the rim.
function spoke_z_in()  = min(hub_plate_bot(), wheel_width);
function spoke_z_out() = wheel_width;

module face_skin() {
    rotate_extrude()
        polygon([
            [hub_outer_r() - weld, 0],
            [rim_bore_r() + weld,  0],
            [rim_bore_r() + weld,  skin_thickness],
            [hub_outer_r() - weld, skin_thickness]
        ]);
}

module rim() {
    rotate_extrude()
        polygon([
            [rim_bore_r(), 0],
            [rim_r(),      0],
            [rim_r(),      wheel_width],
            [rim_bore_r(), wheel_width]
        ]);
}

// One spoke: a vertical plate whose top edge rises from the hub to the
// rim. Every face is vertical or upward facing.
module spoke() {
    rotate([90, 0, 0])
        linear_extrude(height = spoke_thickness, center = true)
            polygon([
                [hub_outer_r() - weld, 0],
                [rim_bore_r() + weld,  0],
                [rim_bore_r() + weld,  spoke_z_out()],
                [hub_outer_r(),        spoke_z_in()],
                [hub_outer_r() - weld, spoke_z_in()]
            ]);
}

module spokes() {
    for (i = [0 : spoke_count - 1])
        rotate([0, 0, i * 360 / spoke_count]) spoke();
}

// Everything inside the rim. Kept separate from the tread so the two
// piece build never has to run a boolean against 16 twisted lugs.
module wheel_inner() {
    hub_body();
    face_skin();
    spokes();
}

// The whole wheel before it is bored, truncated or split.
module wheel_solid() {
    wheel_inner();
    rim();
    tread();
}

module build_plate_box() {
    s = is_truncated() ? 2 * flat_radius() : 4 * tip_r();
    translate([0, 0, wheel_width / 2])
        cube([s, s, wheel_width + 4], center = true);
}

// Four flats can only ever trim the lugs. If the plate is so small that
// they would bite into the rim, the wheel simply does not fit and the
// user needs to hear that rather than get a mangled model.
module fit_guard() {
    assert(flat_radius() >= rim_r() + 1,
        str("This wheel does not fit the build plate. A ", wheel_diameter,
            " mm wheel needs a plate of at least ", ceil(rim_diameter + 2 + 2 * bed_margin),
            " mm. Reduce wheel_diameter, or raise bed_size."));
}

module one_piece_wheel() {
    fit_guard();
    difference() {
        intersection() { wheel_solid(); build_plate_box(); }
        hub_bore();
    }
}
