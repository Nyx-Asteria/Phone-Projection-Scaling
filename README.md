# Phone Projection Scaling

Independent CarPlay and Android Auto interface scaling for Hyundai and Kia Gen5W head units running [HMG-API](https://github.com/Open-HMG/HMG-API).

> **Development status:** Pre-release source; not yet ready for installation. CarPlay native patch isolation and in-car validation are pending.

## Features

- Independent Apple CarPlay and Android Auto scaling.
- 50–100% in 5% increments; 100% by default.
- Native HMG-API single-choice settings, no text entry.
- Android Auto density relative to the original receiver configuration.
- No changes to driving restrictions, wireless pairing, audio or navigation guidance.

## Screenshots

Vehicle screenshots will be added following validation. Planned comparisons: 50%, 75% and 100% for each projection system.

## Compatibility

| Platform | Firmware | Status |
| --- | --- | --- |
| Kia K5 (DL322 US, Gen5W_M) | 260507 | Development target; standalone mod untested |
| Other Gen5W vehicles | — | Not yet verified |

## Settings

Open the mod settings in HMG-API, select each scale, apply and restart the head unit while parked. Reconnect the phone. 100% retains the original receiver values. Do not combine with another mod that changes projection density or the same CarPlay display hook.

## Development

The original CarPlay scaling experiment is documented in [this Ultra-Lite commit](https://github.com/Nyx-Asteria/carplay-ultra-lite-gen5w/commit/4a4ffa85fb28141f3d8ffbf61e8e3e0241885b29). Its Java and native size handling need to be isolated before standalone CarPlay support is enabled. Android Auto uses HMG-API's mapped `gpm.video_sink.nearest` hook.

## Credits

- [HMG-API](https://github.com/Open-HMG/HMG-API)
- [CarPlay Ultra-Lite](https://github.com/Nyx-Asteria/carplay-ultra-lite-gen5w) and [LIVI](https://github.com/f-io/LIVI)
- [Phone Projection TBT](https://github.com/ch0iiih/HMG_Phone_Projection_TBT) for the settings UI reference.

Unofficial project; not affiliated with Apple, Google, Hyundai or Kia.
