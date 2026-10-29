<div align="center">

# BrenOS

### FLOW · FOCUS · FURTHER

**A beautifully cohesive Windows 11 experience — designed by Brendigo.**

Original Nexus visual identity · Premium slate-and-cyan palette · Scalable backgrounds · Modular and reversible.

</div>

---

## The experience

**BrenOS** is an original visual personalization layer for Windows 11, with a restrained premium-dark look that preserves readability. Nexus is an abstract orbital symbol, **not a letter B**. This repository contains the artwork sources, build pipeline, practical Windows theme scripts, and a BrenOS Control Center.

BrenOS is **not a new operating system, modified Windows ISO or complete replacement for the Windows shell**. It does not patch signed binaries, Windows Explorer, UAC, boot firmware or system security. A pixel-matched native shell requires additional dedicated development; concept visuals are not proof that every native Windows screen has been replaced.

## Highlights

- **50 original pictograms** — editable SVG sources, generated PNG and multi-resolution Windows ICO files.
- **Responsive wallpaper pack** — three modes (Flow, Dawn, Midnight), each generated for 1920×1080, 2560×1440, 3840×2160 and 3440×1440, plus an independent lock-screen artwork file.
- **15 custom cursor resources** and **5 original audio earcons** included as optional resources.
- **BrenOS Control Center** — a responsive Windows Presentation Foundation (WPF) interface, themed in slate and cyan, with dynamic wallpaper choices and restore controls.
- **Safe Cleanup** — opt-in reduced recommendation/suggestion clutter; does not remove any Windows app, DLL, driver or security feature.
- **Reversible install** — backs up your current-user Windows appearance values before applying BrenOS.
- **Open source** — built and published via GitHub Actions, with SHA256 checksum.

## Download and install

**1.** Open **[Releases](https://github.com/bren-wp/BrenOS/releases)** and download **BrenOS-1.0-Windows11.zip** once the release workflow succeeds.

**2.** Extract it to a folder on your computer (do not run it from inside the ZIP).

**3.** Run `PREVIEW.cmd` to check the planned changes, then `INSTALL.cmd`.

**4.** Use the **BrenOS Control Center** desktop shortcut to switch wallpaper variants.

**5.** Optionally run `SAFE-CLEANUP.cmd`; preview and explicit confirmation come first.

**6.** To undo the appearance, run `RESTORE.cmd`. To separately undo Safe Cleanup, run `RESTORE-CLEANUP.cmd`.

No Administrator access is needed for the standard branding workflow. There is no need to disable Defender, Windows Update, Secure Boot or UAC. Always test in a Windows 11 VM before installing on your primary computer.

## Build from source

Requires Python 3.12+, Pillow and CairoSVG.

```bash
python -m pip install -r tools/requirements.txt
python tools/build_assets.py
python tools/test_assets.py
```

Generated output is intentionally not duplicated as large binary blobs in source Git history. **The release ZIP includes the built assets**. The editable logo, wallpaper and 50 icon masters stay in `assets/source/`.

## Compatibility

Designed for Windows 11, at 100–250% scaling. Asset sizes include Full HD, QHD, 4K and ultrawide. The Control Center uses scrollable and wrapping WPF layout so smaller windows and high DPI don't overlap. True pixel-level consistency must be verified with screenshot regression tests on real Windows 11 builds, monitor orientations and multi-monitor configurations; automation currently checks image sizes, file integrity and PowerShell syntax only.

## AtlasOS — optional

AtlasOS is an independent open-source Windows modification project, and **not included** in BrenOS. Its official instructions currently require a clean Windows installation and another reinstall to remove Atlas. The branding installer works without Atlas. See **[AtlasOS integration information](docs/ATLASOS.md)**.

## Documentation

[Compatibility & safety boundary](docs/SCOPE.md) · [Safe Cleanup](docs/SAFE-CLEANUP.md) · [AtlasOS](docs/ATLASOS.md) · [Release notes](docs/RELEASE_NOTES.md)

---

**Brand & artwork:** Brendigo · **BrenOS is independent of Microsoft and AtlasOS.** Windows is a registered trademark of Microsoft Corporation. MIT license for this repository's source files. Windows itself is not redistributed.
