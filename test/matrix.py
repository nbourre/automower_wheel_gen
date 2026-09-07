#!/usr/bin/env python3
"""Render a matrix of configurations and assert the invariants."""
import subprocess, tempfile, os, sys, numpy as np, trimesh
from concurrent.futures import ThreadPoolExecutor

SCAD = os.path.join(os.path.dirname(__file__), "..", "dist", "mower_wheel.scad")

def render(target, **kw):
    out = tempfile.mktemp(suffix=".stl")
    cmd = ["openscad", "-o", out, "-D", f'render_target="{target}"', "-D", "$fn=90"]
    for k, v in kw.items():
        cmd += ["-D", f'{k}="{v}"' if isinstance(v, str) else f"{k}={v}"]
    cmd.append(SCAD)
    r = subprocess.run(cmd, capture_output=True, text=True)
    if "ERROR" in r.stderr:
        return None, r.stderr
    return trimesh.load(out), None

def audit(m, hub_r=40.0):
    n, c, a = m.face_normals, m.triangles_center, m.area_faces
    ang = np.degrees(np.arcsin(np.clip(-n[:, 2], 0, 1)))
    rc = np.linalg.norm(c[:, :2], axis=1)
    bad = (n[:, 2] < -1e-4) & ~np.isclose(c[:, 2], c[:, 2].min(), atol=1e-4) \
          & (ang > 46.5) & (a > 1e-6) & (rc > hub_r)
    bb = m.bounds[1] - m.bounds[0]
    return dict(wt=m.is_watertight, bodies=m.body_count, over=a[bad].sum(),
                bb=bb, vol=m.volume / 1000)

CASES = [("tread_type", t) for t in ["spikes", "chevron", "chevron_mixed", "blocks"]] + \
        [("hub_type", h) for h in ["plain_bore", "hex_bore", "splined"]]

JOBS = [(f"{k}={v}", "wheel", {k: v}, 252.01) for k, v in CASES]
for bed, style in [(180, "two_piece"), (180, "one_piece"), (300, "one_piece")]:
    for tgt in (["ring", "hub"] if style == "two_piece" else ["wheel"]):
        JOBS.append((f"bed={bed} {style} {tgt}", tgt,
                     dict(bed_size=bed, build_style=style), min(bed - 4, 400) + 0.01))

def run(job):
    label, tgt, kw, lim = job
    m, err = render(tgt, **kw)
    if m is None:
        return label, None, lim
    return label, audit(m), lim

fails = 0
print(f"{'case':34s} {'wt':>3s} {'bod':>4s} {'overhang':>9s} {'bbox XY':>9s} {'vol cm3':>8s}")
with ThreadPoolExecutor(max_workers=4) as ex:
    for label, r, lim in ex.map(run, JOBS):
        if r is None:
            print(f"{label:34s} RENDER ERROR"); fails += 1; continue
        ok = r["wt"] and r["bodies"] == 1 and r["over"] < 1.0 and max(r["bb"][:2]) <= lim
        fails += not ok
        print(f"{label:34s} {str(r['wt'])[:3]:>3s} {r['bodies']:>4d} {r['over']:>8.2f}  "
              f"{max(r['bb'][:2]):>8.1f} {r['vol']:>8.1f}  {'ok' if ok else 'FAIL'}")

print("FAILURES:", fails)
sys.exit(1 if fails else 0)
