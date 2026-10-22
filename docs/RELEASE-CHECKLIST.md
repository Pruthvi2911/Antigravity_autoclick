# Release checks

Automated validation is useful but does not establish compatibility with every Antigravity release. Record the exact IDE version, Windows version, and results before calling a release stable.

- [ ] Install the built VSIX in Antigravity and reload without activation errors.
- [ ] Fresh install starts OFF; one click starts the helper and reaches ON.
- [ ] On a harmless terminal approval, option 2 is selected and submitted.
- [ ] The same command runs again within that conversation without another prompt, where supported by the IDE.
- [ ] A new conversation retains its own permission boundary.
- [ ] Option 3 is never selected; unsupported or ambiguous forms are skipped.
- [ ] OFF prevents new approvals and leaves existing conversation permissions intact.
- [ ] Changing foreground app during selection prevents submission.
- [ ] Reload restores the enabled preference without leaving an orphan helper.
- [ ] A second enabled IDE window reports the single-instance conflict; it does not approve twice.
- [ ] Closing the owning IDE or terminating its extension host stops the helper after the current scan.
- [ ] UI changes or unavailable accessibility produce useful diagnostics without logging commands.
- [ ] Run `npm test` and `npm run package` on Windows.
- [ ] Review the VSIX contents and source for secrets and personal data.
- [ ] Set your real publisher ID and repository URL before marketplace publication.

Current validation: automated tests and package validation only. Live end-to-end release checks remain pending.
