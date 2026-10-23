"""
Minimal stand-in for the parts of gdsfactory that rect2gds.py uses
(Component.add_polygon / add_label / write_gds), writing plain GDSII.
Only for checking an ACT layout.conf when gdsfactory is not installed.
Database unit = 1nm; rect2gds passes coordinates in um.
"""
import struct


class Component:
    def __init__(self, name):
        self.name = name
        self.polys = []
        self.labels = []

    def add_polygon(self, pts, layer):
        self.polys.append((pts, layer))

    def add_label(self, text, position, layer):
        self.labels.append((text, position, layer))

    def write_gds(self, path):
        def rec(rtype, dtype, data=b""):
            return struct.pack(">HBB", 4 + len(data), rtype, dtype) + data

        def i2(*v):
            return struct.pack(">%dh" % len(v), *v)

        def i4(*v):
            return struct.pack(">%di" % len(v), *v)

        def real8(x):
            # GDS excess-64 real
            if x == 0:
                return b"\0" * 8
            sign = 0x80 if x < 0 else 0
            x = abs(x)
            e = 0
            while x >= 1:
                x /= 16.0
                e += 1
            while x < 1.0 / 16:
                x *= 16.0
                e -= 1
            m = int(round(x * (1 << 56)))
            return bytes([sign | (e + 64)]) + m.to_bytes(7, "big")

        def s(text):
            b = text.encode("ascii", "replace")
            return b + (b"\0" if len(b) % 2 else b"")

        db = lambda v: int(round(v * 1000))
        out = rec(0, 2, i2(600))
        out += rec(1, 2, i2(*([2025, 1, 1, 0, 0, 0] * 2)))
        out += rec(2, 6, s("LIB"))
        out += rec(3, 5, real8(1e-3) + real8(1e-9))
        out += rec(5, 2, i2(*([2025, 1, 1, 0, 0, 0] * 2)))
        out += rec(6, 6, s(self.name))
        for pts, (maj, mnr) in self.polys:
            pts = list(pts) + [pts[0]]
            out += rec(8, 0) + rec(0x0D, 2, i2(maj)) + rec(0x0E, 2, i2(mnr))
            xy = []
            for x, y in pts:
                xy += [db(x), db(y)]
            out += rec(0x10, 3, i4(*xy)) + rec(0x11, 0)
        for text, (x, y), (maj, mnr) in self.labels:
            out += rec(0x0C, 0) + rec(0x0D, 2, i2(maj)) + rec(0x16, 2, i2(mnr))
            out += rec(0x17, 2, i2(0)) + rec(0x10, 3, i4(db(x), db(y)))
            out += rec(0x19, 6, s(text)) + rec(0x11, 0)
        out += rec(7, 0) + rec(4, 0)
        open(path, "wb").write(out)
