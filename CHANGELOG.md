# Changelog

## 0.2.0 — 2026-10-22

- Add a startup handshake and timeout so enabled status follows helper initialization.
- Prevent concurrent helpers across IDE windows with a Windows session mutex.
- Exit the helper when its owning extension host disappears.
- Serialize toggles, ignore stale helper events, and clean up on disposal.
- Require the expected terminal approval form and verify selection before submission.
- Reduce diagnostic noise, bound output, and omit command text from errors.
- Add approval-rule and lifecycle tests, Windows CI, and an allowlisted VSIX builder.
- Document preview status, permission scope, privacy, and manual release checks.

## 0.1.2

- Distinguish option-2 radio buttons from duplicate accessible text nodes.

## 0.1.1

- Recognize the Antigravity IDE process name and add diagnostics.

## 0.1.0

- Initial Windows helper and persistent status-bar toggle.
