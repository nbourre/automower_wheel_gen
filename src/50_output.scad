// =====================================================================
//  OUTPUT
//  MakerWorld's Parametric Model Maker picks up mw_plate_1(), mw_plate_2()
//  and so on as printable plates, and mw_assembly_view() as the preview.
//  Outside MakerWorld, set standalone = true to get a normal render.
// =====================================================================

/* [Hidden] */
// true  -> renders directly, for desktop OpenSCAD
// false -> nothing at top level, MakerWorld calls the plate modules
standalone = true;
// desktop only: assembly, wheel, ring, hub, key, gauge, coupon, skeleton
render_target = "assembly";

module handed(part) { }         // placeholder, kept for readability

module apply_side() {
    if (side == "left") mirror([0, 1, 0]) children();
    else                                  children();
}

module part_wheel() { apply_side() one_piece_wheel(); }
module part_ring()  { apply_side() ring_part(); }
module part_hub()   { apply_side() hub_part(); }
module part_key()   { lock_key(); }
module part_gauge() { bore_gauge(); }
module part_coupon(){ apply_side() hub_coupon(); }
module part_skeleton(){ apply_side() skeleton(); }

// ---- MakerWorld plates ----------------------------------------------
// In fit test mode the user can ask for one part at a time, so that each
// print stays short. "all" spreads the three over three plates.
module fit_part(which) {
    if      (which == "gauge")    part_gauge();
    else if (which == "coupon")   part_coupon();
    else if (which == "skeleton") part_skeleton();
}

module mw_plate_1() {
    if      (build_style == "fit_test")
        fit_part(fit_test_part == "all" ? "gauge" : fit_test_part);
    else if (build_style == "two_piece") part_ring();
    else                                 part_wheel();
}

module mw_plate_2() {
    if      (build_style == "fit_test")  { if (fit_test_part == "all") part_skeleton(); }
    else if (build_style == "two_piece") part_hub();
}

module mw_plate_3() {
    if (build_style == "fit_test" && fit_test_part == "all") part_coupon();
    if (build_style == "two_piece")
        for (i = [0 : bayonet_tabs - 1])
            translate([i * (bayonet_depth + 14), 0, 0]) part_key();
}

module mw_assembly_view() {
    if (build_style == "fit_test") {
        if (fit_test_part != "all") fit_part(fit_test_part);
        else {
            part_skeleton();
            translate([0, tip_r() + gauge_width(), 0]) part_gauge();
        }
    } else if (build_style == "two_piece") {
        part_ring();
        part_hub();
    } else {
        part_wheel();
    }
}

// ---- desktop ---------------------------------------------------------
if (standalone) {
    if      (render_target == "wheel") part_wheel();
    else if (render_target == "ring")  part_ring();
    else if (render_target == "hub")   part_hub();
    else if (render_target == "key")   part_key();
    else if (render_target == "gauge") part_gauge();
    else if (render_target == "coupon") part_coupon();
    else if (render_target == "skeleton") part_skeleton();
    else                               mw_assembly_view();
}
