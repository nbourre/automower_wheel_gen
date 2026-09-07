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
// desktop only: assembly, wheel, ring, hub, key, gauge, coupon
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

// ---- MakerWorld plates ----------------------------------------------
module mw_plate_1() {
    if      (build_style == "fit_test")  part_gauge();
    else if (build_style == "two_piece") part_ring();
    else                                 part_wheel();
}

module mw_plate_2() {
    if      (build_style == "fit_test")  part_coupon();
    else if (build_style == "two_piece") part_hub();
}

module mw_plate_3() {
    if (build_style == "two_piece")
        for (i = [0 : bayonet_tabs - 1])
            translate([i * (bayonet_depth + 14), 0, 0]) part_key();
}

module mw_assembly_view() {
    if (build_style == "fit_test") {
        part_gauge();
        translate([0, gauge_width() + hub_outer_r() + coupon_margin + 10, 0])
            part_coupon();
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
    else                               mw_assembly_view();
}
