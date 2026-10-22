param([Parameter(Mandatory = $true)][int]$ParentProcessId)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'rules.ps1')
# A session-wide lease prevents duplicate approvals across IDE windows.
$lease = [System.Threading.Mutex]::new($false, 'Local\AntigravityOption2Watcher')
$owned = $false
try { $owned = $lease.WaitOne(0) } catch [System.Threading.AbandonedMutexException] { $owned = $true }
if (-not $owned) { Write-Output 'Another window already owns the Option 2 helper. Turn it OFF there first.'; $lease.Dispose(); exit 2 }
try {
$parentStarted = (Get-Process -Id $ParentProcessId).StartTime
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class Option2Window {
 [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
}
'@
$ErrorActionPreference = 'Stop'
$scope = [System.Windows.Automation.TreeScope]::Descendants
$all = [System.Windows.Automation.Condition]::TrueCondition
$walker = [System.Windows.Automation.TreeWalker]::ControlViewWalker
$lastDiagnostic = ''
$lastDiagnosticTime = Get-Date
$lastSubmittedKey = ''
function Diagnostic($message) {
    if ($message -ne $script:lastDiagnostic -or ((Get-Date) - $script:lastDiagnosticTime).TotalSeconds -gt 30) {
        Write-Host "$(Get-Date -Format HH:mm:ss) $message"
        $script:lastDiagnostic = $message
        $script:lastDiagnosticTime = Get-Date
    }
}
function Activate-Control($element, $selection) {
    if (-not $element.Current.IsEnabled -or $element.Current.IsOffscreen) { return $false }
    $pattern = $null
    if ($selection -and $element.TryGetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern, [ref]$pattern)) {
        $pattern.Select(); return $true
    }
    $pattern = $null
    if ($element.TryGetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern, [ref]$pattern)) {
        $pattern.Invoke(); return $true
    }
    return $false
}
Write-Output 'READY'
Write-Host 'Option 2 helper running. Keep Antigravity in front.'
Write-Host 'Toggle OFF in the extension status bar to stop.'
Write-Host 'Approves every matching command for this conversation. No command filtering.'
Write-Host 'If nothing happens, Electron may not expose the controls through accessibility.'
while ($true) {
    $parentProcess = Get-Process -Id $ParentProcessId -ErrorAction SilentlyContinue
    if ($null -eq $parentProcess -or $parentProcess.StartTime -ne $parentStarted) { break }
    & {
        try {
            $handle = [Option2Window]::GetForegroundWindow()
            $window = [System.Windows.Automation.AutomationElement]::FromHandle($handle)
            $process = Get-Process -Id $window.Current.ProcessId
            if ($process.ProcessName -match '^Antigravity(?: IDE)?$' -and $window.Current.Name -match 'Antigravity') {
                $elements = $window.FindAll($scope, $all)
                $candidates = @($elements | Where-Object {
                    -not $_.Current.IsOffscreen -and
                    $_.Current.ControlType -eq [System.Windows.Automation.ControlType]::RadioButton -and
                    (Test-ConversationOption $_.Current.Name $_.Current.AutomationId)
                })
                Diagnostic "Matching conversation approval controls: $($candidates.Count)."
                if ($candidates.Count -eq 0) { $script:lastSubmittedKey = '' }
                if ($candidates.Count -eq 1) {
                    $choice = $candidates[0]
                    $optionId = $choice.Current.AutomationId
                    $optionText = $choice.Current.Name
                    $promptKey = "$handle|$optionId|$($choice.GetRuntimeId() -join ',')|$optionText"
                    if ($promptKey -eq $script:lastSubmittedKey) { return }
                    # Find the nearest shared container holding the full approval form.
                    $container = $walker.GetParent($choice)
                    for ($depth = 0; $depth -lt 7 -and $null -ne $container; $depth++) {
                        $items = $container.FindAll($scope, $all)
                        $submit = @($items | Where-Object {
                            $_.Current.IsEnabled -and -not $_.Current.IsOffscreen -and
                            $_.Current.ControlType -eq [System.Windows.Automation.ControlType]::Button -and
                            $_.Current.Name -match '^Submit(?:\s|$|\u21b5)'
                        })
                        $once = @($items | Where-Object { $_.Current.AutomationId -eq ($optionId -replace '-2$', '-1') -and $_.Current.ControlType -eq [System.Windows.Automation.ControlType]::RadioButton })
                        $target = @($items | Where-Object { $_.Current.Name -eq 'Edit permission target' -and $_.Current.ControlType -eq [System.Windows.Automation.ControlType]::Edit })
                        if ($submit.Count -eq 1 -and $once.Count -eq 1 -and $target.Count -eq 1) {
                            if ([Option2Window]::GetForegroundWindow() -eq $handle) {
                                if (Activate-Control $choice $true) {
                                    Start-Sleep -Milliseconds 150
                                    if ([Option2Window]::GetForegroundWindow() -eq $handle) {
                                        $selectionState = $null
                                        $selected = $choice.TryGetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern, [ref]$selectionState) -and $selectionState.Current.IsSelected
                                        $unchanged = $choice.Current.AutomationId -eq $optionId -and $choice.Current.Name -eq $optionText
                                        if ($selected -and $unchanged -and (Activate-Control $submit[0] $false)) {
                                            $script:lastSubmittedKey = $promptKey
                                            Write-Host "$(Get-Date -Format HH:mm:ss) Submitted conversation-scoped approval."
                                            Start-Sleep -Milliseconds 1200
                                        }
                                        elseif (-not $selected) { Diagnostic 'Selection was not confirmed; Submit skipped.' }
                                    }
                                } else { Diagnostic 'Option 2 found, but its accessibility control could not be selected.' }
                            }
                            break
                        }
                        if ($container.Equals($window)) { break }
                        $container = $walker.GetParent($container)
                    }
                }
            }
        } catch {
            Diagnostic 'Accessibility scan failed or controls changed; retrying without submitting.'
        }
    }
    Start-Sleep -Milliseconds 600
}
} finally {
    if ($owned) { $lease.ReleaseMutex() }
    $lease.Dispose()
}
