## First test build

- Independent CarPlay and Android Auto scaling, 50–100% in 5% steps.
- Stock defaults and native single-choice settings.
- Fingerprint-gated standalone CarPlay memory recipe.
- Optional Ultra-Lite K5 native hook delegation (compatible host required).

**Experimental; not vehicle-validated.** Install and test only while parked. This build uses a disposable test author key. Uninstall it before installing a build signed with another key, including the future production release.

Copy the signed ZIP (without extracting) to HMGAPI/updates on USB, install in HMG-API, apply and restart. Start at 100%, then try 80%, 75%, and 50% if readable. Test each projection independently and restore 100%. If projection fails, disable PPS and restart.

Automated build checks do not establish head-unit compatibility.
