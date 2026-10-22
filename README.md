# Antigravity Option 2

**One toggle for “allow this command in this conversation.”**

A Windows extension for Antigravity IDE that selects the conversation-scoped approval option and submits it while the IDE is in the foreground. Your ON/OFF preference survives restarts.

**Status: experimental preview (0.2.0).** Matching was checked against the actual English approval accessibility labels. Automated tests cover lifecycle and matching rules; a complete live approval sequence has not yet been verified for this release. This project is independent and is not affiliated with Google.

## Install once

1. Download the VSIX from this repository's releases, or build it below.
2. In Antigravity, open Extensions, choose **… → Install from VSIX**, and select the file.
3. Reload the IDE. Click **Option 2: OFF** in the bottom status bar to enable.
4. Click it again to stop. For diagnostics, use the command palette command **Option 2: Show Diagnostics**.

The extension starts OFF on a fresh installation. Close earlier standalone helpers and enable it in only one IDE window. When ON, it applies to matching prompts in whichever Antigravity window is in the foreground; it is not restricted to the workspace in which you enabled it.

## What it approves

Every matching terminal approval containing option **2 — Yes, and always allow … in this conversation** is approved automatically. Commands are not inspected for safety. This includes the first occurrence of each new matching command, not just commands you have already approved manually. The IDE controls the lifetime of the resulting conversation permission.

Turning OFF stops new automated approvals; it does not revoke permissions already granted in a conversation.

The helper checks the foreground process, radio-button type, English option text, option-2 accessibility ID, sibling option 1, permission target field, and Submit button in a shared container. It confirms that option 2 is selected and unchanged before submitting. Ambiguous matches and unsupported accessibility controls are skipped. It does not use fixed coordinates, inject JavaScript into Antigravity, or select the persistent option 3.

## Requirements and limits

- Windows with Windows PowerShell 5.1 and .NET UI Automation available.
- Antigravity IDE using the observed `ask-opt-…-2` approval form in English.
- A trusted workspace and a foreground Antigravity window.
- UI Automation must expose selection and invocation patterns. If those patterns change, the helper can stop working.
- Remote workspaces are not validated. The UI extension runs locally; there is no browser or web-extension version.
- ON means the helper initialized; it does not guarantee that a prompt is currently actionable. Logs report successful Submit invocations, not successful completion of the terminal command.

There are no runtime npm dependencies, network requests, or telemetry in this extension. Logs omit command text. The Windows helper executes only the bundled automation script; it invokes the IDE's approval controls rather than executing the displayed terminal command itself.

## Development

Requires Node.js 22+ and Windows PowerShell. No `npm install` step is needed.

```powershell
npm test
npm run package
```

The self-contained packaging script writes `dist/antigravity-option2-0.2.0.vsix` with an explicit file allowlist. GitHub Actions runs tests and packages a VSIX on Windows.

`controller.js` owns the status bar, persisted preference, helper lifecycle, startup handshake, and bounded output. `watcher.ps1` owns foreground UI Automation, a session-wide single-instance mutex, and extension-host liveness checks. `rules.ps1` contains the tested label matcher. A dead extension host causes its helper to exit on the next completed scan; a blocked UI Automation call can delay that exit.

## Before a public release

Complete the manual checks in [RELEASE-CHECKLIST.md](RELEASE-CHECKLIST.md). Replace `local-tools` with your registered publisher ID and add your actual GitHub repository URL to `package.json` before a marketplace submission. The supplied VSIX is intended for local installation; marketplace publication has not been validated.

See [CONTRIBUTING.md](CONTRIBUTING.md) for bug reports and [CHANGELOG.md](CHANGELOG.md) for changes.

## License

MIT. See [LICENSE](LICENSE).
