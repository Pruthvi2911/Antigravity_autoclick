# Antigravity AutoClick — Option 2

**One toggle for “allow this command in this conversation.”**

### [Download the extension (.vsix)](https://github.com/Pruthvi2911/Antigravity_autoclick/raw/refs/heads/main/Antigravity-AutoClick/antigravity-option2-0.2.0.vsix)

The installable file is in **[Antigravity-AutoClick/](Antigravity-AutoClick/)**. Source code is in **[src/](src/)**; project documentation is in **[docs/](docs/)**.

A Windows extension for Antigravity IDE that selects the conversation-scoped approval option and submits it while the IDE is in the foreground. Your ON/OFF preference survives restarts.

**Status: experimental preview (0.2.0).** Matching was checked against the actual English approval accessibility labels. Automated tests cover lifecycle and matching rules; a complete live approval sequence has not yet been verified for this release. This project is independent and is not affiliated with Google.

## Install the extension

**You only need one file: `antigravity-option2-0.2.0.vsix`.** No Git, Node.js, cloning, or terminal commands are needed to install it.

1. Click **Download the extension** above, or open **Antigravity-AutoClick/** and download the `.vsix` using **Download raw file**.
2. Save **`antigravity-option2-0.2.0.vsix`**. It is also available as a release asset under [Releases](https://github.com/Pruthvi2911/Antigravity_autoclick/releases). GitHub's **Source code (zip)** download is for developers.
3. In Antigravity, open **Extensions** with **Ctrl+Shift+X**.
4. Click **… → Install from VSIX…**, then select the downloaded file.
5. Reload Antigravity if prompted.
6. Click **Option 2: OFF** in the bottom status bar. Once the helper starts, it shows **Option 2: ON**.

Keep Antigravity in front. When a supported command approval appears, the extension selects option 2 and submits it. Click the same status-bar button to turn it OFF. Your preference is remembered after restarting.

**Stuck?** Open the command palette with **Ctrl+Shift+P**, run **Option 2: Show Diagnostics**, and include the resulting log in a [bug report](https://github.com/Pruthvi2911/Antigravity_autoclick/issues). Remove private information before sharing screenshots.

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

## Build from source (developers)

Cloning this repository gives you the extension's source, not an installed extension. Requires Git, Node.js 22+, and Windows PowerShell. No `npm install` step is needed.

```powershell
git clone https://github.com/Pruthvi2911/Antigravity_autoclick.git
cd Antigravity_autoclick
npm test
npm run package
```

Then install **`dist/antigravity-option2-0.2.0.vsix`** using **Extensions → … → Install from VSIX…** in Antigravity. There is no `npm start` or standalone application to run.

The self-contained packaging script uses an explicit file allowlist. GitHub Actions runs tests and packages a VSIX on Windows.

### Repository layout

| File or folder | Purpose |
| --- | --- |
| `Antigravity-AutoClick/` | Installable VSIX; download this to use the extension |
| `package.json` | Extension metadata and build commands |
| `src/` | JavaScript extension code and Windows automation helpers |
| `docs/` | Changelog, contributor guide, publishing, and release checklist |
| `test/` | Automated tests |
| `scripts/` | Builds the installable VSIX |
| `.github/workflows/` | CI tests and package artifacts |
| `dist/` | Generated VSIX after building; excluded from Git |

`src/controller.js` owns the status bar, persisted preference, helper lifecycle, startup handshake, and bounded output. `src/watcher.ps1` owns foreground UI Automation, a session-wide single-instance mutex, and extension-host liveness checks. `src/rules.ps1` contains the tested label matcher. A dead extension host causes its helper to exit on the next completed scan; a blocked UI Automation call can delay that exit.

## Before a public release

Complete the manual checks in [RELEASE-CHECKLIST.md](docs/RELEASE-CHECKLIST.md). Replace `local-tools` with your registered publisher ID before a marketplace submission. The supplied VSIX is intended for local installation; marketplace publication has not been validated. See [PUBLISHING.md](docs/PUBLISHING.md) for uploading a GitHub release asset.

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for bug reports and [CHANGELOG.md](docs/CHANGELOG.md) for changes.

## License

MIT. See [LICENSE](LICENSE).
