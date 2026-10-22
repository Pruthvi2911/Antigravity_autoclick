'use strict';
const { spawn } = require('node:child_process');
const path = require('node:path');

function createController(vscode, context, runtime = {}) {
  const platform = runtime.platform ?? process.platform;
  const launch = runtime.spawn ?? spawn;
  const output = vscode.window.createOutputChannel('Antigravity Option 2');
  const button = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
  const disposables = [];
  let child, startupTimer, disposed = false, busy = false, ready = false;
  let enabled = context.globalState.get('enabled', false);
  let lines = 0;
  function log(text) {
    if (++lines > 1000) { output.clear(); lines = 0; }
    output.appendLine(text);
  }
  function render() {
    button.text = enabled ? (ready ? '$(check) Option 2: ON' : '$(sync~spin) Option 2: Starting') : '$(circle-slash) Option 2: OFF';
    button.tooltip = enabled
      ? 'Click to stop automatic conversation approvals. Foreground Antigravity windows only. Commands are not reviewed.'
      : 'Click to enable automatic conversation approvals. Run Option 2: Show Diagnostics for logs.';
    button.show();
  }
  function stop() {
    clearTimeout(startupTimer); startupTimer = undefined;
    const current = child; child = undefined; ready = false;
    if (current) current.kill();
  }
  function fail(proc, reason) {
    if (disposed || child !== proc) return;
    clearTimeout(startupTimer); startupTimer = undefined;
    child = undefined; enabled = false; ready = false;
    proc.kill();
    void context.globalState.update('enabled', false);
    log(reason); render();
    void vscode.window.showErrorMessage('Option 2 stopped. Run “Option 2: Show Diagnostics” for details.');
  }
  function start() {
    if (disposed || child || !enabled) return;
    const executable = path.win32.join(process.env.SystemRoot || 'C:\\Windows', 'System32', 'WindowsPowerShell', 'v1.0', 'powershell.exe');
    let proc;
    try {
      proc = launch(executable, ['-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-File', path.join(context.extensionPath, 'src', 'watcher.ps1'), '-ParentProcessId', String(process.pid)], { windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'] });
    } catch (error) {
      enabled = false; void context.globalState.update('enabled', false); log(`Cannot launch helper: ${error.message}`); render(); return;
    }
    child = proc;
    startupTimer = setTimeout(() => fail(proc, 'Helper startup timed out after 20 seconds.'), 20000);
    startupTimer.unref();
    let pending = '';
    proc.stdout.on('data', chunk => {
      if (child !== proc || disposed) return;
      pending += chunk.toString();
      if (pending.length > 16384) pending = pending.slice(-16384);
      const complete = pending.split(/\r?\n/); pending = complete.pop();
      for (const line of complete) {
        if (line === 'READY') { clearTimeout(startupTimer); startupTimer = undefined; ready = true; render(); }
        else if (line.trim()) log(line);
      }
    });
    proc.stderr.on('data', () => {
      if (!disposed && child === proc) log('Helper reported an error; it may stop. No command text is recorded.');
    });
    proc.on('error', error => fail(proc, `Helper launch failed: ${error.message}`));
    proc.on('exit', code => fail(proc, `Helper exited (${code}). Another enabled window may own the helper.`));
  }
  button.command = 'option2.toggle';
  disposables.push(vscode.commands.registerCommand('option2.logs', () => output.show(true)));
  disposables.push(vscode.commands.registerCommand('option2.toggle', async () => {
    if (disposed || busy) return;
    busy = true;
    try {
      if (!enabled && (platform !== 'win32' || !vscode.workspace.isTrusted)) {
        void vscode.window.showErrorMessage('Option 2 requires Windows and a trusted workspace.'); return;
      }
      enabled = !enabled;
      if (!enabled) stop();
      await context.globalState.update('enabled', enabled);
      if (disposed) return;
      if (enabled) start();
      render();
    } catch {
      enabled = false; stop();
      if (!disposed) { log('Could not save the toggle preference; helper stopped.'); render(); }
    } finally { busy = false; }
  }));
  if (platform !== 'win32' || !vscode.workspace.isTrusted) enabled = false;
  render(); if (enabled) start();
  return { dispose() {
    if (disposed) return;
    disposed = true; stop();
    for (const item of disposables) item.dispose();
    button.dispose(); output.dispose();
  } };
}
module.exports = { createController };
