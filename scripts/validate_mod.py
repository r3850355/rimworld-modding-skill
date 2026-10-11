"""Static checks for a RimWorld mod folder.

usage: python validate_mod.py <mod root>

Checks: every XML parses; duplicate defNames; Keyed translation keys match
between languages; DefInjected files sit in <DefType>/ subfolders (flat files
are silently ignored by the game); LoadFolders.xml and About.xml exist.
Writes plain ASCII to stdout so cp950 consoles do not crash.
"""
import os
import sys
import xml.etree.ElementTree as ET

root = sys.argv[1] if len(sys.argv) > 1 else "."
problems = []


def fail(msg):
    problems.append(msg)
    print("PROBLEM:", msg.encode("ascii", "replace").decode())


def xml_files():
    for dp, dn, fn in os.walk(root):
        dn[:] = [d for d in dn if d not in (".git", "obj", "bin")]
        for f in fn:
            if f.lower().endswith(".xml"):
                yield os.path.join(dp, f)


trees = {}
for p in xml_files():
    try:
        trees[p] = ET.parse(p).getroot()
    except ET.ParseError as e:
        fail("XML parse error in %s: %s" % (os.path.relpath(p, root), e))

print("xml files:", len(trees))

seen = {}
for p, r in trees.items():
    if os.sep + "Languages" + os.sep in p:
        continue
    for d in r.iter("defName"):
        name = (d.text or "").strip()
        if name in seen:
            fail("duplicate defName %s (%s and %s)" % (name, os.path.basename(p), seen[name]))
        else:
            seen[name] = os.path.basename(p)
print("defNames:", len(seen))

keyed = {}
for p, r in trees.items():
    parts = p.replace("\\", "/").split("/")
    if "Keyed" in parts and "Languages" in parts:
        lang = parts[parts.index("Languages") + 1]
        keyed.setdefault(lang, set()).update(c.tag for c in r)
langs = sorted(keyed)
for a in langs:
    for b in langs:
        if a != b:
            for k in sorted(keyed[a] - keyed[b]):
                fail("Keyed key %s in %s missing in %s" % (k, a, b))
print("keyed languages:", {l: len(keyed[l]) for l in langs})

for dp, dn, fn in os.walk(os.path.join(root, "Languages")):
    if os.path.basename(dp) == "DefInjected":
        for f in fn:
            if f.lower().endswith(".xml"):
                fail("flat DefInjected file ignored by the game: %s (move into a <DefType>/ folder)" % os.path.join(dp, f))

for need in ("About/About.xml", "LoadFolders.xml"):
    if not os.path.exists(os.path.join(root, need)):
        fail("missing " + need)

print("PROBLEMS:", len(problems))
sys.exit(1 if problems else 0)
