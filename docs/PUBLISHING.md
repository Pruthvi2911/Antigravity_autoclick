# Push the source

This folder is initialized as a Git repository on `main`. No remote or commit identity has been configured, and nothing has been pushed.

The project repository is `https://github.com/Pruthvi2911/Antigravity_autoclick`. Run these commands from this folder for subsequent updates:

```powershell
git add .
git commit -m "Improve installation guide"
git push -u origin main
```

If Git asks for author identity, configure your own name and email before committing. This project does not supply an identity for you.

The `dist/` folder is intentionally ignored. Users install a VSIX from Releases; they do not need the individual source files.

## Publish an installable preview

1. Run `npm test` and `npm run package` in this folder.
2. Open [GitHub Releases](https://github.com/Pruthvi2911/Antigravity_autoclick/releases).
3. Choose **Draft a new release**, create tag **v0.2.0**, and title it **Option 2 v0.2.0 — Preview**.
4. Attach **`dist/antigravity-option2-0.2.0.vsix`** in the release attachments area.
5. Mark it as a **pre-release**, review the description, and publish when ready.
6. Verify that the VSIX appears under **Assets**. The automatically generated source ZIP is not the installer.

Complete the manual release checklist before calling the extension production-ready. For later versions, update the manifest version, changelog, release tag, and download filename together.

Marketplace publishing is a separate step: register your publisher, replace `local-tools`, add the real repository metadata, and validate with the target marketplace's packaging tools. Do not put marketplace tokens in this repository.
