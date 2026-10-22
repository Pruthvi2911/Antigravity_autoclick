# Contributing

Run `npm test` and `npm run package` before submitting a change. Changes to approval matching must include both accepted and rejected examples, especially persistent approval options and unrelated dialogs.

For a bug report include Windows and Antigravity versions, extension version, whether the IDE is in front, and redacted Output > Antigravity Option 2 diagnostics. Do not include API keys, private command arguments, environment files, or private chat content.

Never add a fallback that selects a numbered option without validating the surrounding approval form. Keep command text out of logs. The current implementation deliberately stops when controls are ambiguous or cannot be selected through accessibility.

CI action references: [checkout](https://github.com/actions/checkout), [setup-node](https://github.com/actions/setup-node/releases), [upload-artifact](https://github.com/actions/upload-artifact/releases).
