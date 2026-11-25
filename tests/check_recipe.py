"""Check the generated native recipe is restricted to the original info branch."""
import sys
from pathlib import Path
rows = [s.split() for s in Path(sys.argv[1]).read_text().splitlines() if s and not s.startswith("#")]
assert [r for r in rows if r[0] == "verify"] == [["verify", "0x9c18", "20", "fe021bcb7daffe420caf5673cb93e85f", "-"]]
assert [r for r in rows if r[0] == "file"] == [["file", "/system/lib/libCarPlayCore.so"]]
branches = [r for r in rows if r[0] == "branch"]
assert len(branches) == 1 and int(branches[0][1], 0) == 0x9c20
assert not any(r[0] == "patch" for r in rows)
segments = [r for r in rows if r[0] == "segment"]
assert len(segments) == 1
data = bytes.fromhex(segments[0][2])
assert 0 <= int(branches[0][2], 0) < len(data)
rel = [r for r in rows if r[0] == "rel32"]
assert len(rel) == 19
for r in rel:
    off, anchor, target = map(lambda x: int(x, 0), r[1:])
    assert 0 <= off <= len(data)-4 and 0 <= anchor < len(data) and target > 0
    assert data[off:off+4] == bytes(4)
print("Native recipe structural checks passed")
