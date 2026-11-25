#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Compile the scaling-only Thumb-2 segment and generate an HMG-API memory recipe.

All library targets and the verify digest are from the pinned Ultra-Lite recipe.
No stock library is distributed. Runtime Java also checks its complete MD5.
Requires clang, ld.lld, pyelftools. Outputs a generated recipe, not a stock binary.
"""
import os, subprocess, sys
from pathlib import Path
from elftools.elf.elffile import ELFFile

ROOT=Path(__file__).resolve().parents[1]
BASE=0x30000
TARGETS=[0x91fd,0x9c25,0x1fb20,0x1fb1c,0x1fb24,0x60e4,0x60f0,
         0x5c4c,0x5d18,0x69fc,0x6120,0x5ea4,0x60d8,0x6114,
         0x5d3c,0x5eb0,0x5e98,0x5d00,0x5d24]
def run(*args):
    subprocess.run([str(x) for x in args],check=True)

def main():
    out=Path(sys.argv[1]) if len(sys.argv)>1 else ROOT/"build/native"
    out.mkdir(parents=True,exist_ok=True)
    clang=os.environ.get("CLANG","clang")
    lld=os.environ.get("LLD","ld.lld")
    arm=["--target=armv7a-linux-androideabi","-mthumb","-march=armv7-a",
         "-mfloat-abi=soft","-Os","-fPIC","-ffreestanding","-fno-builtin",
         "-fno-stack-protector","-fno-unwind-tables","-fno-asynchronous-unwind-tables",
         "-fno-jump-tables","-fvisibility=hidden","-fno-common","-Wall","-Wextra","-Werror"]
    for source,obj in [("entry.S","entry.o"),("scaling.c","scaling.o")]:
        run(clang,*arm,"-c",ROOT/"native"/source,"-o",out/obj)
    script=out/"segment.ld"
    script.write_text("ENTRY(pps_stub_info)\nSECTIONS { . = 0x30000; .seg : { *(.text.entry) *(.text .text.*) *(.rodata .rodata.*) } /DISCARD/ : { *(.ARM.exidx*) *(.ARM.attributes) *(.comment) *(.note*) } }\n")
    run(lld,"-static","--no-dynamic-linker","-T",script,"-o",out/"segment.elf",out/"entry.o",out/"scaling.o")
    with (out/"segment.elf").open("rb") as f:
        elf=ELFFile(f)
        if [s.name for s in elf.iter_sections() if s["sh_flags"]&2]!=[".seg"]:
            raise RuntimeError("unexpected allocated sections")
        if any(s.name.startswith(".rel") for s in elf.iter_sections()):
            raise RuntimeError("unexpected relocations")
        symbols={s.name:s for s in elf.get_section_by_name(".symtab").iter_symbols() if s.name}
        if any(s["st_shndx"]=="SHN_UNDEF" for s in symbols.values()):
            raise RuntimeError("undefined symbols")
        segment=elf.get_section_by_name(".seg")
        if segment["sh_addr"]!=BASE: raise RuntimeError("wrong base")
        code=segment.data()
        anchor=symbols["pps_table"]["st_value"]-BASE
        entry=(symbols["pps_stub_info"]["st_value"]&~1)-BASE
        if anchor<0 or anchor+4*len(TARGETS)>len(code) or code[anchor:anchor+4*len(TARGETS)]!=bytes(4*len(TARGETS)):
            raise RuntimeError("invalid relocation table")
        if entry<0 or entry>=len(code): raise RuntimeError("invalid branch target")
    lines=["# Scaling-only recipe; stock libCarPlayCore.so d3a47296437df56fb1ffc7ac3dfca4cb",
           "id phone-projection-scaling-cp","file /system/lib/libCarPlayCore.so",
           "verify 0x9c18 20 fe021bcb7daffe420caf5673cb93e85f -",
           f"segment {BASE:#x} {code.hex()}"]
    lines += [f"rel32 {anchor+4*i:#x} {anchor:#x} {target:#x}" for i,target in enumerate(TARGETS)]
    lines += [f"branch 0x9c20 {entry:#x}"]
    (out/"carplay-scaling.recipe").write_text("\n".join(lines)+"\n")
    print(out/"carplay-scaling.recipe")

if __name__=="__main__": main()
