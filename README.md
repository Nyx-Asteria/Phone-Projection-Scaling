<div align="center">

# Phone Projection Scaling

**More screen. Less clutter. Your choice.**

Independent Apple CarPlay and Android Auto interface scaling for Hyundai and Kia Gen5W head units.

[![HMG-API](https://img.shields.io/badge/HMG--API-1.0.2%2B-5965d8?style=flat-square)](https://github.com/Open-HMG/HMG-API)
[![Scaling](https://img.shields.io/badge/Scaling-50%25_to_100%25-208b82?style=flat-square)](#settings)
[![License](https://img.shields.io/badge/License-GPL--3.0--or--later-blue?style=flat-square)](#credits--license)
[![Status](https://img.shields.io/badge/Version-1.0.0-brightgreen?style=flat-square)](../../releases)

[Features](#features) · [Screenshots](#screenshots) · [Compatibility](#compatibility) · [Installation](#installation) · [Settings](#settings)

</div>

---

Phone Projection Scaling (PPS) gives you control over the size of your phone projection interface without changing the head unit's display resolution. Make maps, app icons and interface elements more compact, or return to the original scale at any time.

Built as a standalone [HMG-API](https://github.com/Open-HMG/HMG-API) mod, PPS does not require CarPlay Ultra-Lite or replace the stock projection applications.

> **v1.0.0:** Initial stable release, following successful owner-reported PPS testing on the Kia K5 (DL322 USA, firmware 260507) with a development Ultra-Lite K5 build. See compatibility below for the scope of validation.

## Features

- **Apple CarPlay:** proportional physical display size adjustment.
- **Android Auto:** proportional receiver DPI adjustment.
- **Independent controls:** choose a different scale for each projection system.
- **Eleven scale options:** 50–100%, in 5% increments.
- **Native HMG-API settings:** single-choice controls with no text boxes.
- **Stock by default:** both settings start at 100%.
- **Optional Ultra-Lite integration:** compatible K5 builds share native hook ownership without requiring either mod.

PPS targets interface scaling only. It does not intentionally change wireless pairing, audio, navigation guidance, driving restrictions, vehicle controls or display pixel resolution.

## Screenshots

Vehicle testing is complete for the reported configuration; real comparison screenshots will be added when available.

<!-- Replace pending cells with images from docs/images/ after validation. -->

| Projection | 100% · Stock | 75% · Compact | 50% · Minimum |
| :--- | :---: | :---: | :---: |
| Apple CarPlay | Pending | Pending | Pending |
| Android Auto | Pending | Pending | Pending |

Actual layouts depend on the phone and application. Some interface elements may reflow or have their own minimum size.

## Compatibility

| Vehicle | Region | Firmware | CarPlay | Android Auto |
| --- | --- | --- | --- | --- |
| Kia K5 (DL322, Gen5W_M) | USA | 260507 | Working with development Ultra-Lite host | Not separately documented |
| Other Hyundai / Kia Gen5W | — | — | Unverified | Unverified |

PPS operation has been confirmed by the owner on the Kia K5 listed above while running a development Ultra-Lite K5 build. Separate standalone CarPlay and Android Auto test results have not been documented; other vehicles remain unverified. Standalone CarPlay uses an exact stock library fingerprint; Android Auto uses HMG-API's mapped GPM video configuration hook.

### CarPlay Ultra-Lite

PPS and [CarPlay Ultra-Lite K5](https://github.com/Nyx-Asteria/carplay-ultra-lite-gen5w/tree/k5-compatibility) are designed to work independently or together.

| Configuration | CarPlay scaling owner |
| --- | --- |
| PPS only | PPS native recipe |
| PPS + compatible Ultra-Lite K5 | Ultra-Lite native hook, PPS settings |
| Compatible Ultra-Lite K5 only | Stock 100% |
| Neither | Stock behavior |

Compatible Ultra-Lite builds consume PPS settings through the shared native hook. Older builds do not consume PPS settings. PPS conservatively defers whenever Ultra-Lite K5 is enabled, even if all its features are off or its native preflight fails. Disable Ultra-Lite and restart to use standalone scaling in that case.

Android Auto is independent. PPS does not override an absolute DPI already managed by HMG-API. Avoid other direct density hooks. PPS operation alongside a development Ultra-Lite K5 build has been confirmed; this does not certify unrelated Ultra-Lite features.

## Installation

### Requirements

- Supported Hyundai or Kia Gen5W head unit.
- Working HMG-API (manifest minimum 1.0.2; final requirements subject to validation).
- Appropriate firmware and hook map.
- Working CarPlay or Android Auto connection.
- USB drive.

### Install

Download the appropriate signed package from [Releases](../../releases). For the bare HMG-API mod ZIP, follow these steps:

1. Download the signed update ZIP without extracting it.
2. Copy it to `HMGAPI/updates/` on your USB drive.
3. While parked, open HMG-API and select the package under **Updates**.
4. Install, apply and restart.
5. Choose your preferred scales in PPS settings, apply and restart again.
6. Reconnect your phone.

Alternatively, extract the HMG-API USB or NEMESIS USB archive to the USB root and install with the corresponding manager. The bare signed ZIP is also suitable for compatible CPUL K5 bundles.

**Upgrading from a test-signed RC:** Uninstall the old test-signed PPS package and restart before installing the permanently signed v1.0.0. Future updates signed with the same author key can install over it.

Do not install an unsigned source archive as a mod.

## Settings

Open **Phone Projection Scaling** in HMG-API. Both controls offer the same eleven values.

| Scale | Android Auto DPI example |
| ---: | ---: |
| **100% (default)** | 240 |
| 95% | 228 |
| 90% | 216 |
| 85% | 204 |
| 80% | 192 |
| 75% | 180 |
| 70% | 168 |
| 65% | 156 |
| 60% | 144 |
| 55% | 132 |
| 50% | 120 |

The DPI example assumes a stock density of 240. PPS scales the original density rather than hardcoding a vehicle-specific value. CarPlay adjusts advertised physical dimensions instead.

Start with 80–90% and choose a lower value only if the interface remains readable. Change settings while parked.

### Restore stock

Set both values to **100%**, apply and restart. Alternatively, disable or uninstall PPS and restart the head unit. Restarting also refreshes Ultra-Lite's hosted scaling configuration when present.

## Troubleshooting

| Issue | Suggested action |
| --- | --- |
| CarPlay scale unchanged | Verify firmware support, restart and check Ultra-Lite compatibility. |
| Android Auto scale unchanged | Verify the GPM hook map and check for other DPI overrides. |
| Interface too small | Increase the percentage or return to 100%. |
| Unexpected projection behavior | Disable PPS, restart and reconnect. |

When [reporting an issue](../../issues), include your vehicle, region, firmware, HMG-API and PPS versions, selected scale, projection type, wired/wireless connection and sanitized HMG-API logs. Do not share passwords, personal identifiers or private session data.

## Development

PPS uses Java hooks and a small fingerprint-checked Thumb-2 memory recipe. No stock firmware binaries are distributed.

See [development notes](docs/DEVELOPMENT.md) for implementation and native build details. See [build and signing](docs/BUILD.md) for the automated build, package formats, release procedure and permanent author identity.

## Credits & license

GPL-3.0-or-later, as declared in the mod manifest.

- [HMG-API](https://github.com/Open-HMG/HMG-API) — mod platform and projection hooks.
- [CarPlay Ultra-Lite](https://github.com/Nyx-Asteria/carplay-ultra-lite-gen5w) — original [scaling implementation](https://github.com/Nyx-Asteria/carplay-ultra-lite-gen5w/commit/4a4ffa85fb28141f3d8ffbf61e8e3e0241885b29).
- [LIVI](https://github.com/f-io/LIVI) — upstream CarPlay implementation inspiration.
- [Phone Projection TBT](https://github.com/ch0iiih/HMG_Phone_Projection_TBT) — native single-choice settings reference.

---

<div align="center">

Developed by <a href="https://github.com/Nyx-Asteria">Nyx-Asteria</a>

Unofficial project. Not affiliated with Apple, Google, Hyundai or Kia.

</div>
