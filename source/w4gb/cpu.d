module w4gb.cpu;

import std.bitmanip;

// https://rylev.github.io/DMG-01/public/book/cpu/registers.html
struct Registers {
  union {
    ushort af;
    struct {
      ubyte f, a;
    }
  }

  union {
    ushort bc;
    struct {
      ubyte c, b;
    }
  }

  union {
    ushort de;
    struct {
      ubyte e, d;
    }
  }

  union {
    ushort hl;
    struct {
      ubyte l, h;
    }
  }
}

@nogc nothrow pure @safe unittest {
  Registers reg;
  reg.af = 2;
  assert(reg.a == 0, "should not carry over.");
  assert(reg.f == 2, "2 fits in one 8-bit register.");
  reg.af = ubyte.max + 1;
  assert(reg.a == 1, "should carry over.");
  assert(reg.f == 0, "max + 1 does not fit in one register.");

  // Test with bitmasks.
  foreach (ushort af; [0, 1, ubyte.max - 1, ubyte.max, ubyte.max + 1, ushort.max]) {
    assert(reg.a == (reg.af & 0xFF00) >> 8);
    assert(reg.f == (reg.af & 0xFF));
  }
  foreach (ubyte a; [0, 1, ubyte.max - 1, ubyte.max]) {
    foreach (ubyte f; [0, 1, ubyte.max - 1, ubyte.max]) {
      reg.a = a;
      reg.f = f;
      assert(reg.af == ((cast(ushort) a << 8) | cast(ushort) f));
    }
  }
}

struct Flags {
  union {
    ubyte asUbyte;
    mixin(bitfields!(
        ubyte, "_", 4,
        bool, "carry", 1,
        bool, "half_carry", 1,
        bool, "subtract", 1,
        bool, "zero", 1));
  }
}

unittest {
  assert(Flags(0b11110000)._ == 0);
  assert(Flags(0b11110000).zero);
  assert(!Flags(0b01110000).zero);
  assert(Flags(0b11110000).carry);
  assert(!Flags(0b11100000).carry);
  assert(Flags(0b11110000).half_carry);
  assert(!Flags(0b11010000).half_carry);
  assert(Flags(0b11110000).subtract);
  assert(!Flags(0b10110000).subtract);

  Flags f;
  f.carry = true;
  f.zero = true;
  assert(f.asUbyte == 0b10010000);
}
