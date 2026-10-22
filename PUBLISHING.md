# Push the source

This folder is initialized as a Git repository on `main`. No remote or commit identity has been configured, and nothing has been pushed.

Create an empty repository on your GitHub account, then run these commands from this folder. Replace YOUR-USERNAME with your account name and use your actual repository name.

```powershell
git add .
git commit -m "Prepare Option 2 extension preview"
git remote add origin https://github.com/YOUR-USERNAME/antigravity-option2.git
git push -u origin main
```

If Git asks for author identity, configure your own name and email before committing. This project does not supply an identity for you.

The `dist/` folder is intentionally ignored. Attach its VSIX to a GitHub prerelease after reviewing the manual release checklist. Do not label the release production-ready until live checks pass.

Marketplace publishing is a separate step: register your publisher, replace `local-tools`, add the real repository metadata, and validate with the target marketplace's packaging tools. Do not put marketplace tokens in this repository.
