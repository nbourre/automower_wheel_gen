#!/usr/bin/env python3
"""Geometry checks on a rendered part."""
import sys, numpy as np, trimesh

def report(path, label, hub_r=None):
    m = trimesh.load(path)
    v = m.vertices; r = np.linalg.norm(v[:, :2], axis=1)
    n = m.face_normals; c = m.triangles_center; a = m.area_faces
    down = n[:, 2] < -1e-4
    onbed = np.isclose(c[:, 2], c[:, 2].min(), atol=1e-4)
    ang = np.degrees(np.arcsin(np.clip(-n[:, 2], 0, 1)))
    rc = np.linalg.norm(c[:, :2], axis=1)
    # 45 degree chamfers are deliberate and print fine, so the alarm sits
    # just above them at 46.5.
    bad = down & ~onbed & (ang > 46.5) & (a > 1e-6)
    out_hub = bad if hub_r is None else bad & (rc > hub_r)
    bb = m.bounds[1] - m.bounds[0]
    print(f"{label:6s} watertight={m.is_watertight}  bbox={np.round(bb,2)}  "
          f"vol={m.volume/1000:7.1f}cm3  r=[{r.min():.2f},{r.max():.2f}]")
    print(f"       overhang>45 outside hub: {a[out_hub].sum():8.2f} mm2   "
          f"(hub recess: {a[bad & ~out_hub].sum():.1f} mm2)")
    return m

if __name__ == "__main__":
    report(sys.argv[1], sys.argv[2], float(sys.argv[3]) if len(sys.argv) > 3 else None)
