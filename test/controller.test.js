'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const { EventEmitter } = require('node:events');
const { execFileSync } = require('node:child_process');
const path = require('node:path');
const { createController } = require('../controller');
function setup({ enabled = false, trusted = true, platform = 'win32' } = {}) {
  const commands = new Map(), children = [], errors = [], logs = [];
  const item = { show() {}, dispose() {} };
  const context = { extensionPath: path.resolve(__dirname, '..'), globalState: { get: () => enabled, async update(key, value) { enabled = value; } } };
  const vscode = {
    StatusBarAlignment: { Right: 1 }, workspace: { isTrusted: trusted },
    commands: { registerCommand(id, fn) { commands.set(id, fn); return { dispose() {} }; } },
    window: { createStatusBarItem: () => item, createOutputChannel: () => ({ appendLine: x => logs.push(x), clear() {}, show() {}, dispose() {} }), showErrorMessage: x => errors.push(x) }
  };
  const controller = createController(vscode, context, { platform, spawn() {
    const proc = new EventEmitter(); proc.stdout = new EventEmitter(); proc.stderr = new EventEmitter(); proc.kills = 0; proc.kill = () => { proc.kills++; }; children.push(proc); return proc;
  } });
  return { controller, commands, children, errors, item, logs, saved: () => enabled };
}
test('off by default; toggle persists and waits for complete READY handshake', async () => {
  const s = setup(); assert.equal(s.children.length, 0);
  await s.commands.get('option2.toggle')(); assert.equal(s.saved(), true);
  assert.match(s.item.text, /Starting/);
  s.children[0].stdout.emit('data', Buffer.from('REA')); assert.match(s.item.text, /Starting/);
  s.children[0].stdout.emit('data', Buffer.from('DY\r\n')); assert.match(s.item.text, /ON/);
  await s.commands.get('option2.toggle')(); assert.equal(s.children[0].kills, 1); assert.equal(s.saved(), false);
  s.children[0].emit('exit', 0); assert.equal(s.errors.length, 0); s.controller.dispose();
});
test('restores enabled state and stops on disposal without forgetting preference', () => {
  const s = setup({ enabled: true }); assert.equal(s.children.length, 1);
  s.controller.dispose(); s.controller.dispose(); assert.equal(s.children[0].kills, 1); assert.equal(s.saved(), true);
});
test('unexpected exit resets preference and reports failure once', () => {
  const s = setup({ enabled: true }); s.children[0].emit('error', Error('failed')); s.children[0].emit('exit', 1);
  assert.equal(s.saved(), false); assert.equal(s.errors.length, 1); assert.match(s.item.text, /OFF/); s.controller.dispose();
});
test('unsupported platform and untrusted workspace do not launch', async () => {
  for (const settings of [{ platform: 'linux' }, { trusted: false }]) {
    const s = setup(settings); await s.commands.get('option2.toggle')(); assert.equal(s.children.length, 0); s.controller.dispose();
  }
});
test('rapid double toggle cannot create two helpers', async () => {
  const s = setup(); await Promise.all([s.commands.get('option2.toggle')(), s.commands.get('option2.toggle')()]);
  assert.equal(s.children.length, 1); s.controller.dispose();
});
test('late output from stopped helper cannot change new helper status', async () => {
  const s = setup({ enabled: true }); await s.commands.get('option2.toggle')(); await s.commands.get('option2.toggle')();
  s.children[0].stdout.emit('data', Buffer.from('READY\n')); assert.match(s.item.text, /Starting/); s.controller.dispose();
});
test('PowerShell approval rules and syntax', { skip: process.platform !== 'win32' }, () => {
  const result = execFileSync('powershell.exe', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', path.join(__dirname, 'rules.test.ps1')], { encoding: 'utf8' });
  assert.match(result, /8 approval matching cases/);
});
