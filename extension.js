'use strict';
const vscode = require('vscode');
const { createController } = require('./controller');
let controller;
function activate(context) {
  controller = createController(vscode, context);
  context.subscriptions.push(controller);
}
function deactivate() { controller?.dispose(); controller = undefined; }
module.exports = { activate, deactivate };
